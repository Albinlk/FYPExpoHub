import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
// XLSX is dynamically imported inside processMasterFileImport to reduce cold start times for callables

admin.initializeApp();
const db = admin.firestore();

export { markStudentProjectVisited, undoStudentProjectVisit } from './visits';
export { createLecturerAccount, deleteLecturerAccount, backfillLecturerIds } from './lecturers';

// -----------------------------------------------------------------
// Helper Functions for Data Parsing and Normalisation
// -----------------------------------------------------------------

/**
 * Normalises Malay month names to English numbers/names for parsing.
 */
function normaliseMalayDate(dateStr: string): Date {
  let cleanStr = dateStr.toLowerCase().trim();
  const monthMap: { [key: string]: string } = {
    'januari': 'january', 'februari': 'february', 'mac': 'march', 'april': 'april',
    'mei': 'may', 'jun': 'june', 'julai': 'july', 'ogos': 'august',
    'september': 'september', 'sept': 'september', 'oktober': 'october',
    'november': 'november', 'disember': 'december'
  };

  for (const [malay, english] of Object.entries(monthMap)) {
    if (cleanStr.includes(malay)) {
      cleanStr = cleanStr.replace(malay, english);
      break;
    }
  }

  const parsedDate = new Date(cleanStr);
  if (isNaN(parsedDate.getTime())) {
    throw new Error(`Gagal memparsed tarikh: ${dateStr}`);
  }
  return parsedDate;
}

/**
 * Converts standard time formats (e.g. "08:30 AM", "17.00") to total minutes since midnight
 */
function timeToMinutes(timeStr: string): number {
  const cleanStr = timeStr.toUpperCase().replace(/\s/g, '').trim();
  let hours = 0;
  let minutes = 0;

  if (cleanStr.includes('AM') || cleanStr.includes('PM')) {
    const isPM = cleanStr.includes('PM');
    const parts = cleanStr.replace('AM', '').replace('PM', '').split(':');
    hours = parseInt(parts[0], 10);
    minutes = parts.length > 1 ? parseInt(parts[1], 10) : 0;
    
    if (isPM && hours !== 12) hours += 12;
    if (!isPM && hours === 12) hours = 0;
  } else {
    // Treat as "24:00" or "24.00" format
    const separator = cleanStr.includes('.') ? '.' : ':';
    const parts = cleanStr.split(separator);
    hours = parseInt(parts[0], 10);
    minutes = parts.length > 1 ? parseInt(parts[1], 10) : 0;
  }

  return hours * 60 + minutes;
}

// -----------------------------------------------------------------
// Core Cloud Function Task: processMasterFileImport
// -----------------------------------------------------------------

export const processMasterFileImport = functions.storage.object().onFinalize(async (object) => {
  const filePath = object.name;
  if (!filePath || !filePath.startsWith('private/imports/')) return;

  const pathParts = filePath.split('/');
  const importId = pathParts[2];
  
  const importRef = db.collection('imports').doc(importId);
  await importRef.update({ status: 'processing' });

  try {
    // Download XLSX file content from Storage
    const bucket = admin.storage().bucket(object.bucket);
    const file = bucket.file(filePath);
    const [fileBuffer] = await file.download();

    // Lazy-load sheetjs (XLSX) to prevent top-level cold-start module bloat for other cloud functions
    const XLSX = require('xlsx');

    // Load workbook using sheetjs
    const workbook = XLSX.read(fileBuffer, { type: 'buffer' });
    const sheetNames = workbook.SheetNames;

    const summary: { [key: string]: number } = {};
    const warningCounts: { [key: string]: number } = { overlap: 0, privacy: 0, format: 0 };

    // -------------------------------------------------------------
    // SHEET 1: TENTATIF
    // -------------------------------------------------------------
    if (sheetNames.includes('TENTATIF')) {
      const sheet = workbook.Sheets['TENTATIF'];
      const rows: any[] = XLSX.utils.sheet_to_json(sheet);
      summary['TENTATIF'] = rows.length;

      const scheduleItems: any[] = [];
      let scheduleBatch = db.batch();
      let scheduleBatchCount = 0;
      let issueBatch = db.batch();
      let issueBatchCount = 0;

      const scheduleCandidatesCol = importRef.collection('scheduleCandidates');
      const validationIssuesCol = importRef.collection('validationIssues');

      const flushScheduleBatch = async () => {
        if (scheduleBatchCount > 0) { await scheduleBatch.commit(); scheduleBatch = db.batch(); scheduleBatchCount = 0; }
      };
      const flushIssueBatch = async () => {
        if (issueBatchCount > 0) { await issueBatch.commit(); issueBatch = db.batch(); issueBatchCount = 0; }
      };

      for (let i = 0; i < rows.length; i++) {
        const row = rows[i];
        const rowNum = i + 2;

        try {
          const dateStr = row['TARIKH'] || row['Date'];
          const startStr = row['MULA'] || row['Start'];
          const endStr = row['TAMAT'] || row['End'];
          const title = row['ACARA'] || row['Title'];
          const venue = row['TEMPAT'] || row['Venue'];
          const audience = row['SASARAN'] || row['Audience'] || 'Semua';
          const visibility = (row['AKSES'] || row['Visibility'] || 'public').toLowerCase().trim();

          if (!dateStr || !startStr || !endStr || !title || !venue) {
            const ref = validationIssuesCol.doc();
            issueBatch.set(ref, {
              issueType: 'missing_title',
              severity: 'warning',
              message: `Baris ${rowNum}: Maklumat penting kosong.`,
              worksheetName: 'TENTATIF',
              rowNumber: rowNum
            });
            issueBatchCount++;
            continue;
          }

          const parsedDate = normaliseMalayDate(dateStr);
          const startMin = timeToMinutes(startStr);
          const endMin = timeToMinutes(endStr);

          const candidate = {
            id: `sch_${importId}_${rowNum}`,
            date: admin.firestore.Timestamp.fromDate(parsedDate),
            startAt: startStr,
            endAt: endStr,
            title: title,
            venue: venue,
            audience: audience,
            classification: visibility === 'internal' ? 'internal' : 'publicCandidate',
            comparisonStatus: 'new',
            isDuplicate: false,
            isOverlapping: false
          };

          for (const other of scheduleItems) {
            if (other.date.toDate().toDateString() === parsedDate.toDateString()) {
              const otherStart = timeToMinutes(other.startAt);
              const otherEnd = timeToMinutes(other.endAt);
              if (startMin < otherEnd && endMin > otherStart) {
                candidate.isOverlapping = true;
                warningCounts.overlap++;
                const ref = validationIssuesCol.doc();
                issueBatch.set(ref, {
                  issueType: 'overlap',
                  severity: 'warning',
                  message: `Baris ${rowNum}: Waktu bertindih dengan "${other.title}".`,
                  worksheetName: 'TENTATIF',
                  rowNumber: rowNum
                });
                issueBatchCount++;
              }
            }
          }

          scheduleItems.push(candidate);
          scheduleBatch.set(scheduleCandidatesCol.doc(candidate.id), candidate);
          scheduleBatchCount++;

          if (scheduleBatchCount >= 500) await flushScheduleBatch();
          if (issueBatchCount >= 500) await flushIssueBatch();

        } catch (err: any) {
          warningCounts.format++;
          const ref = validationIssuesCol.doc();
          issueBatch.set(ref, {
            issueType: 'invalid_time',
            severity: 'error',
            message: `Baris ${rowNum}: Ralat memproses - ${err.message}`,
            worksheetName: 'TENTATIF',
            rowNumber: rowNum
          });
          issueBatchCount++;
        }
      }

      await flushScheduleBatch();
      await flushIssueBatch();
    }

    // -------------------------------------------------------------
    // SHEET 2: PEMENANG ANUGERAH
    // -------------------------------------------------------------
    if (sheetNames.includes('PEMENANG ANUGERAH')) {
      const sheet = workbook.Sheets['PEMENANG ANUGERAH'];
      const rows: any[] = XLSX.utils.sheet_to_json(sheet);
      summary['PEMENANG ANUGERAH'] = rows.length;

      let emailSkipCount = 0;
      let phoneSkipCount = 0;

      const awardCandidatesCol = importRef.collection('awardCandidates');
      const privacySkipsCol = importRef.collection('privacySkips');
      let awardBatch = db.batch();
      let awardBatchCount = 0;

      for (let i = 0; i < rows.length; i++) {
        const row = rows[i];
        const rowNum = i + 2;

        const category = row['KATEGORI'] || row['Category'];
        const projectTitle = row['PROJEK'] || row['Project'];
        const team = row['PELAJAR'] || row['Team'];
        const supervisor = row['PENYELIA'] || row['Supervisor'];
        const code = row['KOD_PROGRAM'] || row['Programme'];

        if (row['STUDENT_ID'] || row['MATRIK'] || row['NO_TEL'] || row['EMAIL']) {
          if (row['STUDENT_ID'] || row['MATRIK']) emailSkipCount++;
          if (row['NO_TEL'] || row['EMAIL']) phoneSkipCount++;
        }

        if (!category || !projectTitle) continue;

        const candidate = {
          id: `awd_${importId}_${rowNum}`,
          awardCategory: category,
          projectTitle: projectTitle,
          teamDisplayName: team || 'N/A',
          supervisorDisplayName: supervisor || 'N/A',
          programmeCode: code || 'N/A',
          isSkip: false
        };

        awardBatch.set(awardCandidatesCol.doc(candidate.id), candidate);
        awardBatchCount++;
        if (awardBatchCount >= 500) { await awardBatch.commit(); awardBatch = db.batch(); awardBatchCount = 0; }
      }

      if (awardBatchCount > 0) await awardBatch.commit();

      const privacyBatch = db.batch();
      if (emailSkipCount > 0) {
        privacyBatch.set(privacySkipsCol.doc(), {
          skipType: 'Student ID / Matrik',
          count: emailSkipCount,
          reason: 'Isolasi perlindungan maklumat peribadi PDPA.',
          worksheetName: 'PEMENANG ANUGERAH',
          timestamp: admin.firestore.FieldValue.serverTimestamp()
        });
        warningCounts.privacy += emailSkipCount;
      }

      if (phoneSkipCount > 0) {
        privacyBatch.set(privacySkipsCol.doc(), {
          skipType: 'No Tel / E-mel Peribadi',
          count: phoneSkipCount,
          reason: 'Isolasi perlindungan maklumat peribadi PDPA.',
          worksheetName: 'PEMENANG ANUGERAH',
          timestamp: admin.firestore.FieldValue.serverTimestamp()
        });
        warningCounts.privacy += phoneSkipCount;
      }

      if (emailSkipCount > 0 || phoneSkipCount > 0) await privacyBatch.commit();
    }

    // Update Import log record with completion status
    await importRef.update({
      status: 'pending_review',
      summary: summary,
      warningCounts: warningCounts,
      completedAt: admin.firestore.FieldValue.serverTimestamp()
    });

  } catch (error: any) {
    await importRef.update({
      status: 'error',
      errorSummary: error.message || 'Ralat tidak dijangka berlaku semasa parsing.'
    });
  }
});

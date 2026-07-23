import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as XLSX from 'xlsx';

admin.initializeApp();
const db = admin.firestore();

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

    // Load workbook using sheetjs
    const workbook = XLSX.read(fileBuffer, { type: 'buffer' });
    const sheetNames = workbook.SheetNames;

    const summary: { [key: string]: number } = {};
    const warningCounts: { [key: string]: number } = { overlap: 0, privacy: 0, format: 0 };
    
    // Create subcollections references
    const scheduleCandidatesCol = importRef.collection('scheduleCandidates');
    const awardCandidatesCol = importRef.collection('awardCandidates');
    const privacySkipsCol = importRef.collection('privacySkips');
    const validationIssuesCol = importRef.collection('validationIssues');

    // -------------------------------------------------------------
    // SHEET 1: TENTATIF
    // -------------------------------------------------------------
    if (sheetNames.includes('TENTATIF')) {
      const sheet = workbook.Sheets['TENTATIF'];
      const rows: any[] = XLSX.utils.sheet_to_json(sheet);
      summary['TENTATIF'] = rows.length;

      const scheduleItems: any[] = [];

      for (let i = 0; i < rows.length; i++) {
        const row = rows[i];
        const rowNum = i + 2; // spreadsheet rows are 1-indexed, header is row 1

        try {
          const dateStr = row['TARIKH'] || row['Date'];
          const startStr = row['MULA'] || row['Start'];
          const endStr = row['TAMAT'] || row['End'];
          const title = row['ACARA'] || row['Title'];
          const venue = row['TEMPAT'] || row['Venue'];
          const audience = row['SASARAN'] || row['Audience'] || 'Semua';
          const visibility = (row['AKSES'] || row['Visibility'] || 'public').toLowerCase().trim();

          if (!dateStr || !startStr || !endStr || !title || !venue) {
            await validationIssuesCol.add({
              issueType: 'missing_title',
              severity: 'warning',
              message: `Baris ${rowNum}: Maklumat penting kosong.`,
              worksheetName: 'TENTATIF',
              rowNumber: rowNum
            });
            continue;
          }

          const parsedDate = normaliseMalayDate(dateStr);
          const startMin = timeToMinutes(startStr);
          const endMin = timeToMinutes(endStr);

          // Build candidate object
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

          // Basic overlap check inside uploaded items
          for (const other of scheduleItems) {
            if (other.date.toDate().toDateString() === parsedDate.toDateString()) {
              const otherStart = timeToMinutes(other.startAt);
              const otherEnd = timeToMinutes(other.endAt);
              if (startMin < otherEnd && endMin > otherStart) {
                candidate.isOverlapping = true;
                warningCounts.overlap++;
                await validationIssuesCol.add({
                  issueType: 'overlap',
                  severity: 'warning',
                  message: `Baris ${rowNum}: Waktu bertindih dengan "${other.title}".`,
                  worksheetName: 'TENTATIF',
                  rowNumber: rowNum
                });
              }
            }
          }

          scheduleItems.push(candidate);
          await scheduleCandidatesCol.doc(candidate.id).set(candidate);

        } catch (err: any) {
          warningCounts.format++;
          await validationIssuesCol.add({
            issueType: 'invalid_time',
            severity: 'error',
            message: `Baris ${rowNum}: Ralat memproses - ${err.message}`,
            worksheetName: 'TENTATIF',
            rowNumber: rowNum
          });
        }
      }
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

      for (let i = 0; i < rows.length; i++) {
        const row = rows[i];
        const rowNum = i + 2;

        const category = row['KATEGORI'] || row['Category'];
        const projectTitle = row['PROJEK'] || row['Project'];
        const team = row['PELAJAR'] || row['Team'];
        const supervisor = row['PENYELIA'] || row['Supervisor'];
        const code = row['KOD_PROGRAM'] || row['Programme'];

        // PDPA Privacy: skip personal student identifiers
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

        await awardCandidatesCol.doc(candidate.id).set(candidate);
      }

      if (emailSkipCount > 0) {
        await privacySkipsCol.add({
          skipType: 'Student ID / Matrik',
          count: emailSkipCount,
          reason: 'Isolasi perlindungan maklumat peribadi PDPA.',
          worksheetName: 'PEMENANG ANUGERAH',
          timestamp: admin.firestore.FieldValue.serverTimestamp()
        });
        warningCounts.privacy += emailSkipCount;
      }

      if (phoneSkipCount > 0) {
        await privacySkipsCol.add({
          skipType: 'No Tel / E-mel Peribadi',
          count: phoneSkipCount,
          reason: 'Isolasi perlindungan maklumat peribadi PDPA.',
          worksheetName: 'PEMENANG ANUGERAH',
          timestamp: admin.firestore.FieldValue.serverTimestamp()
        });
        warningCounts.privacy += phoneSkipCount;
      }
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

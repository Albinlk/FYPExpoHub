const { CALON_MATRICS } = require('./lib/config');
const { httpsRequest, getAccessToken, authHeader, fetchAllDocs, parseDocFields, FIRESTORE_BASE } = require('./lib/firebase_api');

async function main() {
  console.log('Signing in...');
  const token = await getAccessToken();
  console.log('Signed in');

  const allDocs = await fetchAllDocs('publicProjects', token);
  console.log(`Total: ${allDocs.length} documents`);

  let updated = 0;
  let skipped = 0;
  for (const doc of allDocs) {
    const docId = doc.name.split('/').pop();
    const parsed = parseDocFields(doc);
    const matricId = parsed.matricId || parsed.matric_id || '';
    const currentVal = parsed.calonIndustri;
    const shouldBe = CALON_MATRICS.has(matricId);

    if (currentVal !== shouldBe) {
      const status = currentVal === undefined ? 'new' : `${currentVal}→${shouldBe}`;
      process.stdout.write(`${docId} (${matricId}): ${status} ... `);
      const url = `${FIRESTORE_BASE}/publicProjects/${docId}?updateMask.fieldPaths=calonIndustri`;
      const patchRes = await httpsRequest(url, 'PATCH', { fields: { calonIndustri: { booleanValue: shouldBe } } }, authHeader(token));
      if (patchRes.status === 200) {
        console.log('OK');
        updated++;
      } else {
        console.log('FAIL:', patchRes.body?.error?.message || JSON.stringify(patchRes.body).slice(0, 200));
      }
    } else {
      skipped++;
    }
  }

  console.log(`\nDone: ${updated} updated, ${skipped} already correct.`);
}

main().catch(console.error);

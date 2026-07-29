const { CALON_MATRICS } = require('./lib/config');
const { getAccessToken, authHeader, fetchAllDocs, parseDocFields } = require('./lib/firebase_api');

async function main() {
  const token = await getAccessToken();
  const allDocs = await fetchAllDocs('publicProjects', token);

  const dbMatrics = new Map();
  for (const doc of allDocs) {
    const parsed = parseDocFields(doc);
    const matricId = parsed.matricId || parsed.matric_id || '';
    const name = Array.isArray(parsed.teamDisplayNames) ? parsed.teamDisplayNames[0] || '' : '';
    dbMatrics.set(matricId, { id: doc.name.split('/').pop(), name });
  }

  console.log('=== Calon Matrics NOT found in database ===');
  let found = 0, notFound = 0;
  for (const m of [...CALON_MATRICS].sort()) {
    if (dbMatrics.has(m)) {
      found++;
    } else {
      notFound++;
      console.log(`  ${m} - no matching project in database`);
    }
  }
  console.log(`\nMatched: ${found}, Not found: ${notFound}`);

  console.log('\n=== Calon Matrics FOUND ===');
  for (const m of [...CALON_MATRICS].sort()) {
    if (dbMatrics.has(m)) {
      const info = dbMatrics.get(m);
      console.log(`  ${m} -> ${info.id} (${info.name})`);
    }
  }

  console.log('\n=== Database has 2023414614 (old CS255)? ===');
  if (dbMatrics.has('2023414614')) {
    const info = dbMatrics.get('2023414614');
    console.log(`  YES: ${info.id} (${info.name})`);
    console.log('  Should be 2028414614 - needs matricId update');
  } else {
    console.log('  NO - already corrected');
  }
}

main().catch(console.error);

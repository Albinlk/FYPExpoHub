const { getAccessToken, authHeader, fetchAllDocs, parseDocFields } = require('./lib/firebase_api');

async function main() {
  const token = await getAccessToken();
  const allDocs = await fetchAllDocs('publicProjects', token);

  let calonCount = 0;
  const programmes = {};
  for (const doc of allDocs) {
    const parsed = parseDocFields(doc);
    if (parsed.calonIndustri === true) {
      calonCount++;
      const prog = parsed.programmeCode || 'unknown';
      programmes[prog] = (programmes[prog] || 0) + 1;
    }
  }
  console.log(`Total projects with calonIndustri = true: ${calonCount}`);
  console.log('By programme:');
  for (const [prog, count] of Object.entries(programmes).sort()) {
    console.log(`  ${prog}: ${count}`);
  }
}
main().catch(console.error);

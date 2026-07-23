/**
 * set_admin_claim.js
 * 
 * Secure Node.js CLI script to assign the custom claim `admin: true` to an existing
 * Firebase Auth user. Run this using a service account credentials key file.
 * 
 * Usage:
 *   node scripts/set_admin_claim.js <user-email-or-uid> <true|false>
 */

const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

const serviceAccountPath = path.join(__dirname, '../serviceAccountKey.json');

if (!fs.existsSync(serviceAccountPath)) {
  console.error('\n[RALAT] Fail serviceAccountKey.json tidak dijumpai di direktori root.');
  console.error('Sila muat turun fail kunci akaun perkhidmatan daripada Konsol Firebase:');
  console.error('Project Settings -> Service Accounts -> Generate New Private Key\n');
  process.exit(1);
}

const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const identifier = process.argv[2];
const adminState = process.argv[3] !== 'false'; // defaults to true unless explicitly 'false'

if (!identifier) {
  console.error('\n[PANDUAN] Sila nyatakan e-mel atau UID pengguna.');
  console.error('Penggunaan: node scripts/set_admin_claim.js <email-atau-uid> [true|false]\n');
  process.exit(1);
}

async function setAdminClaim() {
  let user;
  try {
    if (identifier.includes('@')) {
      user = await admin.auth().getUserByEmail(identifier);
    } else {
      user = await admin.auth().getUser(identifier);
    }
  } catch (err) {
    console.error(`\n[RALAT] Gagal mencari pengguna dengan identiti "${identifier}": ${err.message}\n`);
    process.exit(1);
  }

  try {
    await admin.auth().setCustomUserClaims(user.uid, { admin: adminState });
    console.log(`\n[BERJAYA] Rekod tuntutan tersuai (custom claim) dikemaskini bagi:`);
    console.log(`  - Nama: ${user.displayName || 'N/A'}`);
    console.log(`  - E-mel: ${user.email}`);
    console.log(`  - UID: ${user.uid}`);
    console.log(`  - Status Pentadbir (admin: true): ${adminState}\n`);
    process.exit(0);
  } catch (err) {
    console.error(`\n[RALAT] Gagal menetapkan tuntutan pentadbir: ${err.message}\n`);
    process.exit(1);
  }
}

setAdminClaim();

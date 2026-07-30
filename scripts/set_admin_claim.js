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
  console.error('\n[ERROR] serviceAccountKey.json file not found in root directory.');
  console.error('Please download a service account key file from Firebase Console:');
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
  console.error('\n[USAGE] Please specify user email or UID.');
  console.error('Usage: node scripts/set_admin_claim.js <email-or-uid> [true|false]\n');
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
    console.error(`\n[ERROR] Failed to find user with identity "${identifier}": ${err.message}\n`);
    process.exit(1);
  }

  try {
    await admin.auth().setCustomUserClaims(user.uid, { admin: adminState });
    console.log(`\n[SUCCESS] Custom user claim record updated for:`);
    console.log(`  - Name: ${user.displayName || 'N/A'}`);
    console.log(`  - Email: ${user.email}`);
    console.log(`  - UID: ${user.uid}`);
    console.log(`  - Administrator Status (admin: true): ${adminState}\n`);
    process.exit(0);
  } catch (err) {
    console.error(`\n[ERROR] Failed to set administrator claims: ${err.message}\n`);
    process.exit(1);
  }
}

setAdminClaim();

/**
 * rotate_admin_password.js
 *
 * Rotate the password for a Firebase Auth user using a service account key.
 * By default a strong random password is generated and printed exactly once;
 * set the ADMIN_PASSWORD_NEW env var to provide your own value instead.
 *
 * Usage:
 *   node scripts/rotate_admin_password.js [email-or-uid]
 *
 * Env:
 *   ADMIN_PASSWORD_NEW  - optional; if set, used instead of generating.
 *   ADMIN_EMAIL         - optional; used when no email/UID arg is given.
 *
 * After rotation, update scripts/.env -> ADMIN_PASSWORD=<new value>.
 */

const admin = require('firebase-admin');
const crypto = require('crypto');
const path = require('path');
const fs = require('fs');
const dotenv = require('dotenv');

const serviceAccountPath = path.join(__dirname, '../serviceAccountKey.json');

if (!fs.existsSync(serviceAccountPath)) {
  console.error('\n[ERROR] serviceAccountKey.json file not found in root directory.');
  console.error('Please download a service account key file from Firebase Console:');
  console.error('Project Settings -> Service Accounts -> Generate New Private Key\n');
  process.exit(1);
}

dotenv.config({ path: path.join(__dirname, '.env') });

const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

function generatePassword(length = 20) {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%^&*';
  const bytes = crypto.randomBytes(length);
  let out = '';
  for (let i = 0; i < length; i++) out += chars[bytes[i] % chars.length];
  return out;
}

const identifier = process.argv[2] || process.env.ADMIN_EMAIL;
const provided = process.env.ADMIN_PASSWORD_NEW;
const newPassword = provided || generatePassword();

if (!identifier) {
  console.error('\n[USAGE] Please specify the user email or UID.');
  console.error('Usage: node scripts/rotate_admin_password.js <email-or-uid>\n');
  process.exit(1);
}

async function rotatePassword() {
  let user;
  try {
    user = identifier.includes('@')
      ? await admin.auth().getUserByEmail(identifier)
      : await admin.auth().getUser(identifier);
  } catch (err) {
    console.error(`\n[ERROR] Failed to find user "${identifier}": ${err.message}\n`);
    process.exit(1);
  }

  try {
    await admin.auth().updateUser(user.uid, { password: newPassword });
    console.log('\n[SUCCESS] Password rotated for:');
    console.log(`  - Email: ${user.email}`);
    console.log(`  - UID: ${user.uid}`);
    if (provided) {
      console.log('  - New password: taken from ADMIN_PASSWORD_NEW');
    } else {
      console.log('\n  NEW PASSWORD (shown once, save it now):');
      console.log(`  ${newPassword}`);
    }
    console.log('\n  Next: update scripts/.env -> ADMIN_PASSWORD=<new value>\n');
    process.exit(0);
  } catch (err) {
    console.error(`\n[ERROR] Failed to rotate password: ${err.message}\n`);
    process.exit(1);
  }
}

rotatePassword();

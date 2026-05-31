// Seed demo users for Factory Attendance.
//
// Creates Firebase Auth accounts and their matching Firestore `users/{uid}`
// profile documents (including roles) using the public REST APIs — no service
// account needed. Run AFTER enabling Email/Password auth and creating the
// Firestore database (in test mode) in the Firebase console:
//
//   node tool/seed.mjs
//
// Re-running is safe: existing accounts are signed in instead of re-created.

const API_KEY = 'AIzaSyDmH4fCoEsZOGbkVrsk955wd8EuS0DgI1A';
const PROJECT_ID = 'factory-attend-72702';

const IDENTITY = 'https://identitytoolkit.googleapis.com/v1';
const FIRESTORE =
  `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents`;

/** Demo accounts. Passwords meet the 6+ char minimum. */
const users = [
  {
    email: 'admin@pabrik.com',
    password: 'Admin123',
    nik: '10001',
    name: 'Andi Admin',
    role: 'admin',
    department: 'HRD',
    position: 'HR Manager',
  },
  {
    email: 'budi@pabrik.com',
    password: 'Budi1234',
    nik: '20001',
    name: 'Budi Santoso',
    role: 'employee',
    department: 'Produksi',
    position: 'Operator Mesin',
  },
];

/** Convert a flat JS object into Firestore REST "fields" typed values. */
function toFirestoreFields(obj) {
  const fields = {};
  for (const [key, value] of Object.entries(obj)) {
    fields[key] = { stringValue: String(value) };
  }
  return { fields };
}

async function signUpOrIn(email, password) {
  // Try to create the account first.
  let res = await fetch(`${IDENTITY}/accounts:signUp?key=${API_KEY}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password, returnSecureToken: true }),
  });
  let data = await res.json();

  if (!res.ok && data.error?.message === 'EMAIL_EXISTS') {
    // Already exists → sign in to obtain a fresh idToken + uid.
    res = await fetch(`${IDENTITY}/accounts:signInWithPassword?key=${API_KEY}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password, returnSecureToken: true }),
    });
    data = await res.json();
  }

  if (!res.ok) {
    throw new Error(`Auth failed for ${email}: ${data.error?.message ?? res.status}`);
  }
  return { uid: data.localId, idToken: data.idToken };
}

async function writeProfile(uid, idToken, profile) {
  const res = await fetch(`${FIRESTORE}/users/${uid}?key=${API_KEY}`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${idToken}`,
    },
    body: JSON.stringify(toFirestoreFields(profile)),
  });
  if (!res.ok) {
    const data = await res.json().catch(() => ({}));
    throw new Error(
      `Firestore write failed for ${uid}: ${data.error?.message ?? res.status}`,
    );
  }
}

async function main() {
  for (const u of users) {
    const { email, password, ...profile } = u;
    const { uid, idToken } = await signUpOrIn(email, password);
    await writeProfile(uid, idToken, { email, ...profile });
    console.log(`✓ ${email}  (uid=${uid}, role=${profile.role})`);
  }
  console.log('\nDone. Demo credentials:');
  for (const u of users) {
    console.log(`  ${u.role.padEnd(8)} → ${u.email} / ${u.password}`);
  }
}

main().catch((err) => {
  console.error('Seed failed:', err.message);
  process.exit(1);
});

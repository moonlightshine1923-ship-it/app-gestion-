import bcrypt from 'bcryptjs';
import { connect, initSchema, get, run } from './db.js';
import { ensureFinanceSchema } from './routes/finances.js';


export async function ensureSeed() {
  await initSchema();
  await ensureFinanceSchema();

  const userCount = (await get('SELECT COUNT(*) AS c FROM users')).c;
  if (userCount > 0) return; // comptes déjà créés → rien à faire

  console.log('  Création des comptes de connexion (base vide, sans données de démonstration)...');

  await run('INSERT INTO users (email, password_hash, role) VALUES (?,?,?)',
    ['admin@opa.dz', bcrypt.hashSync('Admin@2026', 10), 'admin']);
  await run('INSERT INTO users (email, password_hash, role) VALUES (?,?,?)',
    ['president@opa.dz', bcrypt.hashSync('President@2026', 10), 'president']);

  console.log('  Comptes créés : admin@opa.dz / Admin@2026  ·  president@opa.dz / President@2026');
}

// Lancement direct : npm run seed
if (import.meta.url === `file://${process.argv[1]}`) {
  (async () => { await connect(); await ensureSeed(); process.exit(0); })();
}

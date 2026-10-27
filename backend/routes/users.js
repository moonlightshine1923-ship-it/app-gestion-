import express from 'express';
import bcrypt from 'bcryptjs';
import { get, query, run } from '../db.js';
import { authenticate, authorize, normalizePermissions } from '../middleware/auth.js';
import { logAction } from '../audit.js';
import { notifyUserCreated, notifyPasswordChanged } from '../email.js';

const router = express.Router();
const ROLES = ['admin', 'president', 'saisie'];

async function assertNotPresidentTarget(req, res, { allowSelf = false } = {}) {
  const target = await get('SELECT id, email, role, permissions FROM users WHERE id = ?', [req.params.id]);
  if (!target) {
    res.status(404).json({ error: 'Compte introuvable.' });
    return null;
  }
  if (target.role === 'president') {
    if (!(allowSelf && req.user.role === 'president' && req.user.id === target.id)) {
      res.status(403).json({ error: 'Le compte Président est protégé : seul le Président peut modifier ses informations.' });
      return null;
    }
  }
  return target;
}

router.get('/', authenticate, authorize('admin', 'president', 'perm:comptes_view', 'perm:comptes_edit'), async (req, res) => {
  try {
    const rows = await query('SELECT id, email, role, permissions, created_at FROM users ORDER BY id');
    res.json(rows.map((u) => ({ ...u, permissions: normalizePermissions(u.permissions) })));
  } catch (e) { res.status(500).json({ error: e.message }); }
});

router.post('/', authenticate, authorize('admin', 'president', 'perm:comptes_edit'), async (req, res) => {
  try {
    const { email, password, role, permissions } = req.body || {};
    const effectiveRole = role || 'saisie';
    const cleanEmail = String(email || '').toLowerCase().trim();

    if (!cleanEmail || !password) return res.status(400).json({ error: "Nom d'utilisateur (ou email) et mot de passe requis." });
    if (!ROLES.includes(effectiveRole)) return res.status(400).json({ error: 'Rôle invalide.' });
    if (String(password).length < 6) return res.status(400).json({ error: 'Mot de passe : 6 caractères minimum.' });
    if (effectiveRole === 'president' && req.user.role !== 'president') {
      return res.status(403).json({ error: 'Seul le Président peut créer un nouveau compte Président.' });
    }

    const normalizedPermissions = normalizePermissions(permissions);
    if (effectiveRole === 'saisie' && !normalizedPermissions.length) {
      return res.status(400).json({ error: 'Choisissez au moins une rubrique.' });
    }

    const exists = await get('SELECT id FROM users WHERE LOWER(email) = ?', [cleanEmail]);
    if (exists) return res.status(409).json({ error: 'Cet identifiant / email est déjà utilisé.' });

    const hash = bcrypt.hashSync(password, 10);
    const serializedPermissions = normalizedPermissions.length ? JSON.stringify(normalizedPermissions) : null;
    const r = await run(
      'INSERT INTO users (email, password_hash, role, permissions) VALUES (?,?,?,?)',
      [cleanEmail, hash, effectiveRole, serializedPermissions]
    );
    await logAction(req, 'CREATE_USER', `Création du compte utilisateur : ${cleanEmail} (Rôle: ${effectiveRole})`, r.insertId, 'user');
    
    const clientIp = req.ip || req.headers['x-forwarded-for'] || req.connection?.remoteAddress || '';
    await notifyUserCreated({
      createdUserEmail: cleanEmail,
      createdUserRole: effectiveRole,
      createdByEmail: req.user.email,
      ip: clientIp
    });

    res.status(201).json({
      id: r.insertId,
      email: cleanEmail,
      role: effectiveRole,
      permissions: normalizedPermissions,
    });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

router.patch('/:id/role', authenticate, authorize('admin', 'president', 'perm:comptes_edit'), async (req, res) => {
  try {
    const target = await assertNotPresidentTarget(req, res);
    if (!target) return;
    const { role, permissions, email } = req.body || {};
    const effectiveRole = role || target.role || 'saisie';
    if (!ROLES.includes(effectiveRole)) return res.status(400).json({ error: 'Rôle invalide.' });
    if (effectiveRole === 'president' && req.user.role !== 'president') {
      return res.status(403).json({ error: 'Seul le Président peut attribuer le rôle Président.' });
    }
    const normalizedPermissions = normalizePermissions(permissions);
    if (effectiveRole === 'saisie' && !normalizedPermissions.length) {
      return res.status(400).json({ error: 'Choisissez au moins une rubrique.' });
    }

    const nextEmail = email !== undefined && String(email).trim() ? String(email).toLowerCase().trim() : target.email;
    if (nextEmail !== target.email) {
      const dup = await get('SELECT id FROM users WHERE LOWER(email) = ? AND id <> ?', [nextEmail, target.id]);
      if (dup) return res.status(409).json({ error: 'Cet identifiant / email est déjà utilisé.' });
    }

    const serialized = normalizedPermissions.length ? JSON.stringify(normalizedPermissions) : null;
    await run('UPDATE users SET email = ?, role = ?, permissions = ? WHERE id = ?', [nextEmail, effectiveRole, serialized, target.id]);
    await logAction(req, 'EDIT_USER_ROLE', `Mise à jour des accès de l'utilisateur ${nextEmail} (Rôle: ${effectiveRole})`, target.id, 'user');
    res.json({ ok: true, email: nextEmail, role: effectiveRole, permissions: normalizedPermissions });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

router.patch('/:id/password', authenticate, authorize('admin', 'president', 'perm:comptes_edit'), async (req, res) => {
  try {
    const target = await assertNotPresidentTarget(req, res);
    if (!target) return;
    const { password } = req.body || {};
    if (!password || String(password).length < 6) return res.status(400).json({ error: 'Mot de passe : 6 caractères minimum.' });
    await run('UPDATE users SET password_hash = ? WHERE id = ?', [bcrypt.hashSync(password, 10), target.id]);
    await logAction(req, 'EDIT_USER_PASSWORD', `Réinitialisation du mot de passe de l'utilisateur ${target.email}`, target.id, 'user');
    
    const clientIp = req.ip || req.headers['x-forwarded-for'] || req.connection?.remoteAddress || '';
    await notifyPasswordChanged({
      userEmail: target.email,
      changedByEmail: req.user.email,
      ip: clientIp,
      isResetByAdmin: true
    });

    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

router.delete('/:id', authenticate, authorize('admin', 'president', 'perm:comptes_edit'), async (req, res) => {
  try {
    const target = await assertNotPresidentTarget(req, res);
    if (!target) return;
    if (parseInt(req.params.id, 10) === req.user.id) {
      return res.status(400).json({ error: 'Vous ne pouvez pas supprimer votre propre compte.' });
    }
    const r = await run('DELETE FROM users WHERE id = ?', [target.id]);
    if (!r.affectedRows) return res.status(404).json({ error: 'Compte introuvable.' });
    await logAction(req, 'DELETE_USER', `Suppression de l'utilisateur ${target.email}`, target.id, 'user');
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

export default router;
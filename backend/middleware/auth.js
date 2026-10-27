import jwt from 'jsonwebtoken';
import { get } from '../db.js';

export const JWT_SECRET = process.env.OPA_SECRET || 'opa-secret-key-change-in-production';

// ✅ Toutes les permissions par rubrique (Lecture seule _view / Lecture & écriture _edit ou _manage)
export const AVAILABLE_PERMISSIONS = [
  // Tableau de bord
  'dashboard_view',
  'dashboard_edit',
  // Adhérents
  'adherents_view',
  'adherents_add',
  'adherents_manage',
  // Services aux adhérents
  'services_view',
  'services_edit',
  // Bureau exécutif
  'bureau_view',
  'bureau_edit',
  // Blacklist
  'blacklist_view',
  'blacklist_edit',
  // Demandes (site web)
  'demandes_view',
  'demandes_edit',
  // Documents
  'documents_view',
  'documents_edit',
  // Finances
  'finances_view',
  'finances_edit',
  // Comptes utilisateurs
  'comptes_view',
  'comptes_edit',
  // Paramètres & sauvegardes
  'parametres_view',
  'parametres_edit',
  // Journal d'audit
  'audit_view',
  'audit_edit',
];

// Chaque permission d'écriture implique automatiquement la permission de lecture correspondante
const IMPLIED_PERMISSIONS = {
  dashboard_view: ['dashboard_edit'],
  adherents_view: ['adherents_manage'],
  adherents_add: ['adherents_manage'],
  services_view: ['services_edit'],
  bureau_view: ['bureau_edit'],
  blacklist_view: ['blacklist_edit'],
  demandes_view: ['demandes_edit'],
  documents_view: ['documents_edit'],
  finances_view: ['finances_edit'],
  comptes_view: ['comptes_edit'],
  parametres_view: ['parametres_edit'],
  audit_view: ['audit_edit'],
};

export function normalizePermissions(input) {
  let list = [];

  if (Array.isArray(input)) {
    list = input;
  } else if (typeof input === 'string' && input.trim()) {
    try {
      const parsed = JSON.parse(input);
      list = Array.isArray(parsed) ? parsed : [];
    } catch {
      list = input.split(',');
    }
  }

  return [...new Set(list.map((x) => String(x || '').trim()).filter(Boolean))]
    .filter((x) => AVAILABLE_PERMISSIONS.includes(x));
}

export function resolveUserPermissions(user = {}) {
  if (user.role === 'admin' || user.role === 'president') return AVAILABLE_PERMISSIONS.slice();
  const perms = normalizePermissions(user.permissions);
  if (!perms.length && user.role === 'saisie') return ['adherents_add'];
  return perms;
}

export function hasPermission(user, permission) {
  if (!permission) return true;
  if (user?.role === 'admin' || user?.role === 'president') return true;
  const perms = resolveUserPermissions(user);
  if (perms.includes(permission)) return true;
  const impliers = IMPLIED_PERMISSIONS[permission] || [];
  return impliers.some((imp) => perms.includes(imp));
}

export function signToken(user) {
  return jwt.sign(
    {
      id: user.id,
      email: user.email,
      nom: user.nom || null,
      role: user.role,
      permissions: resolveUserPermissions(user),
    },
    JWT_SECRET,
    { expiresIn: '12h' }
  );
}

export async function authenticate(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : (req.query.token || null);

  if (!token) return res.status(401).json({ error: 'Authentification requise.' });
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    // Tenter de lire les droits à jour en base (pour que toute modification de permissions prenne effet sans reconnexion)
    if (decoded?.id) {
      try {
        const dbUser = await get('SELECT id, email, role, permissions FROM users WHERE id = ?', [decoded.id]);
        if (dbUser) {
          decoded.role = dbUser.role;
          decoded.permissions = resolveUserPermissions(dbUser);
        } else {
          decoded.permissions = resolveUserPermissions(decoded);
        }
      } catch {
        // Si la DB n'est pas joignable, utiliser les permissions du JWT
        decoded.permissions = resolveUserPermissions(decoded);
      }
    } else {
      decoded.permissions = resolveUserPermissions(decoded);
    }
    req.user = decoded;
    next();
  } catch {
    return res.status(401).json({ error: 'Session expirée ou invalide.' });
  }
}

export function authorize(...rules) {
  return (req, res, next) => {
    if (!rules.length) return next();

    const roles = rules.filter((r) => !String(r).startsWith('perm:'));
    const perms = rules.filter((r) => String(r).startsWith('perm:')).map((r) => String(r).slice(5));

    const roleOk = roles.includes(req.user.role);
    const permOk = perms.some((p) => hasPermission(req.user, p));

    if (!roleOk && !permOk) {
      return res.status(403).json({ error: 'Accès refusé pour votre rôle.' });
    }
    next();
  };
}
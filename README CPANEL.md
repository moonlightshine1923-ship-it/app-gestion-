### OPA — Application de gestion interne
Application web de gestion interne pour l’Organisation des Patronats d’Algérie (OPA). Conçue pour centraliser et fluidifier les opérations administratives, elle permet de gérer :
* Les adhérents et les membres du bureau exécutif
* Génération automatique des cartes d'adhérents et des dossiers d'adhésion complets, mis en forme et prêts à être imprimés
* Le traitement des demandes reçues depuis le site public
* L'archivage et la gestion des documents
* Le suivi et la gestion des services rendus aux adhérents
* La gestion de la trésorerie (comptes bancaires et caisse)
* La gestion des utilisateurs et des rôles
* Le suivi de la blacklist
* Les statistiques, les sauvegardes et le journal d’audit (logs)

Le projet est une application full-stack Node.js / Express / MySQL avec un frontend en HTML, CSS et JavaScript vanilla.

### 1. Adhérents
* Ajout, modification et suppression de fiches adhérents.
* **Génération automatique de matricule** (avec possibilité de renseigner un matricule personnalisé et manuel pour les adhérents situés hors Algérie).
* Gestion des informations détaillées : wilaya, type de membre, documents professionnels, statut de paiement et système d'étoiles.
* Suivi des adhésions : renouvellement et affichage des alertes d'expiration.
* **Génération de la carte d'adhérent** et des **dossiers d'adhésion** mis en forme, prêts à être imprimés.

### 2. Bureau exécutif
* Gestion complète des membres du bureau exécutif.
* Attribution de matricules spécifiques.
* Gestion des badges spéciaux.

### 3. Demandes (Site public)
* Réception et affichage centralisé des demandes envoyées depuis le site web public.
* Traitement des demandes : modification des statuts, gestion des priorités et affectation à un responsable.
* Suivi interactif : ajout de réponses/commentaires, clôture et suppression.

### 4. Documents & Outils
* Fusion de fichiers PDF et gestion des répertoires de documents.
* Suppression des documents fusionnés directement depuis l'interface.

### 5. Gestion des utilisateurs
* Création de comptes personnalisés avec contrôle d'accès granulaire (permissions spécifiques par module : adhérents, demandes, documents, etc.).
* Réinitialisation des mots de passe et gestion/suppression des comptes.

### 6. Blacklist
* Enregistrement, modification et retrait de personnes de la liste noire.
* Signalement et affichage des alertes directement sur le tableau de bord.

### 7. Sauvegarde & Maintenance
* Déclenchement de sauvegardes manuelles depuis les paramètres.
* Stockage des sauvegardes SQL dans le dossier `backups/` et téléchargement sécurisé via l'application.

### 8. Journal d’audit (Logs)
* Traçabilité complète de l'activité des utilisateurs (historique des connexions, actions de création, modification, suppression, traitement des demandes et lancements de sauvegardes).

### 9. Services aux adhérents
* Enregistrement et suivi du nombre de services rendus à chaque adhérent.
* Historique et statistiques de l'accompagnement par adhérent.

### 10. Gestion financière (Banque & Caisse)
* Suivi des mouvements financiers, des comptes bancaires et de la caisse.
* Enregistrement des flux et état de la trésorerie.

## 🛠️ Stack technique

* **Backend & API :** Node.js, Express (API REST et serveur web)
* **Base de données :** MySQL / MariaDB (via `mysql2`)
* **Sécurité & Authentification :** JWT (JSON Web Tokens), `bcryptjs` (hachage des mots de passe)
* **Gestion des fichiers & Documents :** `Multer` (upload), `pdf-merger-js` (fusion de PDF)
* **Communication :** `Nodemailer` (préparation pour l'envoi d'e-mails)
* **Frontend :** HTML, CSS et JavaScript vanilla

## ⚙️ Installation et lancement

1. **Prérequis :** Installer Node.js (v18+) et s'assurer que MySQL/MariaDB est actif (via XAMPP ou autre).
2. **Installer les dépendances :**
   ```bash
   npm install

## 📝 Guide de développement et bonnes pratiques

### Méthode recommandée pour les modifications
1. **Sauvegarder :** Toujours faire une sauvegarde de la base de données (depuis les paramètres de l'app ou via phpMyAdmin) avant toute modification majeure.
2. **Méthode itérative :** Modifier un seul sujet à la fois (frontend, API, backend ou base de données) et tester à chaque étape.
3. **Actualisation :**
   * Après modification du backend : Redémarrer le serveur (`Ctrl + C` puis `npm start`).
   * Après modification du frontend : Vider le cache du navigateur (`Ctrl + F5`).
4. **Validation :** Tester le cas nominal, les cas d'erreur/vide, et vérifier systématiquement la console du navigateur (`F12`) ainsi que les logs du terminal.

### Architecture des vues frontend (`frontend/js/views.js`)
La majorité des écrans de l'application sont gérés via des fonctions dédiées :
* `dashboard()` : Tableau de bord
* `adherentsList()` / `adherentForm()` / `adherentDetail()` : Gestion des adhérents
* `demandesList()` / `demandeDetail()` : Gestion des demandes publiques
* `documentsList()` : Gestion documentaire
* `comptesList()` : Comptes utilisateurs
* `servicesList()` : Gestion des services rendus
* `financeList()` ou `tresorerieList()` : Gestion de la caisse et des comptes bancaires
* `blacklistList()` : Blacklist
* `auditList()` : Journal d’audit

#### Les rôles admin et president ont l’accès complet.#####

*(Vous pourrez modifier ces mots de passe dans l'onglet Paramètres une fois connecté).*

### 🆔 Règle de génération du matricule
Format : `AGN19-[CODE_WILAYA][NUM_ORDRE 3 chiffres][TYPE][ANNEE]`  
*Exemple : `AGN1931005CR2025`*
* Le numéro d'ordre est propre à chaque wilaya et calculé automatiquement.
* Recalculé dynamiquement si la wilaya, le type ou l'année changent.
* *(Rappel : Saisie manuelle possible pour les adhérents situés hors Algérie).*

### 🔒 Contrôles de format et unicité
* **NIN :** Exactement 18 chiffres obligatoires.
* **Documents d'identification :** 
  * Numéro RC : exactement 12 caractères.
  * Carte Artisan : exactement 11 caractères.
  * Numéro d'Agrément : 10 à 15 caractères.
* **Unicité :** Deux adhérents ne peuvent pas partager le même NIN, téléphone ou numéro de document (les noms/prénoms identiques restent autorisés).



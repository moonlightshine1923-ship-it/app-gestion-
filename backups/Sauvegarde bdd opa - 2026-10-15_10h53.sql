-- ============================================
--  Sauvegarde de la base de données OPA
--  Base : opa_db
--  Date : 15/10/2026 10:53:44
-- ============================================

SET FOREIGN_KEY_CHECKS=0;
SET NAMES utf8mb4;

CREATE DATABASE IF NOT EXISTS `opa_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `opa_db`;

-- --------------------------------------------
-- Table : adherents
-- --------------------------------------------
DROP TABLE IF EXISTS `adherents`;
CREATE TABLE `adherents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `matricule` varchar(40) DEFAULT NULL,
  `nom` varchar(100) NOT NULL,
  `prenom` varchar(100) NOT NULL,
  `nom_ar` varchar(100) DEFAULT NULL,
  `prenom_ar` varchar(100) DEFAULT NULL,
  `nom_soc` varchar(255) DEFAULT NULL,
  `telephone` varchar(30) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `whatsapp` varchar(30) DEFAULT NULL,
  `viber` varchar(30) DEFAULT NULL,
  `adresse_personnelle` varchar(255) DEFAULT NULL,
  `date_naissance` date DEFAULT NULL,
  `nin` varchar(18) DEFAULT NULL,
  `doc_type` varchar(2) DEFAULT 'RC',
  `doc_numero` varchar(20) DEFAULT NULL,
  `doc_numero_2` varchar(20) DEFAULT NULL,
  `photo` varchar(255) DEFAULT NULL,
  `wilaya_code` varchar(5) NOT NULL DEFAULT '16',
  `type_code` varchar(2) NOT NULL DEFAULT 'AD',
  `niveau` varchar(40) DEFAULT 'Adhérent Simple',
  `num_ordre` int(11) DEFAULT 0,
  `annee` int(11) DEFAULT 0,
  `date_adhesion` date DEFAULT NULL,
  `description` text DEFAULT NULL,
  `fichier_final` varchar(255) DEFAULT NULL,
  `dossier_pdf` varchar(255) DEFAULT NULL,
  `paiement_mode` varchar(20) DEFAULT NULL,
  `paiement_banque` varchar(150) DEFAULT NULL,
  `paiement_ref` varchar(100) DEFAULT NULL,
  `bureau_code` varchar(3) DEFAULT NULL,
  `bureau_badge_type` varchar(100) DEFAULT NULL,
  `qualite_ar` varchar(100) DEFAULT NULL,
  `etoiles` tinyint(4) DEFAULT 0,
  `notation_negative` tinyint(4) DEFAULT 0,
  `malus` tinyint(4) DEFAULT 0,
  `fonction` varchar(150) DEFAULT NULL,
  `diplome` varchar(150) DEFAULT NULL,
  `profession` varchar(150) DEFAULT NULL,
  `carte_remise` tinyint(1) DEFAULT 0,
  `top_month_rank` int(11) DEFAULT NULL,
  `top_year_rank` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `matricule` (`matricule`),
  UNIQUE KEY `telephone` (`telephone`),
  UNIQUE KEY `nin` (`nin`),
  UNIQUE KEY `uq_adh_nin` (`nin`),
  UNIQUE KEY `uq_adh_tel` (`telephone`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------
-- Table : audit_logs
-- --------------------------------------------
DROP TABLE IF EXISTS `audit_logs`;
CREATE TABLE `audit_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `user_email` varchar(150) DEFAULT NULL,
  `action_type` varchar(50) NOT NULL,
  `description` text DEFAULT NULL,
  `target_id` varchar(50) DEFAULT NULL,
  `target_type` varchar(50) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_audit_user` (`user_id`),
  CONSTRAINT `fk_audit_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `audit_logs` (`id`, `user_id`, `user_email`, `action_type`, `description`, `target_id`, `target_type`, `ip_address`, `created_at`) VALUES
(2, 3, 'admin@opa.dz', 'LOGIN', 'Connexion de l''utilisateur admin@opa.dz', NULL, NULL, '::1', '2026-10-15 10:53:43');

-- --------------------------------------------
-- Table : blacklist
-- --------------------------------------------
DROP TABLE IF EXISTS `blacklist`;
CREATE TABLE `blacklist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `adherent_id` int(11) DEFAULT NULL,
  `nom` varchar(100) NOT NULL,
  `prenom` varchar(100) NOT NULL,
  `matricule` varchar(40) DEFAULT NULL,
  `telephone` varchar(30) DEFAULT NULL,
  `nin` varchar(18) DEFAULT NULL,
  `wilaya_code` varchar(5) DEFAULT NULL,
  `motif` text DEFAULT NULL,
  `niveau_risque` enum('faible','moyen','élevé','critique') DEFAULT 'moyen',
  `date_blacklist` date DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_blacklist_adherent` (`adherent_id`),
  KEY `fk_blacklist_user` (`created_by`),
  KEY `idx_blacklist_matricule` (`matricule`),
  KEY `idx_blacklist_nom` (`nom`,`prenom`),
  CONSTRAINT `fk_blacklist_adherent` FOREIGN KEY (`adherent_id`) REFERENCES `adherents` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_blacklist_user` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------
-- Table : demandes_site
-- --------------------------------------------
DROP TABLE IF EXISTS `demandes_site`;
CREATE TABLE `demandes_site` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `numero` varchar(30) DEFAULT NULL,
  `nom` varchar(100) NOT NULL,
  `prenom` varchar(100) NOT NULL,
  `num_tel` varchar(30) DEFAULT NULL,
  `matricule` varchar(40) DEFAULT NULL,
  `wilaya` varchar(100) DEFAULT NULL,
  `titre_demande` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `priorite` varchar(20) NOT NULL DEFAULT 'Normale',
  `statut` varchar(20) NOT NULL DEFAULT 'En attente',
  `affecte_a` varchar(150) DEFAULT NULL,
  `reponse` text DEFAULT NULL,
  `source` varchar(20) DEFAULT 'site',
  `fichier_joint` varchar(255) DEFAULT NULL,
  `date_creation` datetime DEFAULT current_timestamp(),
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `numero` (`numero`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------
-- Table : demandes_site_pieces
-- --------------------------------------------
DROP TABLE IF EXISTS `demandes_site_pieces`;
CREATE TABLE `demandes_site_pieces` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `demande_id` bigint(20) unsigned NOT NULL,
  `filename` varchar(255) NOT NULL,
  `original_name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_demande_site_id` (`demande_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------
-- Table : documents
-- --------------------------------------------
DROP TABLE IF EXISTS `documents`;
CREATE TABLE `documents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `adherent_id` int(11) DEFAULT NULL,
  `titre` varchar(200) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `original_name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_doc_adherent` (`adherent_id`),
  CONSTRAINT `fk_doc_adherent` FOREIGN KEY (`adherent_id`) REFERENCES `adherents` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------
-- Table : finance_comptes
-- --------------------------------------------
DROP TABLE IF EXISTS `finance_comptes`;
CREATE TABLE `finance_comptes` (
  `code` varchar(20) NOT NULL,
  `label` varchar(120) NOT NULL,
  `montant_initial` decimal(15,5) NOT NULL DEFAULT 0.00000,
  `observation` text DEFAULT NULL,
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `finance_comptes` (`code`, `label`, `montant_initial`, `observation`, `updated_at`) VALUES
('BDL', 'BDL — Banque de Développement Local', '0.00000', NULL, '2026-10-15 10:52:54'),
('CAISSE', 'Caisse (espèces)', '0.00000', NULL, '2026-10-15 10:52:54'),
('CPA', 'CPA — Crédit Populaire d''Algérie', '0.00000', NULL, '2026-10-15 10:52:54');

-- --------------------------------------------
-- Table : finance_frais_mensuels_log
-- --------------------------------------------
DROP TABLE IF EXISTS `finance_frais_mensuels_log`;
CREATE TABLE `finance_frais_mensuels_log` (
  `compte_code` varchar(20) NOT NULL,
  `nature` varchar(40) NOT NULL,
  `mois` varchar(7) NOT NULL,
  `generated_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`compte_code`,`nature`,`mois`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `finance_frais_mensuels_log` (`compte_code`, `nature`, `mois`, `generated_at`) VALUES
('BDL', 'ebanking', '2026-01', '2026-10-15 10:53:25'),
('BDL', 'ebanking', '2026-02', '2026-10-15 10:53:25'),
('BDL', 'ebanking', '2026-03', '2026-10-15 10:53:25'),
('BDL', 'ebanking', '2026-04', '2026-10-15 10:53:25'),
('BDL', 'ebanking', '2026-05', '2026-10-15 10:53:25'),
('BDL', 'ebanking', '2026-06', '2026-10-15 10:53:25'),
('BDL', 'ebanking', '2026-07', '2026-10-15 10:53:25'),
('BDL', 'ebanking', '2026-08', '2026-10-15 10:53:25'),
('BDL', 'ebanking', '2026-09', '2026-10-15 10:53:25'),
('CPA', 'frais_application', '2026-01', '2026-10-15 10:53:25'),
('CPA', 'frais_application', '2026-02', '2026-10-15 10:53:25'),
('CPA', 'frais_application', '2026-03', '2026-10-15 10:53:25'),
('CPA', 'frais_application', '2026-04', '2026-10-15 10:53:25'),
('CPA', 'frais_application', '2026-05', '2026-10-15 10:53:25'),
('CPA', 'frais_application', '2026-06', '2026-10-15 10:53:25'),
('CPA', 'frais_application', '2026-07', '2026-10-15 10:53:25'),
('CPA', 'frais_application', '2026-08', '2026-10-15 10:53:25'),
('CPA', 'frais_application', '2026-09', '2026-10-15 10:53:25');

-- --------------------------------------------
-- Table : finance_mouvements
-- --------------------------------------------
DROP TABLE IF EXISTS `finance_mouvements`;
CREATE TABLE `finance_mouvements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `compte_code` varchar(20) NOT NULL,
  `sens` enum('entree','sortie') NOT NULL,
  `nature` varchar(40) NOT NULL,
  `montant` decimal(15,5) NOT NULL,
  `date_mouvement` date NOT NULL,
  `adherent_id` int(11) DEFAULT NULL,
  `cheque_numero` varchar(20) DEFAULT NULL,
  `motif` varchar(150) DEFAULT NULL,
  `observation` text DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_fin_user` (`created_by`),
  KEY `idx_fin_compte` (`compte_code`),
  KEY `idx_fin_date` (`date_mouvement`),
  KEY `idx_fin_adherent` (`adherent_id`),
  KEY `idx_fin_sens` (`sens`),
  CONSTRAINT `fk_fin_adherent` FOREIGN KEY (`adherent_id`) REFERENCES `adherents` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_fin_compte` FOREIGN KEY (`compte_code`) REFERENCES `finance_comptes` (`code`),
  CONSTRAINT `fk_fin_user` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `finance_mouvements` (`id`, `compte_code`, `sens`, `nature`, `montant`, `date_mouvement`, `adherent_id`, `cheque_numero`, `motif`, `observation`, `created_by`, `created_at`) VALUES
(19, 'CPA', 'sortie', 'frais_application', '1071.00000', '2026-01-31', NULL, NULL, 'Frais d''application (fin de mois)', 'Déduction automatique fin de mois (1 071 DA)', NULL, '2026-10-15 10:53:25'),
(20, 'BDL', 'sortie', 'ebanking', '2000.00000', '2026-01-31', NULL, NULL, 'Frais ebanking (fin de mois)', 'Déduction automatique fin de mois (2 000 DA)', NULL, '2026-10-15 10:53:25'),
(21, 'CPA', 'sortie', 'frais_application', '1071.00000', '2026-02-28', NULL, NULL, 'Frais d''application (fin de mois)', 'Déduction automatique fin de mois (1 071 DA)', NULL, '2026-10-15 10:53:25'),
(22, 'BDL', 'sortie', 'ebanking', '2000.00000', '2026-02-28', NULL, NULL, 'Frais ebanking (fin de mois)', 'Déduction automatique fin de mois (2 000 DA)', NULL, '2026-10-15 10:53:25'),
(23, 'CPA', 'sortie', 'frais_application', '1071.00000', '2026-03-31', NULL, NULL, 'Frais d''application (fin de mois)', 'Déduction automatique fin de mois (1 071 DA)', NULL, '2026-10-15 10:53:25'),
(24, 'BDL', 'sortie', 'ebanking', '2000.00000', '2026-03-31', NULL, NULL, 'Frais ebanking (fin de mois)', 'Déduction automatique fin de mois (2 000 DA)', NULL, '2026-10-15 10:53:25'),
(25, 'CPA', 'sortie', 'frais_application', '1071.00000', '2026-04-30', NULL, NULL, 'Frais d''application (fin de mois)', 'Déduction automatique fin de mois (1 071 DA)', NULL, '2026-10-15 10:53:25'),
(26, 'BDL', 'sortie', 'ebanking', '2000.00000', '2026-04-30', NULL, NULL, 'Frais ebanking (fin de mois)', 'Déduction automatique fin de mois (2 000 DA)', NULL, '2026-10-15 10:53:25'),
(27, 'CPA', 'sortie', 'frais_application', '1071.00000', '2026-05-31', NULL, NULL, 'Frais d''application (fin de mois)', 'Déduction automatique fin de mois (1 071 DA)', NULL, '2026-10-15 10:53:25'),
(28, 'BDL', 'sortie', 'ebanking', '2000.00000', '2026-05-31', NULL, NULL, 'Frais ebanking (fin de mois)', 'Déduction automatique fin de mois (2 000 DA)', NULL, '2026-10-15 10:53:25'),
(29, 'CPA', 'sortie', 'frais_application', '1071.00000', '2026-06-30', NULL, NULL, 'Frais d''application (fin de mois)', 'Déduction automatique fin de mois (1 071 DA)', NULL, '2026-10-15 10:53:25'),
(30, 'BDL', 'sortie', 'ebanking', '2000.00000', '2026-06-30', NULL, NULL, 'Frais ebanking (fin de mois)', 'Déduction automatique fin de mois (2 000 DA)', NULL, '2026-10-15 10:53:25'),
(31, 'CPA', 'sortie', 'frais_application', '1071.00000', '2026-07-31', NULL, NULL, 'Frais d''application (fin de mois)', 'Déduction automatique fin de mois (1 071 DA)', NULL, '2026-10-15 10:53:25'),
(32, 'BDL', 'sortie', 'ebanking', '2000.00000', '2026-07-31', NULL, NULL, 'Frais ebanking (fin de mois)', 'Déduction automatique fin de mois (2 000 DA)', NULL, '2026-10-15 10:53:25'),
(33, 'CPA', 'sortie', 'frais_application', '1071.00000', '2026-08-31', NULL, NULL, 'Frais d''application (fin de mois)', 'Déduction automatique fin de mois (1 071 DA)', NULL, '2026-10-15 10:53:25'),
(34, 'BDL', 'sortie', 'ebanking', '2000.00000', '2026-08-31', NULL, NULL, 'Frais ebanking (fin de mois)', 'Déduction automatique fin de mois (2 000 DA)', NULL, '2026-10-15 10:53:25'),
(35, 'CPA', 'sortie', 'frais_application', '1071.00000', '2026-09-30', NULL, NULL, 'Frais d''application (fin de mois)', 'Déduction automatique fin de mois (1 071 DA)', NULL, '2026-10-15 10:53:25'),
(36, 'BDL', 'sortie', 'ebanking', '2000.00000', '2026-09-30', NULL, NULL, 'Frais ebanking (fin de mois)', 'Déduction automatique fin de mois (2 000 DA)', NULL, '2026-10-15 10:53:25');

-- --------------------------------------------
-- Table : services_adherents
-- --------------------------------------------
DROP TABLE IF EXISTS `services_adherents`;
CREATE TABLE `services_adherents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `adherent_id` int(11) NOT NULL,
  `titre` varchar(200) NOT NULL,
  `type_service` varchar(100) DEFAULT 'Administratif',
  `description` text DEFAULT NULL,
  `statut` varchar(40) DEFAULT 'Effectué',
  `date_service` date NOT NULL,
  `montant` decimal(15,2) DEFAULT 0.00,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_service_user` (`created_by`),
  KEY `idx_service_adherent` (`adherent_id`),
  KEY `idx_service_date` (`date_service`),
  CONSTRAINT `fk_service_adherent` FOREIGN KEY (`adherent_id`) REFERENCES `adherents` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_service_user` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------
-- Table : users
-- --------------------------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` varchar(20) NOT NULL,
  `permissions` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `users` (`id`, `email`, `password_hash`, `role`, `permissions`, `created_at`) VALUES
(3, 'admin@opa.dz', '$2b$10$4eLEs9ltAgmQbYR6Zt3WDOxi7L4UDqE8U8OFve1Q/2h4rDg3rlph6', 'admin', NULL, '2026-10-15 10:52:54'),
(4, 'president@opa.dz', '$2b$10$NDinDyn4tU7P5NhuX1UNoevtAtF3DJ3Vb9i4vm3uubLJGsV/lSOvO', 'president', NULL, '2026-10-15 10:52:54');

SET FOREIGN_KEY_CHECKS=1;

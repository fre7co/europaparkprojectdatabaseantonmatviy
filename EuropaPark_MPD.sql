-- Europa-Park - Module 162 - MPD (MySQL 8.0.16+ / InnoDB)
-- Script généré depuis la modélisation ; 37 tables en 3NF.

CREATE DATABASE IF NOT EXISTS europapark CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE europapark;

CREATE TABLE pays (
  id_pays INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant du pays',
  code_iso_pays CHAR(2) NOT NULL COMMENT 'Code ISO 3166-1 alpha-2',
  nom_pays VARCHAR(60) NOT NULL COMMENT 'Nom du pays',
  CONSTRAINT pk_pays PRIMARY KEY (id_pays),
  CONSTRAINT uq_pays_code_iso_pays UNIQUE (code_iso_pays)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Pays (thème de quartier, adresse, nationalité)';

CREATE TABLE localite (
  id_localite INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant de la localité',
  code_postal VARCHAR(10) NOT NULL COMMENT 'Code postal (NPA)',
  nom_localite VARCHAR(80) NOT NULL COMMENT 'Nom de la localité',
  id_pays INT UNSIGNED NOT NULL COMMENT 'Clé étrangère issue de SE_SITUER',
  CONSTRAINT pk_localite PRIMARY KEY (id_localite),
  CONSTRAINT uq_localite_1 UNIQUE (code_postal, nom_localite, id_pays),
  CONSTRAINT fk_localite_id_pays FOREIGN KEY (id_pays) REFERENCES pays (id_pays)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Localité postale (NPA/ville), sortie des personnes pour respecter la 3NF';

CREATE TABLE quartier (
  id_quartier INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant du quartier',
  code_quartier VARCHAR(3) NOT NULL COMMENT 'Code du quartier sur la carte',
  nom_quartier VARCHAR(60) NOT NULL COMMENT 'Nom du quartier',
  type_quartier ENUM('Pays','Région','Thématique','Logistique') NOT NULL COMMENT 'Nature du quartier',
  wifi_quartier TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Wi-Fi couvrant tout le quartier',
  id_pays INT UNSIGNED NULL COMMENT 'Clé étrangère issue de REPRESENTER',
  CONSTRAINT pk_quartier PRIMARY KEY (id_quartier),
  CONSTRAINT uq_quartier_code_quartier UNIQUE (code_quartier),
  CONSTRAINT fk_quartier_id_pays FOREIGN KEY (id_pays) REFERENCES pays (id_pays)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Quartier thématique du parc';

CREATE TABLE hotel (
  id_hotel INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant de l''hébergement',
  nom_hotel VARCHAR(80) NOT NULL COMMENT 'Nom de l''hébergement',
  type_hebergement ENUM('Hôtel','Resort et camping') NOT NULL COMMENT 'Type d''hébergement',
  nb_etoiles TINYINT UNSIGNED NULL COMMENT 'Nombre d''étoiles',
  superior TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Mention Superior',
  theme_hotel VARCHAR(80) NULL COMMENT 'Thème de l''hébergement',
  CONSTRAINT pk_hotel PRIMARY KEY (id_hotel),
  CONSTRAINT uq_hotel_nom_hotel UNIQUE (nom_hotel),
  CONSTRAINT ck_hotel_1 CHECK (nb_etoiles IS NULL OR nb_etoiles BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Hébergement du parc (hôtel, Silver Lake City)';

CREATE TABLE lieu (
  id_lieu INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant du lieu',
  numero_carte SMALLINT UNSIGNED NULL COMMENT 'Numéro sur la carte',
  nom_lieu VARCHAR(120) NOT NULL COMMENT 'Nom du lieu',
  wifi_lieu TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Wi-Fi disponible sur le lieu',
  reserve_clients_hotel TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Réservé aux clients des hôtels',
  points_junior SMALLINT UNSIGNED NULL COMMENT 'Points Junior Club gagnés par passage',
  id_quartier INT UNSIGNED NULL COMMENT 'Clé étrangère issue de CONTENIR',
  id_hotel INT UNSIGNED NULL COMMENT 'Clé étrangère issue de ABRITER',
  CONSTRAINT pk_lieu PRIMARY KEY (id_lieu),
  CONSTRAINT uq_lieu_1 UNIQUE (id_quartier, numero_carte),
  CONSTRAINT fk_lieu_id_quartier FOREIGN KEY (id_quartier) REFERENCES quartier (id_quartier),
  CONSTRAINT fk_lieu_id_hotel FOREIGN KEY (id_hotel) REFERENCES hotel (id_hotel),
  CONSTRAINT ck_lieu_1 CHECK ((id_quartier IS NULL) <> (id_hotel IS NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tout point exploité du parc ou d''un hôtel (super-type de ATTRACTION et INFRASTRUCTURE)';

CREATE TABLE type_attraction (
  id_type_attraction INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant du type d''attraction',
  libelle_type_attraction VARCHAR(50) NOT NULL COMMENT 'Libellé du type',
  CONSTRAINT pk_type_attraction PRIMARY KEY (id_type_attraction),
  CONSTRAINT uq_type_attraction_libelle_type_attraction UNIQUE (libelle_type_attraction)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Catégorie d''attraction';

CREATE TABLE ligne_transport (
  id_ligne INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant de la ligne',
  nom_ligne VARCHAR(60) NOT NULL COMMENT 'Nom de la ligne',
  mode_transport ENUM('Train','Monorail') NOT NULL COMMENT 'Mode de transport',
  CONSTRAINT pk_ligne_transport PRIMARY KEY (id_ligne),
  CONSTRAINT uq_ligne_transport_nom_ligne UNIQUE (nom_ligne)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Ligne interne reliant plusieurs stations (EP-Express, Panorama Train, Monorail)';

CREATE TABLE attraction (
  id_lieu INT UNSIGNED NOT NULL COMMENT 'Identifiant hérité de LIEU',
  age_min TINYINT UNSIGNED NULL COMMENT 'Âge minimum',
  age_max TINYINT UNSIGNED NULL COMMENT 'Âge maximum',
  taille_min_cm SMALLINT UNSIGNED NULL COMMENT 'Taille minimum (cm)',
  taille_max_cm SMALLINT UNSIGNED NULL COMMENT 'Taille maximum (cm)',
  age_accompagnement TINYINT UNSIGNED NULL COMMENT 'Âge jusqu''auquel un adulte doit accompagner',
  billet_supplementaire TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Billet en supplément requis (Coastiality)',
  capacite_horaire SMALLINT UNSIGNED NULL COMMENT 'Capacité (personnes/heure)',
  duree_tour_s SMALLINT UNSIGNED NULL COMMENT 'Durée d''un tour (secondes)',
  annee_ouverture SMALLINT UNSIGNED NULL COMMENT 'Année d''ouverture',
  id_type_attraction INT UNSIGNED NOT NULL COMMENT 'Clé étrangère issue de CLASSER_ATTRACTION',
  id_ligne INT UNSIGNED NULL COMMENT 'Clé étrangère issue de DESSERVIR',
  CONSTRAINT pk_attraction PRIMARY KEY (id_lieu),
  CONSTRAINT fk_attraction_id_lieu FOREIGN KEY (id_lieu) REFERENCES lieu (id_lieu) ON DELETE CASCADE,
  CONSTRAINT fk_attraction_id_type_attraction FOREIGN KEY (id_type_attraction) REFERENCES type_attraction (id_type_attraction),
  CONSTRAINT fk_attraction_id_ligne FOREIGN KEY (id_ligne) REFERENCES ligne_transport (id_ligne),
  CONSTRAINT ck_attraction_1 CHECK (age_max IS NULL OR age_min IS NULL OR age_max >= age_min),
  CONSTRAINT ck_attraction_2 CHECK (taille_max_cm IS NULL OR taille_min_cm IS NULL OR taille_max_cm >= taille_min_cm)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Attraction (sous-type de LIEU)';

CREATE TABLE type_infrastructure (
  id_type_infrastructure INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant du type d''infrastructure',
  libelle_type_infrastructure VARCHAR(50) NOT NULL COMMENT 'Libellé du type',
  categorie_infrastructure ENUM('Restauration','Commerce','Spectacle','Bien-être','Accueil et services','Découverte','Logistique') NOT NULL COMMENT 'Catégorie du type',
  CONSTRAINT pk_type_infrastructure PRIMARY KEY (id_type_infrastructure),
  CONSTRAINT uq_type_infrastructure_libelle_type_infrastructure UNIQUE (libelle_type_infrastructure)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Type d''infrastructure';

CREATE TABLE infrastructure (
  id_lieu INT UNSIGNED NOT NULL COMMENT 'Identifiant hérité de LIEU',
  capacite_accueil SMALLINT UNSIGNED NULL COMMENT 'Capacité d''accueil (personnes)',
  type_service ENUM('Libre-service','À table','Mixte') NULL COMMENT 'Mode de service en restauration',
  id_type_infrastructure INT UNSIGNED NOT NULL COMMENT 'Clé étrangère issue de CLASSER_INFRA',
  CONSTRAINT pk_infrastructure PRIMARY KEY (id_lieu),
  CONSTRAINT fk_infrastructure_id_lieu FOREIGN KEY (id_lieu) REFERENCES lieu (id_lieu) ON DELETE CASCADE,
  CONSTRAINT fk_infrastructure_id_type_infrastructure FOREIGN KEY (id_type_infrastructure) REFERENCES type_infrastructure (id_type_infrastructure)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Infrastructure de quartier ou d''hôtel (sous-type de LIEU)';

CREATE TABLE periode (
  id_periode INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant de la période',
  libelle_periode VARCHAR(50) NOT NULL COMMENT 'Libellé de la période',
  date_debut_periode DATE NOT NULL COMMENT 'Premier jour de la période',
  date_fin_periode DATE NOT NULL COMMENT 'Dernier jour de la période',
  heure_ouverture_parc TIME NULL COMMENT 'Heure d''ouverture du parc',
  heure_fermeture_parc TIME NULL COMMENT 'Heure de fermeture du parc',
  CONSTRAINT pk_periode PRIMARY KEY (id_periode),
  CONSTRAINT uq_periode_libelle_periode UNIQUE (libelle_periode),
  CONSTRAINT ck_periode_1 CHECK (date_fin_periode >= date_debut_periode)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Période de l''année : ouverture des lieux et affectation du personnel';

CREATE TABLE spectacle (
  id_spectacle INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant du spectacle',
  titre_spectacle VARCHAR(120) NOT NULL COMMENT 'Titre du spectacle',
  genre_spectacle VARCHAR(40) NULL COMMENT 'Genre du spectacle',
  duree_spectacle_min SMALLINT UNSIGNED NULL COMMENT 'Durée (minutes)',
  id_infrastructure INT UNSIGNED NOT NULL COMMENT 'Clé étrangère issue de SE_JOUER',
  CONSTRAINT pk_spectacle PRIMARY KEY (id_spectacle),
  CONSTRAINT uq_spectacle_titre_spectacle UNIQUE (titre_spectacle),
  CONSTRAINT fk_spectacle_id_infrastructure FOREIGN KEY (id_infrastructure) REFERENCES infrastructure (id_lieu)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Spectacle (œuvre) présenté dans une infrastructure';

CREATE TABLE seance (
  id_seance INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant de la séance',
  date_heure_seance DATETIME NOT NULL COMMENT 'Date et heure de début',
  id_spectacle INT UNSIGNED NOT NULL COMMENT 'Clé étrangère issue de PRESENTER',
  CONSTRAINT pk_seance PRIMARY KEY (id_seance),
  CONSTRAINT uq_seance_1 UNIQUE (id_spectacle, date_heure_seance),
  CONSTRAINT fk_seance_id_spectacle FOREIGN KEY (id_spectacle) REFERENCES spectacle (id_spectacle)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Représentation d''un spectacle à une date et une heure';

CREATE TABLE plat (
  id_plat INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant du plat',
  nom_plat VARCHAR(80) NOT NULL COMMENT 'Nom du plat',
  categorie_plat ENUM('Salé','Sucré','Boisson') NOT NULL COMMENT 'Catégorie du plat',
  id_quartier_typique INT UNSIGNED NULL COMMENT 'Clé étrangère issue de ETRE_TYPIQUE',
  CONSTRAINT pk_plat PRIMARY KEY (id_plat),
  CONSTRAINT uq_plat_nom_plat UNIQUE (nom_plat),
  CONSTRAINT fk_plat_id_quartier_typique FOREIGN KEY (id_quartier_typique) REFERENCES quartier (id_quartier)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Plat vendu ; peut être typique d''un quartier';

CREATE TABLE employe (
  id_employe INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant de l''employé',
  matricule VARCHAR(10) NOT NULL COMMENT 'Matricule RH',
  nom_employe VARCHAR(60) NOT NULL COMMENT 'Nom de famille',
  prenom_employe VARCHAR(60) NOT NULL COMMENT 'Prénom',
  date_naissance_employe DATE NOT NULL COMMENT 'Date de naissance',
  email_employe VARCHAR(120) NOT NULL COMMENT 'Adresse e-mail',
  telephone_employe VARCHAR(20) NULL COMMENT 'Numéro de téléphone',
  adresse_employe VARCHAR(120) NOT NULL COMMENT 'Rue et numéro',
  date_embauche DATE NOT NULL COMMENT 'Date d''embauche',
  date_fin_contrat DATE NULL COMMENT 'Date de fin de contrat',
  id_pays_nationalite INT UNSIGNED NOT NULL COMMENT 'Clé étrangère issue de AVOIR_NATIONALITE',
  id_localite INT UNSIGNED NOT NULL COMMENT 'Clé étrangère issue de HABITER_EMPLOYE',
  CONSTRAINT pk_employe PRIMARY KEY (id_employe),
  CONSTRAINT uq_employe_matricule UNIQUE (matricule),
  CONSTRAINT uq_employe_email_employe UNIQUE (email_employe),
  CONSTRAINT fk_employe_id_pays_nationalite FOREIGN KEY (id_pays_nationalite) REFERENCES pays (id_pays),
  CONSTRAINT fk_employe_id_localite FOREIGN KEY (id_localite) REFERENCES localite (id_localite),
  CONSTRAINT ck_employe_1 CHECK (date_fin_contrat IS NULL OR date_fin_contrat >= date_embauche)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Employé du parc';

CREATE TABLE langue (
  id_langue INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant de la langue',
  code_langue CHAR(2) NOT NULL COMMENT 'Code ISO 639-1',
  nom_langue VARCHAR(40) NOT NULL COMMENT 'Nom de la langue',
  CONSTRAINT pk_langue PRIMARY KEY (id_langue),
  CONSTRAINT uq_langue_code_langue UNIQUE (code_langue)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Langue parlée par le personnel';

CREATE TABLE job (
  id_job INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant du job',
  intitule_job VARCHAR(80) NOT NULL COMMENT 'Intitulé du job',
  salaire_horaire DECIMAL(6,2) NOT NULL COMMENT 'Salaire horaire de base (EUR)',
  CONSTRAINT pk_job PRIMARY KEY (id_job),
  CONSTRAINT uq_job_intitule_job UNIQUE (intitule_job),
  CONSTRAINT ck_job_1 CHECK (salaire_horaire > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Métier exercé dans le parc';

CREATE TABLE visiteur (
  id_visiteur INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant du visiteur',
  nom_visiteur VARCHAR(60) NOT NULL COMMENT 'Nom de famille',
  prenom_visiteur VARCHAR(60) NOT NULL COMMENT 'Prénom',
  date_naissance_visiteur DATE NOT NULL COMMENT 'Date de naissance',
  email_visiteur VARCHAR(120) NULL COMMENT 'Adresse e-mail',
  telephone_visiteur VARCHAR(20) NULL COMMENT 'Numéro de téléphone',
  adresse_visiteur VARCHAR(120) NULL COMMENT 'Rue et numéro',
  id_localite INT UNSIGNED NULL COMMENT 'Clé étrangère issue de HABITER_VISITEUR',
  CONSTRAINT pk_visiteur PRIMARY KEY (id_visiteur),
  CONSTRAINT uq_visiteur_email_visiteur UNIQUE (email_visiteur),
  CONSTRAINT fk_visiteur_id_localite FOREIGN KEY (id_localite) REFERENCES localite (id_localite)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Personne qui visite le parc, loue du matériel ou séjourne';

CREATE TABLE type_billet (
  id_type_billet INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant du type de billet',
  libelle_type_billet VARCHAR(60) NOT NULL COMMENT 'Libellé du billet',
  nb_jours_validite SMALLINT UNSIGNED NOT NULL COMMENT 'Nombre de jours de validité',
  tarif_billet DECIMAL(7,2) NOT NULL COMMENT 'Tarif catalogue (EUR)',
  CONSTRAINT pk_type_billet PRIMARY KEY (id_type_billet),
  CONSTRAINT uq_type_billet_libelle_type_billet UNIQUE (libelle_type_billet),
  CONSTRAINT ck_type_billet_1 CHECK (nb_jours_validite >= 1),
  CONSTRAINT ck_type_billet_2 CHECK (tarif_billet >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Catalogue des billets';

CREATE TABLE billet (
  id_billet INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant du billet',
  code_barres VARCHAR(30) NOT NULL COMMENT 'Code-barres du billet',
  date_achat DATE NOT NULL COMMENT 'Date d''achat',
  date_debut_validite DATE NOT NULL COMMENT 'Premier jour valable',
  prix_paye DECIMAL(7,2) NOT NULL COMMENT 'Prix payé (EUR)',
  id_visiteur INT UNSIGNED NOT NULL COMMENT 'Clé étrangère issue de POSSEDER',
  id_type_billet INT UNSIGNED NOT NULL COMMENT 'Clé étrangère issue de CORRESPONDRE',
  CONSTRAINT pk_billet PRIMARY KEY (id_billet),
  CONSTRAINT uq_billet_code_barres UNIQUE (code_barres),
  CONSTRAINT fk_billet_id_visiteur FOREIGN KEY (id_visiteur) REFERENCES visiteur (id_visiteur),
  CONSTRAINT fk_billet_id_type_billet FOREIGN KEY (id_type_billet) REFERENCES type_billet (id_type_billet),
  CONSTRAINT ck_billet_1 CHECK (date_debut_validite >= date_achat),
  CONSTRAINT ck_billet_2 CHECK (prix_paye >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Billet acheté par un visiteur';

CREATE TABLE visite (
  id_visite INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant de la visite',
  date_heure_entree DATETIME NOT NULL COMMENT 'Date et heure d''entrée',
  date_heure_sortie DATETIME NULL COMMENT 'Date et heure de sortie',
  id_billet INT UNSIGNED NOT NULL COMMENT 'Clé étrangère issue de VALIDER',
  CONSTRAINT pk_visite PRIMARY KEY (id_visite),
  CONSTRAINT fk_visite_id_billet FOREIGN KEY (id_billet) REFERENCES billet (id_billet),
  CONSTRAINT ck_visite_1 CHECK (date_heure_sortie IS NULL OR date_heure_sortie >= date_heure_entree)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Passage d''un billet à l''entrée du parc';

CREATE TABLE type_materiel (
  id_type_materiel INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant du type de matériel',
  libelle_type_materiel VARCHAR(40) NOT NULL COMMENT 'Libellé du matériel',
  tarif_journalier DECIMAL(6,2) NOT NULL COMMENT 'Tarif de location par jour (EUR)',
  montant_caution DECIMAL(6,2) NOT NULL COMMENT 'Caution (EUR)',
  CONSTRAINT pk_type_materiel PRIMARY KEY (id_type_materiel),
  CONSTRAINT uq_type_materiel_libelle_type_materiel UNIQUE (libelle_type_materiel),
  CONSTRAINT ck_type_materiel_1 CHECK (tarif_journalier >= 0),
  CONSTRAINT ck_type_materiel_2 CHECK (montant_caution >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Type de matériel louable';

CREATE TABLE materiel (
  id_materiel INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant du matériel',
  numero_inventaire VARCHAR(20) NOT NULL COMMENT 'Numéro d''inventaire',
  etat_materiel ENUM('Disponible','En réparation','Retiré') NOT NULL COMMENT 'État du matériel',
  id_type_materiel INT UNSIGNED NOT NULL COMMENT 'Clé étrangère issue de CATEGORISER',
  CONSTRAINT pk_materiel PRIMARY KEY (id_materiel),
  CONSTRAINT uq_materiel_numero_inventaire UNIQUE (numero_inventaire),
  CONSTRAINT fk_materiel_id_type_materiel FOREIGN KEY (id_type_materiel) REFERENCES type_materiel (id_type_materiel)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Exemplaire physique de poussette ou de chaise roulante';

CREATE TABLE location (
  id_location INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant de la location',
  date_heure_debut_location DATETIME NOT NULL COMMENT 'Date et heure de remise',
  date_heure_retour DATETIME NULL COMMENT 'Date et heure de retour',
  montant_facture DECIMAL(7,2) NOT NULL COMMENT 'Montant facturé (EUR)',
  id_visiteur INT UNSIGNED NOT NULL COMMENT 'Clé étrangère issue de LOUER',
  id_materiel INT UNSIGNED NOT NULL COMMENT 'Clé étrangère issue de CONCERNER',
  id_point_location INT UNSIGNED NOT NULL COMMENT 'Clé étrangère issue de REMETTRE',
  CONSTRAINT pk_location PRIMARY KEY (id_location),
  CONSTRAINT fk_location_id_visiteur FOREIGN KEY (id_visiteur) REFERENCES visiteur (id_visiteur),
  CONSTRAINT fk_location_id_materiel FOREIGN KEY (id_materiel) REFERENCES materiel (id_materiel),
  CONSTRAINT fk_location_id_point_location FOREIGN KEY (id_point_location) REFERENCES infrastructure (id_lieu),
  CONSTRAINT ck_location_1 CHECK (date_heure_retour IS NULL OR date_heure_retour >= date_heure_debut_location),
  CONSTRAINT ck_location_2 CHECK (montant_facture >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Location d''un matériel à un visiteur';

CREATE TABLE membre_junior (
  id_membre INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant du membre',
  numero_carte_junior VARCHAR(20) NOT NULL COMMENT 'Numéro de carte Junior Club',
  date_inscription_junior DATE NOT NULL COMMENT 'Date d''inscription',
  id_visiteur INT UNSIGNED NOT NULL COMMENT 'Clé étrangère issue de AFFILIER',
  id_responsable INT UNSIGNED NOT NULL COMMENT 'Clé étrangère issue de ETRE_RESPONSABLE',
  CONSTRAINT pk_membre_junior PRIMARY KEY (id_membre),
  CONSTRAINT uq_membre_junior_numero_carte_junior UNIQUE (numero_carte_junior),
  CONSTRAINT uq_membre_junior_id_visiteur UNIQUE (id_visiteur),
  CONSTRAINT fk_membre_junior_id_visiteur FOREIGN KEY (id_visiteur) REFERENCES visiteur (id_visiteur),
  CONSTRAINT fk_membre_junior_id_responsable FOREIGN KEY (id_responsable) REFERENCES visiteur (id_visiteur),
  CONSTRAINT ck_membre_junior_1 CHECK (id_visiteur <> id_responsable)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Enfant inscrit au Junior Club';

CREATE TABLE collecte (
  id_collecte INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant de la collecte',
  date_heure_collecte DATETIME NOT NULL COMMENT 'Date et heure de la collecte',
  points_gagnes SMALLINT UNSIGNED NOT NULL COMMENT 'Points gagnés',
  id_membre INT UNSIGNED NOT NULL COMMENT 'Clé étrangère issue de COLLECTER',
  id_lieu INT UNSIGNED NOT NULL COMMENT 'Clé étrangère issue de RAPPORTER',
  CONSTRAINT pk_collecte PRIMARY KEY (id_collecte),
  CONSTRAINT fk_collecte_id_membre FOREIGN KEY (id_membre) REFERENCES membre_junior (id_membre),
  CONSTRAINT fk_collecte_id_lieu FOREIGN KEY (id_lieu) REFERENCES lieu (id_lieu),
  CONSTRAINT ck_collecte_1 CHECK (points_gagnes > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Points gagnés par un membre sur une attraction';

CREATE TABLE goodie (
  id_goodie INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant du goodie',
  nom_goodie VARCHAR(80) NOT NULL COMMENT 'Nom du goodie',
  points_requis SMALLINT UNSIGNED NOT NULL COMMENT 'Points nécessaires',
  stock_goodie INT UNSIGNED NOT NULL COMMENT 'Stock restant',
  CONSTRAINT pk_goodie PRIMARY KEY (id_goodie),
  CONSTRAINT uq_goodie_nom_goodie UNIQUE (nom_goodie),
  CONSTRAINT ck_goodie_1 CHECK (points_requis > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Récompense à débloquer';

CREATE TABLE type_chambre (
  id_type_chambre INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant du type de chambre',
  libelle_type_chambre VARCHAR(50) NOT NULL COMMENT 'Libellé du type',
  capacite_chambre TINYINT UNSIGNED NOT NULL COMMENT 'Nombre maximum de personnes',
  CONSTRAINT pk_type_chambre PRIMARY KEY (id_type_chambre),
  CONSTRAINT uq_type_chambre_libelle_type_chambre UNIQUE (libelle_type_chambre),
  CONSTRAINT ck_type_chambre_1 CHECK (capacite_chambre >= 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Catégorie d''unité louable (chambre, suite, tipi, emplacement caravane ou tente)';

CREATE TABLE chambre (
  id_chambre INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant de la chambre',
  numero_chambre VARCHAR(10) NOT NULL COMMENT 'Numéro de chambre',
  etage TINYINT NULL COMMENT 'Étage',
  id_hotel INT UNSIGNED NOT NULL COMMENT 'Clé étrangère issue de APPARTENIR',
  id_type_chambre INT UNSIGNED NOT NULL COMMENT 'Clé étrangère issue de TYPER_CHAMBRE',
  CONSTRAINT pk_chambre PRIMARY KEY (id_chambre),
  CONSTRAINT uq_chambre_1 UNIQUE (id_hotel, numero_chambre),
  CONSTRAINT fk_chambre_id_hotel FOREIGN KEY (id_hotel) REFERENCES hotel (id_hotel),
  CONSTRAINT fk_chambre_id_type_chambre FOREIGN KEY (id_type_chambre) REFERENCES type_chambre (id_type_chambre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Unité louable d''un hébergement';

CREATE TABLE sejour (
  id_sejour INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identifiant du séjour',
  date_reservation DATE NOT NULL COMMENT 'Date de réservation',
  date_arrivee DATE NOT NULL COMMENT 'Date d''arrivée',
  date_depart DATE NOT NULL COMMENT 'Date de départ',
  nb_adultes TINYINT UNSIGNED NOT NULL COMMENT 'Nombre d''adultes',
  nb_enfants TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Nombre d''enfants',
  statut_sejour ENUM('Réservé','En cours','Terminé','Annulé') NOT NULL COMMENT 'Statut du séjour',
  id_visiteur INT UNSIGNED NOT NULL COMMENT 'Clé étrangère issue de RESERVER',
  CONSTRAINT pk_sejour PRIMARY KEY (id_sejour),
  CONSTRAINT fk_sejour_id_visiteur FOREIGN KEY (id_visiteur) REFERENCES visiteur (id_visiteur),
  CONSTRAINT ck_sejour_1 CHECK (date_depart > date_arrivee),
  CONSTRAINT ck_sejour_2 CHECK (nb_adultes >= 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Réservation d''un séjour';

CREATE TABLE ouvrir (
  id_lieu INT UNSIGNED NOT NULL COMMENT 'Clé étrangère vers LIEU',
  id_periode INT UNSIGNED NOT NULL COMMENT 'Clé étrangère vers PERIODE',
  CONSTRAINT pk_ouvrir PRIMARY KEY (id_lieu, id_periode),
  CONSTRAINT fk_ouvrir_id_lieu FOREIGN KEY (id_lieu) REFERENCES lieu (id_lieu) ON DELETE CASCADE,
  CONSTRAINT fk_ouvrir_id_periode FOREIGN KEY (id_periode) REFERENCES periode (id_periode) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Un lieu est ouvert pendant des périodes';

CREATE TABLE proposer (
  id_infrastructure INT UNSIGNED NOT NULL COMMENT 'Clé étrangère vers INFRASTRUCTURE',
  id_plat INT UNSIGNED NOT NULL COMMENT 'Clé étrangère vers PLAT',
  prix_plat DECIMAL(6,2) NOT NULL COMMENT 'Prix de vente (EUR)',
  CONSTRAINT pk_proposer PRIMARY KEY (id_infrastructure, id_plat),
  CONSTRAINT fk_proposer_id_infrastructure FOREIGN KEY (id_infrastructure) REFERENCES infrastructure (id_lieu) ON DELETE CASCADE,
  CONSTRAINT fk_proposer_id_plat FOREIGN KEY (id_plat) REFERENCES plat (id_plat) ON DELETE CASCADE,
  CONSTRAINT ck_proposer_1 CHECK (prix_plat >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Un point de restauration propose des plats';

CREATE TABLE parler (
  id_employe INT UNSIGNED NOT NULL COMMENT 'Clé étrangère vers EMPLOYE',
  id_langue INT UNSIGNED NOT NULL COMMENT 'Clé étrangère vers LANGUE',
  niveau_langue ENUM('A1','A2','B1','B2','C1','C2','Natif') NOT NULL COMMENT 'Niveau de langue',
  CONSTRAINT pk_parler PRIMARY KEY (id_employe, id_langue),
  CONSTRAINT fk_parler_id_employe FOREIGN KEY (id_employe) REFERENCES employe (id_employe) ON DELETE CASCADE,
  CONSTRAINT fk_parler_id_langue FOREIGN KEY (id_langue) REFERENCES langue (id_langue) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Un employé parle au moins deux langues, dont l''allemand';

CREATE TABLE affecter (
  id_employe INT UNSIGNED NOT NULL COMMENT 'Clé étrangère vers EMPLOYE',
  id_job INT UNSIGNED NOT NULL COMMENT 'Clé étrangère vers JOB',
  id_periode INT UNSIGNED NOT NULL COMMENT 'Clé étrangère vers PERIODE',
  id_lieu INT UNSIGNED NOT NULL COMMENT 'Clé étrangère vers LIEU',
  taux_activite TINYINT UNSIGNED NOT NULL COMMENT 'Taux d''activité (%)',
  CONSTRAINT pk_affecter PRIMARY KEY (id_employe, id_job, id_periode, id_lieu),
  CONSTRAINT fk_affecter_id_employe FOREIGN KEY (id_employe) REFERENCES employe (id_employe) ON DELETE CASCADE,
  CONSTRAINT fk_affecter_id_job FOREIGN KEY (id_job) REFERENCES job (id_job) ON DELETE CASCADE,
  CONSTRAINT fk_affecter_id_periode FOREIGN KEY (id_periode) REFERENCES periode (id_periode) ON DELETE CASCADE,
  CONSTRAINT fk_affecter_id_lieu FOREIGN KEY (id_lieu) REFERENCES lieu (id_lieu) ON DELETE CASCADE,
  CONSTRAINT ck_affecter_1 CHECK (taux_activite BETWEEN 1 AND 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Un employé exerce un job sur un lieu pendant une période';

CREATE TABLE debloquer (
  id_membre INT UNSIGNED NOT NULL COMMENT 'Clé étrangère vers MEMBRE_JUNIOR',
  id_goodie INT UNSIGNED NOT NULL COMMENT 'Clé étrangère vers GOODIE',
  date_deblocage DATETIME NOT NULL COMMENT 'Date de déblocage',
  points_debites SMALLINT UNSIGNED NOT NULL COMMENT 'Points débités',
  CONSTRAINT pk_debloquer PRIMARY KEY (id_membre, id_goodie),
  CONSTRAINT fk_debloquer_id_membre FOREIGN KEY (id_membre) REFERENCES membre_junior (id_membre) ON DELETE CASCADE,
  CONSTRAINT fk_debloquer_id_goodie FOREIGN KEY (id_goodie) REFERENCES goodie (id_goodie) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Un membre débloque des goodies';

CREATE TABLE tarifer (
  id_hotel INT UNSIGNED NOT NULL COMMENT 'Clé étrangère vers HOTEL',
  id_type_chambre INT UNSIGNED NOT NULL COMMENT 'Clé étrangère vers TYPE_CHAMBRE',
  prix_nuit DECIMAL(7,2) NOT NULL COMMENT 'Prix catalogue par nuit (EUR)',
  CONSTRAINT pk_tarifer PRIMARY KEY (id_hotel, id_type_chambre),
  CONSTRAINT fk_tarifer_id_hotel FOREIGN KEY (id_hotel) REFERENCES hotel (id_hotel) ON DELETE CASCADE,
  CONSTRAINT fk_tarifer_id_type_chambre FOREIGN KEY (id_type_chambre) REFERENCES type_chambre (id_type_chambre) ON DELETE CASCADE,
  CONSTRAINT ck_tarifer_1 CHECK (prix_nuit >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Prix d''un type de chambre dans un hébergement';

CREATE TABLE occuper (
  id_sejour INT UNSIGNED NOT NULL COMMENT 'Clé étrangère vers SEJOUR',
  id_chambre INT UNSIGNED NOT NULL COMMENT 'Clé étrangère vers CHAMBRE',
  prix_nuit_applique DECIMAL(7,2) NOT NULL COMMENT 'Prix par nuit appliqué (EUR)',
  CONSTRAINT pk_occuper PRIMARY KEY (id_sejour, id_chambre),
  CONSTRAINT fk_occuper_id_sejour FOREIGN KEY (id_sejour) REFERENCES sejour (id_sejour) ON DELETE CASCADE,
  CONSTRAINT fk_occuper_id_chambre FOREIGN KEY (id_chambre) REFERENCES chambre (id_chambre) ON DELETE CASCADE,
  CONSTRAINT ck_occuper_1 CHECK (prix_nuit_applique >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Un séjour occupe une ou plusieurs chambres';

-- ---------- Vues : données calculées, jamais stockées

CREATE VIEW v_lieu_carte AS
SELECT l.id_lieu, CONCAT(q.code_quartier, ' ', l.numero_carte) AS code_carte, l.nom_lieu, q.nom_quartier
FROM lieu l
JOIN quartier q ON q.id_quartier = l.id_quartier
WHERE l.numero_carte IS NOT NULL;

CREATE VIEW v_employe_non_conforme AS
SELECT e.id_employe, e.nom_employe, e.prenom_employe, COUNT(p.id_langue) AS nb_langues,
       COALESCE(SUM(CASE WHEN l.code_langue = 'DE' THEN 1 ELSE 0 END), 0) AS parle_allemand
FROM employe e
LEFT JOIN parler p ON p.id_employe = e.id_employe
LEFT JOIN langue l ON l.id_langue = p.id_langue
GROUP BY e.id_employe, e.nom_employe, e.prenom_employe
HAVING COUNT(p.id_langue) < 2 OR COALESCE(SUM(CASE WHEN l.code_langue = 'DE' THEN 1 ELSE 0 END), 0) = 0;

CREATE VIEW v_solde_junior AS
SELECT m.id_membre, m.numero_carte_junior,
       COALESCE((SELECT SUM(c.points_gagnes) FROM collecte c WHERE c.id_membre = m.id_membre), 0)
     - COALESCE((SELECT SUM(d.points_debites) FROM debloquer d WHERE d.id_membre = m.id_membre), 0) AS solde_points
FROM membre_junior m;

CREATE VIEW v_seance_quartier AS
SELECT s.id_seance, sp.titre_spectacle, s.date_heure_seance, l.nom_lieu, q.nom_quartier
FROM seance s
JOIN spectacle sp ON sp.id_spectacle = s.id_spectacle
JOIN lieu l ON l.id_lieu = sp.id_infrastructure
LEFT JOIN quartier q ON q.id_quartier = l.id_quartier;

CREATE VIEW v_restauration_typique AS
SELECT DISTINCT l.id_lieu, l.nom_lieu, q.nom_quartier, pl.nom_plat
FROM proposer p
JOIN plat pl ON pl.id_plat = p.id_plat
JOIN lieu l ON l.id_lieu = p.id_infrastructure
JOIN quartier q ON q.id_quartier = l.id_quartier
WHERE pl.id_quartier_typique = l.id_quartier;

-- ---------- Déclencheurs : règles que les cardinalités ne peuvent pas porter

DELIMITER $$

-- RG01 : l'allemand ne peut pas être retiré et il reste toujours au moins 2 langues
CREATE TRIGGER trg_parler_bd BEFORE DELETE ON parler FOR EACH ROW
BEGIN
  DECLARE v_code CHAR(2);
  DECLARE v_nb INT;
  SELECT code_langue INTO v_code FROM langue WHERE id_langue = OLD.id_langue;
  SELECT COUNT(*) INTO v_nb FROM parler WHERE id_employe = OLD.id_employe;
  IF v_code = 'DE' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RG01 : l''allemand est obligatoire pour un employé';
  END IF;
  IF v_nb <= 2 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RG01 : un employé doit parler au moins 2 langues';
  END IF;
END$$

CREATE TRIGGER trg_parler_bu BEFORE UPDATE ON parler FOR EACH ROW
BEGIN
  DECLARE v_code CHAR(2);
  SELECT code_langue INTO v_code FROM langue WHERE id_langue = OLD.id_langue;
  IF v_code = 'DE' AND NEW.id_langue <> OLD.id_langue THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RG01 : l''allemand est obligatoire pour un employé';
  END IF;
END$$

-- RG13 : le Junior Club est réservé aux enfants (limite de 12 ans à confirmer)
CREATE TRIGGER trg_membre_junior_bi BEFORE INSERT ON membre_junior FOR EACH ROW
BEGIN
  DECLARE v_naissance DATE;
  SELECT date_naissance_visiteur INTO v_naissance FROM visiteur WHERE id_visiteur = NEW.id_visiteur;
  IF TIMESTAMPDIFF(YEAR, v_naissance, NEW.date_inscription_junior) > 12 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RG13 : le Junior Club est réservé aux enfants';
  END IF;
END$$

-- RG14 : seuls les lieux du programme (badge JC) rapportent des points
CREATE TRIGGER trg_collecte_bi BEFORE INSERT ON collecte FOR EACH ROW
BEGIN
  DECLARE v_points SMALLINT UNSIGNED;
  SELECT points_junior INTO v_points FROM lieu WHERE id_lieu = NEW.id_lieu;
  IF v_points IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RG14 : ce lieu ne rapporte pas de points';
  END IF;
END$$

-- RG15 : un goodie exige assez de points et un stock positif
CREATE TRIGGER trg_debloquer_bi BEFORE INSERT ON debloquer FOR EACH ROW
BEGIN
  DECLARE v_solde INT;
  DECLARE v_requis INT;
  DECLARE v_stock INT;
  SELECT solde_points INTO v_solde FROM v_solde_junior WHERE id_membre = NEW.id_membre;
  SELECT points_requis, stock_goodie INTO v_requis, v_stock FROM goodie WHERE id_goodie = NEW.id_goodie;
  IF v_solde < v_requis THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RG15 : points insuffisants';
  END IF;
  IF v_stock = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RG15 : goodie en rupture de stock';
  END IF;
  UPDATE goodie SET stock_goodie = stock_goodie - 1 WHERE id_goodie = NEW.id_goodie;
END$$

-- RG11 : un matériel ne peut être loué que s'il est disponible et rendu
CREATE TRIGGER trg_location_bi BEFORE INSERT ON location FOR EACH ROW
BEGIN
  IF (SELECT etat_materiel FROM materiel WHERE id_materiel = NEW.id_materiel) <> 'Disponible' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RG11 : matériel indisponible';
  END IF;
  IF EXISTS (SELECT 1 FROM location WHERE id_materiel = NEW.id_materiel AND date_heure_retour IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RG11 : matériel déjà loué';
  END IF;
END$$

-- RG18 : une chambre ne peut pas être occupée par deux séjours qui se chevauchent
CREATE TRIGGER trg_occuper_bi BEFORE INSERT ON occuper FOR EACH ROW
BEGIN
  DECLARE v_arrivee DATE;
  DECLARE v_depart DATE;
  SELECT date_arrivee, date_depart INTO v_arrivee, v_depart FROM sejour WHERE id_sejour = NEW.id_sejour;
  IF EXISTS (
    SELECT 1 FROM occuper o
    JOIN sejour s ON s.id_sejour = o.id_sejour
    WHERE o.id_chambre = NEW.id_chambre
      AND s.statut_sejour <> 'Annulé'
      AND s.date_arrivee < v_depart
      AND s.date_depart > v_arrivee
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RG18 : chambre déjà occupée sur ces dates';
  END IF;
END$$

DELIMITER ;

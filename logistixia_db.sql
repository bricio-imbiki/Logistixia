
-- BASE DE DONNÉES COMPLÈTE POUR UN SYSTÈME DE GESTION LOGISTIQUE MODERNE

CREATE DATABASE IF NOT EXISTS logistixia_db;
USE logistixia_db;

-- 1. CLIENTS
CREATE TABLE clients (
    client_id INT PRIMARY KEY AUTO_INCREMENT,
    nom_entreprise VARCHAR(100),
    contact VARCHAR(100),
    telephone VARCHAR(20),
    email VARCHAR(100),
    adresse TEXT
);

-- 2. CAMIONS
CREATE TABLE camions (
    camion_id INT PRIMARY KEY AUTO_INCREMENT,
    matricule VARCHAR(20) UNIQUE NOT NULL,
    marque VARCHAR(50),
    modele VARCHAR(50),
    capacite_kg INT,
    statut ENUM('disponible', 'en mission', 'panne', 'maintenance') DEFAULT 'disponible',
    est_interne BOOLEAN DEFAULT TRUE,
    societe_proprietaire VARCHAR(100)
);

-- 3. REMORQUES
CREATE TABLE remorques (
    remorque_id INT PRIMARY KEY AUTO_INCREMENT,
    matricule VARCHAR(20) UNIQUE NOT NULL,
    type VARCHAR(50),
    capacite_max DECIMAL(10,2),
    est_interne BOOLEAN DEFAULT TRUE,
    societe_proprietaire VARCHAR(100),
    camion_id INT,
    FOREIGN KEY (camion_id) REFERENCES camions(camion_id) ON DELETE SET NULL
);

-- 4. CHAUFFEURS
CREATE TABLE chauffeurs (
    chauffeur_id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(50),
    prenom VARCHAR(50),
    telephone VARCHAR(20),
    email VARCHAR(100),
    permis_conduire VARCHAR(50),
    date_embauche DATE,
    date_naissance DATE,
    adresse TEXT,
    photo VARCHAR(255),
    camion_id INT,
    statut ENUM('titulaire', 'remplaçant') DEFAULT 'titulaire'
);

-- 5. ITINÉRAIRES
CREATE TABLE itineraires (
    itineraire_id INT PRIMARY KEY AUTO_INCREMENT,
    lieu_depart VARCHAR(100),
    lieu_arrivee VARCHAR(100),
    distance_km DECIMAL(6,2),
    duree_estimee_hr DECIMAL(5,2)
);

-- 6. TRAJETS (MISSIONS)
CREATE TABLE trajets (
    trajet_id INT PRIMARY KEY AUTO_INCREMENT,
    camion_id INT,
    remorque_id INT,
    chauffeur_id INT,
    itineraire_id INT,
    date_depart DATETIME,
    date_arrivee_estimee DATETIME,
    date_arrivee_reelle DATETIME,
    statut ENUM('prévu', 'en cours', 'terminé', 'annulé') DEFAULT 'prévu',
    commentaire TEXT,
    FOREIGN KEY (camion_id) REFERENCES camions(camion_id),
    FOREIGN KEY (remorque_id) REFERENCES remorques(remorque_id),
    FOREIGN KEY (chauffeur_id) REFERENCES chauffeurs(chauffeur_id),
    FOREIGN KEY (itineraire_id) REFERENCES itineraires(itineraire_id)
);

-- 7. MARCHANDISES (PAR CLIENT ET PAR TRAJET)
CREATE TABLE marchandises (
    marchandise_id INT PRIMARY KEY AUTO_INCREMENT,
    trajet_id INT,
    client_id INT,
    description TEXT,
    poids_kg DECIMAL(10,2),
    valeur_estimee DECIMAL(12,2),
    lieu_livraison VARCHAR(100),
    statut_livraison ENUM('chargée', 'en transit', 'livrée') DEFAULT 'chargée',
    FOREIGN KEY (trajet_id) REFERENCES trajets(trajet_id),
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

-- 8. GPS TRACKING EN TEMPS RÉEL
CREATE TABLE gps_tracking (
    tracking_id INT PRIMARY KEY AUTO_INCREMENT,
    camion_id INT,
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    vitesse_kmh DECIMAL(6,2),
    date_heure DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (camion_id) REFERENCES camions(camion_id)
);

-- 9. PIÈCES DÉTACHÉES POUR MAINTENANCE
CREATE TABLE pieces (
    piece_id INT PRIMARY KEY AUTO_INCREMENT,
    nom_piece VARCHAR(100),
    quantite_stock INT DEFAULT 0,
    prix_achat DECIMAL(10,2),
    seuil_alerte INT DEFAULT 5
);

-- 10. MOUVEMENTS DE STOCK DE PIÈCES
CREATE TABLE mouvements_stock (
    mouvement_id INT PRIMARY KEY AUTO_INCREMENT,
    piece_id INT,
    date_mouvement DATE,
    type_mouvement ENUM('entrée', 'sortie'),
    quantite INT,
    description TEXT,
    FOREIGN KEY (piece_id) REFERENCES pieces(piece_id)
);

-- 11. DÉPENSES PAR TRAJET OU CAMION
CREATE TABLE depenses (
    depense_id INT PRIMARY KEY AUTO_INCREMENT,
    camion_id INT,
    trajet_id INT,
    type_depense ENUM('carburant', 'réparation', 'péage', 'salaire', 'autre'),
    montant DECIMAL(10,2),
    date DATE,
    description TEXT,
    FOREIGN KEY (camion_id) REFERENCES camions(camion_id),
    FOREIGN KEY (trajet_id) REFERENCES trajets(trajet_id)
);

-- 12. REVENUS PAR MARCHANDISE OU CLIENT
CREATE TABLE revenus (
    revenu_id INT PRIMARY KEY AUTO_INCREMENT,
    marchandise_id INT,
    montant DECIMAL(10,2),
    date_reception DATE,
    description TEXT,
    FOREIGN KEY (marchandise_id) REFERENCES marchandises(marchandise_id)
);

-- 13. UTILISATEURS DU SYSTÈME
CREATE TABLE utilisateurs (
    utilisateur_id INT PRIMARY KEY AUTO_INCREMENT,
    nom_utilisateur VARCHAR(50) UNIQUE NOT NULL,
    mot_de_passe VARCHAR(255) NOT NULL,
    role ENUM('admin', 'operateur', 'gestionnaire_stock') NOT NULL
);

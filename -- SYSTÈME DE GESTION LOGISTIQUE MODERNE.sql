-- SYSTÈME DE GESTION LOGISTIQUE MODERNE - CONFORME AUX NORMES SECTEUR
-- Optimisé pour la traçabilité, conformité réglementaire et performance

CREATE DATABASE IF NOT EXISTS logistique_transport_pro;
USE logistique_transport_pro;

-- ==============================================================================
-- 1. GESTION DES ENTITÉS JURIDIQUES ET PARTENAIRES
-- ==============================================================================

-- Types d'entités pour classification
CREATE TABLE types_entites (
    type_entite_id INT PRIMARY KEY AUTO_INCREMENT,
    code_type VARCHAR(10) UNIQUE NOT NULL,
    libelle VARCHAR(50) NOT NULL,
    description TEXT
);

-- Clients, fournisseurs, sous-traitants unifiés
CREATE TABLE partenaires (
    partenaire_id INT PRIMARY KEY AUTO_INCREMENT,
    code_partenaire VARCHAR(20) UNIQUE NOT NULL,
    type_entite_id INT NOT NULL,
    raison_sociale VARCHAR(150) NOT NULL,
    siret VARCHAR(14),
    numero_tva VARCHAR(20),
    
    -- Contact principal
    contact_principal VARCHAR(100),
    telephone_principal VARCHAR(20),
    email_principal VARCHAR(100),
    
    -- Adresse siège social
    adresse_ligne1 VARCHAR(100),
    adresse_ligne2 VARCHAR(100),
    code_postal VARCHAR(10),
    ville VARCHAR(50),
    pays VARCHAR(50) DEFAULT 'France',
    
    -- Informations commerciales
    conditions_paiement VARCHAR(50),
    delai_paiement_jours INT DEFAULT 30,
    limite_credit DECIMAL(12,2),
    
    -- Statut et dates
    statut ENUM('actif', 'suspendu', 'inactif') DEFAULT 'actif',
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (type_entite_id) REFERENCES types_entites(type_entite_id),
    INDEX idx_code_partenaire (code_partenaire),
    INDEX idx_siret (siret),
    INDEX idx_statut (statut)
);

-- Contacts multiples par partenaire
CREATE TABLE contacts_partenaires (
    contact_id INT PRIMARY KEY AUTO_INCREMENT,
    partenaire_id INT NOT NULL,
    civilite ENUM('M.', 'Mme', 'Dr.') DEFAULT 'M.',
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50),
    fonction VARCHAR(50),
    telephone VARCHAR(20),
    email VARCHAR(100),
    est_principal BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (partenaire_id) REFERENCES partenaires(partenaire_id) ON DELETE CASCADE
);

-- ==============================================================================
-- 2. GESTION DE LA FLOTTE OPTIMISÉE
-- ==============================================================================

-- Catégories de véhicules selon normes européennes
CREATE TABLE categories_vehicules (
    categorie_id INT PRIMARY KEY AUTO_INCREMENT,
    code_categorie VARCHAR(10) UNIQUE NOT NULL, -- N1, N2, N3, O1, O2, O3, O4
    libelle VARCHAR(50) NOT NULL,
    description TEXT,
    poids_min_kg INT,
    poids_max_kg INT
);

-- Véhicules tracteurs
CREATE TABLE vehicules (
    vehicule_id INT PRIMARY KEY AUTO_INCREMENT,
    immatriculation VARCHAR(15) UNIQUE NOT NULL,
    numero_chassis VARCHAR(50) UNIQUE,
    categorie_id INT NOT NULL,
    
    -- Identification technique
    marque VARCHAR(50) NOT NULL,
    modele VARCHAR(50) NOT NULL,
    annee_fabrication YEAR,
    puissance_cv INT,
    cylindree_cm3 INT,
    
    -- Capacités et limites
    poids_vide_kg INT,
    ptac_kg INT, -- Poids Total Autorisé en Charge
    charge_utile_kg INT,
    
    -- Propriété et statut
    proprietaire ENUM('interne', 'externe', 'location') DEFAULT 'interne',
    partenaire_proprietaire_id INT,
    statut_operationnel ENUM('disponible', 'en_mission', 'maintenance', 'panne', 'controle_technique', 'reforme') DEFAULT 'disponible',
    
    -- Conformité réglementaire
    date_mise_service DATE,
    date_derniere_revision DATE,
    date_prochaine_revision DATE,
    date_controle_technique DATE,
    date_prochain_controle DATE,
    
    -- Économie et environnement
    consommation_l_100km DECIMAL(4,2),
    norme_emission VARCHAR(10), -- Euro 6, etc.
    co2_g_km INT,
    
    -- Suivi
    kilometrage_actuel INT DEFAULT 0,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (categorie_id) REFERENCES categories_vehicules(categorie_id),
    FOREIGN KEY (partenaire_proprietaire_id) REFERENCES partenaires(partenaire_id),
    INDEX idx_immatriculation (immatriculation),
    INDEX idx_statut (statut_operationnel),
    INDEX idx_proprietaire (proprietaire)
);

-- Semi-remorques et remorques
CREATE TABLE remorques (
    remorque_id INT PRIMARY KEY AUTO_INCREMENT,
    immatriculation VARCHAR(15) UNIQUE NOT NULL,
    numero_chassis VARCHAR(50) UNIQUE,
    categorie_id INT NOT NULL,
    
    -- Type selon ADR si applicable
    type_remorque ENUM('plateau', 'bache', 'frigorifique', 'citerne', 'porte_conteneur', 'autre') NOT NULL,
    
    -- Capacités
    poids_vide_kg INT,
    ptac_kg INT,
    charge_utile_kg INT,
    volume_m3 DECIMAL(6,2),
    
    -- Spécifications techniques
    longueur_m DECIMAL(4,2),
    largeur_m DECIMAL(4,2),
    hauteur_m DECIMAL(4,2),
    nb_essieux INT DEFAULT 2,
    
    -- Équipements spéciaux
    hayon_elevateur BOOLEAN DEFAULT FALSE,
    temperature_min_celsius INT,
    temperature_max_celsius INT,
    
    -- Propriété et statut
    proprietaire ENUM('interne', 'externe', 'location') DEFAULT 'interne',
    partenaire_proprietaire_id INT,
    statut_operationnel ENUM('disponible', 'en_mission', 'maintenance', 'panne', 'controle_technique', 'reforme') DEFAULT 'disponible',
    
    -- Conformité
    date_mise_service DATE,
    date_controle_technique DATE,
    date_prochain_controle DATE,
    
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (categorie_id) REFERENCES categories_vehicules(categorie_id),
    FOREIGN KEY (partenaire_proprietaire_id) REFERENCES partenaires(partenaire_id),
    INDEX idx_immatriculation_remorque (immatriculation),
    INDEX idx_type (type_remorque),
    INDEX idx_statut_remorque (statut_operationnel)
);

-- Attelages véhicule-remorque
CREATE TABLE attelages (
    attelage_id INT PRIMARY KEY AUTO_INCREMENT,
    vehicule_id INT NOT NULL,
    remorque_id INT NOT NULL,
    date_debut DATETIME NOT NULL,
    date_fin DATETIME,
    est_actif BOOLEAN DEFAULT TRUE,
    
    FOREIGN KEY (vehicule_id) REFERENCES vehicules(vehicule_id),
    FOREIGN KEY (remorque_id) REFERENCES remorques(remorque_id),
    INDEX idx_vehicule (vehicule_id),
    INDEX idx_remorque (remorque_id),
    INDEX idx_actif (est_actif)
);

-- ==============================================================================
-- 3. GESTION DES CONDUCTEURS ET PERSONNEL
-- ==============================================================================

-- Conducteurs avec conformité réglementaire
CREATE TABLE conducteurs (
    conducteur_id INT PRIMARY KEY AUTO_INCREMENT,
    numero_employe VARCHAR(20) UNIQUE,
    
    -- Identité
    civilite ENUM('M.', 'Mme') DEFAULT 'M.',
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    date_naissance DATE,
    lieu_naissance VARCHAR(100),
    
    -- Contact
    telephone_mobile VARCHAR(20),
    telephone_fixe VARCHAR(20),
    email VARCHAR(100),
    
    -- Adresse
    adresse_ligne1 VARCHAR(100),
    adresse_ligne2 VARCHAR(100),
    code_postal VARCHAR(10),
    ville VARCHAR(50),
    pays VARCHAR(50) DEFAULT 'France',
    
    -- Permis et qualifications
    numero_permis VARCHAR(20) UNIQUE NOT NULL,
    categories_permis VARCHAR(20) NOT NULL, -- B, C, CE, D, etc.
    date_obtention_permis DATE,
    date_expiration_permis DATE,
    
    -- Formations spécialisées
    fimo BOOLEAN DEFAULT FALSE, -- Formation Initiale Minimale Obligatoire
    fco BOOLEAN DEFAULT FALSE,  -- Formation Continue Obligatoire
    date_fimo DATE,
    date_fco DATE,
    date_prochaine_fco DATE,
    
    -- ADR (matières dangereuses)
    adr_base BOOLEAN DEFAULT FALSE,
    adr_citerne BOOLEAN DEFAULT FALSE,
    adr_explosifs BOOLEAN DEFAULT FALSE,
    adr_radioactifs BOOLEAN DEFAULT FALSE,
    date_expiration_adr DATE,
    
    -- Statut professionnel
    type_contrat ENUM('cdi', 'cdd', 'interim', 'independant') DEFAULT 'cdi',
    statut_activite ENUM('actif', 'conge', 'arret_maladie', 'formation', 'suspendu', 'inactif') DEFAULT 'actif',
    
    -- Temps de travail et repos
    temps_conduite_semaine INT DEFAULT 0, -- en minutes
    temps_repos_journalier_restant INT DEFAULT 660, -- 11h en minutes
    derniere_pause_45min DATETIME,
    
    date_embauche DATE,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_numero_employe (numero_employe),
    INDEX idx_numero_permis (numero_permis),
    INDEX idx_statut (statut_activite),
    INDEX idx_nom_prenom (nom, prenom)
);

-- Affectations conducteur-véhicule
CREATE TABLE affectations_vehicules (
    affectation_id INT PRIMARY KEY AUTO_INCREMENT,
    conducteur_id INT NOT NULL,
    vehicule_id INT NOT NULL,
    date_debut DATETIME NOT NULL,
    date_fin DATETIME,
    est_conducteur_principal BOOLEAN DEFAULT TRUE,
    
    FOREIGN KEY (conducteur_id) REFERENCES conducteurs(conducteur_id),
    FOREIGN KEY (vehicule_id) REFERENCES vehicules(vehicule_id),
    INDEX idx_conducteur (conducteur_id),
    INDEX idx_vehicule (vehicule_id)
);

-- ==============================================================================
-- 4. GESTION DES ORDRES DE TRANSPORT ET EXPÉDITIONS
-- ==============================================================================

-- Ordres de transport (équivalent commande)
CREATE TABLE ordres_transport (
    ordre_id INT PRIMARY KEY AUTO_INCREMENT,
    numero_ordre VARCHAR(20) UNIQUE NOT NULL,
    partenaire_client_id INT NOT NULL,
    partenaire_facture_id INT, -- Peut être différent du client
    
    -- Dates et délais
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_demande_enlevement DATETIME,
    date_livraison_souhaitee DATETIME,
    date_limite_livraison DATETIME,
    
    -- Origine et destination
    adresse_enlevement_ligne1 VARCHAR(100),
    adresse_enlevement_ligne2 VARCHAR(100),
    code_postal_enlevement VARCHAR(10),
    ville_enlevement VARCHAR(50),
    pays_enlevement VARCHAR(50) DEFAULT 'France',
    
    adresse_livraison_ligne1 VARCHAR(100),
    adresse_livraison_ligne2 VARCHAR(100),
    code_postal_livraison VARCHAR(10),
    ville_livraison VARCHAR(50),
    pays_livraison VARCHAR(50) DEFAULT 'France',
    
    -- Informations commerciales
    prix_transport_ht DECIMAL(10,2),
    taux_tva DECIMAL(5,2) DEFAULT 20.00,
    prix_transport_ttc DECIMAL(10,2),
    
    -- Statut et priorité
    statut ENUM('brouillon', 'confirme', 'planifie', 'en_cours', 'livre', 'facture', 'annule') DEFAULT 'brouillon',
    priorite ENUM('normale', 'urgente', 'critique') DEFAULT 'normale',
    
    -- Instructions spéciales
    instructions_enlevement TEXT,
    instructions_livraison TEXT,
    commentaires TEXT,
    
    date_modification DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (partenaire_client_id) REFERENCES partenaires(partenaire_id),
    FOREIGN KEY (partenaire_facture_id) REFERENCES partenaires(partenaire_id),
    INDEX idx_numero_ordre (numero_ordre),
    INDEX idx_client (partenaire_client_id),
    INDEX idx_statut_ordre (statut),
    INDEX idx_date_enlevement (date_demande_enlevement)
);

-- Lignes d'expédition (détail des marchandises)
CREATE TABLE expeditions (
    expedition_id INT PRIMARY KEY AUTO_INCREMENT,
    ordre_id INT NOT NULL,
    ligne_numero INT NOT NULL,
    
    -- Description marchandise
    description_marchandise TEXT NOT NULL,
    code_marchandise VARCHAR(20),
    quantite DECIMAL(10,2) NOT NULL,
    unite_mesure VARCHAR(10) DEFAULT 'kg',
    
    -- Poids et dimensions
    poids_brut_kg DECIMAL(10,2),
    poids_net_kg DECIMAL(10,2),
    volume_m3 DECIMAL(8,3),
    longueur_cm INT,
    largeur_cm INT,
    hauteur_cm INT,
    
    -- Valeur et assurance
    valeur_declaree DECIMAL(12,2),
    valeur_assurance DECIMAL(12,2),
    
    -- Conditionnement
    type_conditionnement ENUM('palette', 'carton', 'vrac', 'conteneur', 'autre') DEFAULT 'palette',
    nombre_colis INT DEFAULT 1,
    
    -- Contraintes transport
    fragile BOOLEAN DEFAULT FALSE,
    dangereux BOOLEAN DEFAULT FALSE,
    classe_adr VARCHAR(10), -- Si matière dangereuse
    temperature_min_celsius INT,
    temperature_max_celsius INT,
    
    -- Statut ligne
    statut ENUM('planifie', 'enleve', 'en_transit', 'livre', 'refuse') DEFAULT 'planifie',
    
    FOREIGN KEY (ordre_id) REFERENCES ordres_transport(ordre_id) ON DELETE CASCADE,
    INDEX idx_ordre (ordre_id),
    INDEX idx_statut_expedition (statut),
    UNIQUE KEY uk_ordre_ligne (ordre_id, ligne_numero)
);

-- ==============================================================================
-- 5. PLANIFICATION ET EXÉCUTION DES TOURNÉES
-- ==============================================================================

-- Tournées planifiées
CREATE TABLE tournees (
    tournee_id INT PRIMARY KEY AUTO_INCREMENT,
    numero_tournee VARCHAR(20) UNIQUE NOT NULL,
    
    date_tournee DATE NOT NULL,
    heure_debut_prevue TIME,
    heure_fin_prevue TIME,
    heure_debut_reelle TIME,
    heure_fin_reelle TIME,
    
    -- Affectation ressources
    vehicule_id INT NOT NULL,
    remorque_id INT,
    conducteur_principal_id INT NOT NULL,
    conducteur_secondaire_id INT,
    
    -- Kilométrage
    km_debut INT,
    km_fin INT,
    km_total_calcule INT,
    
    -- Statut
    statut ENUM('planifiee', 'en_cours', 'terminee', 'annulee') DEFAULT 'planifiee',
    
    -- Coûts prévisionnels
    cout_carburant_prevu DECIMAL(8,2),
    cout_peage_prevu DECIMAL(8,2),
    cout_total_prevu DECIMAL(10,2),
    
    commentaires TEXT,
    
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (vehicule_id) REFERENCES vehicules(vehicule_id),
    FOREIGN KEY (remorque_id) REFERENCES remorques(remorque_id),
    FOREIGN KEY (conducteur_principal_id) REFERENCES conducteurs(conducteur_id),
    FOREIGN KEY (conducteur_secondaire_id) REFERENCES conducteurs(conducteur_id),
    INDEX idx_numero_tournee (numero_tournee),
    INDEX idx_date_tournee (date_tournee),
    INDEX idx_vehicule_tournee (vehicule_id),
    INDEX idx_conducteur (conducteur_principal_id),
    INDEX idx_statut_tournee (statut)
);

-- Étapes de tournée (enlèvements et livraisons)
CREATE TABLE etapes_tournee (
    etape_id INT PRIMARY KEY AUTO_INCREMENT,
    tournee_id INT NOT NULL,
    ordre_id INT NOT NULL,
    
    -- Séquence
    numero_etape INT NOT NULL,
    type_etape ENUM('enlevement', 'livraison') NOT NULL,
    
    -- Horaires
    heure_arrivee_prevue TIME,
    heure_depart_prevue TIME,
    heure_arrivee_reelle TIME,
    heure_depart_reelle TIME,
    duree_stationnement_min INT,
    
    -- Adresse (peut être différente de l'ordre)
    adresse_ligne1 VARCHAR(100),
    adresse_ligne2 VARCHAR(100),
    code_postal VARCHAR(10),
    ville VARCHAR(50),
    pays VARCHAR(50) DEFAULT 'France',
    
    -- Coordonnées GPS
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    
    -- Statut étape
    statut ENUM('planifiee', 'en_cours', 'terminee', 'echec', 'reportee') DEFAULT 'planifiee',
    
    -- Remarques
    instructions TEXT,
    compte_rendu TEXT,
    
    FOREIGN KEY (tournee_id) REFERENCES tournees(tournee_id) ON DELETE CASCADE,
    FOREIGN KEY (ordre_id) REFERENCES ordres_transport(ordre_id),
    INDEX idx_tournee (tournee_id),
    INDEX idx_ordre_etape (ordre_id),
    INDEX idx_numero_etape (numero_etape),
    UNIQUE KEY uk_tournee_etape (tournee_id, numero_etape)
);

-- ==============================================================================
-- 6. SUIVI TEMPS RÉEL ET TÉLÉMATIQUE
-- ==============================================================================

-- Positions GPS historiques
CREATE TABLE positions_gps (
    position_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    vehicule_id INT NOT NULL,
    tournee_id INT,
    
    -- Coordonnées
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    altitude_m INT,
    
    -- Données véhicule
    vitesse_kmh DECIMAL(5,2),
    cap_degres INT,
    kilometrage INT,
    niveau_carburant_pct INT,
    
    -- Horodatage
    timestamp_gps DATETIME NOT NULL,
    timestamp_reception DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    -- Statut conducteur
    moteur_allume BOOLEAN DEFAULT FALSE,
    en_conduite BOOLEAN DEFAULT FALSE,
    
    FOREIGN KEY (vehicule_id) REFERENCES vehicules(vehicule_id),
    FOREIGN KEY (tournee_id) REFERENCES tournees(tournee_id),
    INDEX idx_vehicule_gps (vehicule_id),
    INDEX idx_timestamp (timestamp_gps),
    INDEX idx_tournee_gps (tournee_id)
);

-- Événements de conduite (freinages, accélérations, etc.)
CREATE TABLE evenements_conduite (
    evenement_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    vehicule_id INT NOT NULL,
    conducteur_id INT,
    tournee_id INT,
    
    type_evenement ENUM('freinage_brutal', 'acceleration_forte', 'virage_serre', 'exces_vitesse', 'ralenti_excessif') NOT NULL,
    severite ENUM('faible', 'moyenne', 'forte') DEFAULT 'moyenne',
    
    -- Localisation
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    adresse_approximative VARCHAR(200),
    
    -- Données techniques
    vitesse_kmh DECIMAL(5,2),
    acceleration_g DECIMAL(4,2),
    
    timestamp_evenement DATETIME NOT NULL,
    timestamp_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (vehicule_id) REFERENCES vehicules(vehicule_id),
    FOREIGN KEY (conducteur_id) REFERENCES conducteurs(conducteur_id),
    FOREIGN KEY (tournee_id) REFERENCES tournees(tournee_id),
    INDEX idx_vehicule_evenement (vehicule_id),
    INDEX idx_type_evenement (type_evenement),
    INDEX idx_timestamp_evenement (timestamp_evenement)
);

-- ==============================================================================
-- 7. GESTION FINANCIÈRE ET COMPTABILITÉ
-- ==============================================================================

-- Postes comptables
CREATE TABLE postes_comptables (
    poste_id INT PRIMARY KEY AUTO_INCREMENT,
    code_poste VARCHAR(10) UNIQUE NOT NULL,
    libelle VARCHAR(100) NOT NULL,
    type_poste ENUM('charge', 'produit') NOT NULL,
    categorie VARCHAR(50),
    description TEXT
);

-- Dépenses (charges d'exploitation)
CREATE TABLE depenses (
    depense_id INT PRIMARY KEY AUTO_INCREMENT,
    numero_piece VARCHAR(20) UNIQUE NOT NULL,
    
    -- Classification
    poste_comptable_id INT NOT NULL,
    partenaire_fournisseur_id INT,
    
    -- Affectation
    vehicule_id INT,
    remorque_id INT,
    tournee_id INT,
    conducteur_id INT,
    
    -- Montants
    montant_ht DECIMAL(10,2) NOT NULL,
    taux_tva DECIMAL(5,2) DEFAULT 20.00,
    montant_tva DECIMAL(10,2),
    montant_ttc DECIMAL(10,2),
    
    -- Dates
    date_operation DATE NOT NULL,
    date_saisie DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    -- Détails
    description TEXT,
    justificatif_url VARCHAR(255),
    
    -- Statut
    statut ENUM('brouillon', 'validee', 'comptabilisee', 'annulee') DEFAULT 'brouillon',
    
    FOREIGN KEY (poste_comptable_id) REFERENCES postes_comptables(poste_id),
    FOREIGN KEY (partenaire_fournisseur_id) REFERENCES partenaires(partenaire_id),
    FOREIGN KEY (vehicule_id) REFERENCES vehicules(vehicule_id),
    FOREIGN KEY (remorque_id) REFERENCES remorques(remorque_id),
    FOREIGN KEY (tournee_id) REFERENCES tournees(tournee_id),
    FOREIGN KEY (conducteur_id) REFERENCES conducteurs(conducteur_id),
    INDEX idx_numero_piece (numero_piece),
    INDEX idx_date_operation (date_operation),
    INDEX idx_vehicule_depense (vehicule_id),
    INDEX idx_poste (poste_comptable_id)
);

-- Revenus (produits d'exploitation)
CREATE TABLE revenus (
    revenu_id INT PRIMARY KEY AUTO_INCREMENT,
    numero_facture VARCHAR(20) UNIQUE NOT NULL,
    
    -- Client
    partenaire_client_id INT NOT NULL,
    ordre_id INT,
    
    -- Montants
    montant_ht DECIMAL(10,2) NOT NULL,
    taux_tva DECIMAL(5,2) DEFAULT 20.00,
    montant_tva DECIMAL(10,2),
    montant_ttc DECIMAL(10,2),
    
    -- Dates
    date_facture DATE NOT NULL,
    date_echeance DATE,
    date_reglement DATE,
    
    -- Statut
    statut ENUM('brouillon', 'emise', 'envoyee', 'payee', 'impayee', 'annulee') DEFAULT 'brouillon',
    
    description TEXT,
    
    FOREIGN KEY (partenaire_client_id) REFERENCES partenaires(partenaire_id),
    FOREIGN KEY (ordre_id) REFERENCES ordres_transport(ordre_id),
    INDEX idx_numero_facture (numero_facture),
    INDEX idx_client_revenu (partenaire_client_id),
    INDEX idx_date_facture (date_facture),
    INDEX idx_statut_revenu (statut)
);

-- ==============================================================================
-- 8. MAINTENANCE ET GESTION DES PIÈCES
-- ==============================================================================

-- Catégories de pièces
CREATE TABLE categories_pieces (
    categorie_piece_id INT PRIMARY KEY AUTO_INCREMENT,
    code_categorie VARCHAR(10) UNIQUE NOT NULL,
    libelle VARCHAR(100) NOT NULL,
    description TEXT
);

-- Pièces détachées
CREATE TABLE pieces_detachees (
    piece_id INT PRIMARY KEY AUTO_INCREMENT,
    reference_piece VARCHAR(30) UNIQUE NOT NULL,
    reference_constructeur VARCHAR(30),
    categorie_piece_id INT NOT NULL,
    
    designation VARCHAR(200) NOT NULL,
    description TEXT,
    
    -- Compatibilité
    marque_vehicule VARCHAR(50),
    modele_vehicule VARCHAR(50),
    
    -- Gestion stock
    stock_actuel INT DEFAULT 0,
    stock_minimum INT DEFAULT 0,
    stock_maximum INT DEFAULT 100,
    
    -- Coûts
    prix_achat_unitaire DECIMAL(8,2),
    prix_vente_unitaire DECIMAL(8,2),
    
    -- Fournisseur principal
    partenaire_fournisseur_id INT,
    
    -- Statut
    actif BOOLEAN DEFAULT TRUE,
    
    FOREIGN KEY (categorie_piece_id) REFERENCES categories_pieces(categorie_piece_id),
    FOREIGN KEY (partenaire_fournisseur_id) REFERENCES partenaires(partenaire_id),
    INDEX idx_reference (reference_piece),
    INDEX idx_categorie (categorie_piece_id),
    INDEX idx_stock (stock_actuel)
);

-- Mouvements de stock
CREATE TABLE mouvements_stock (
    mouvement_id INT PRIMARY KEY AUTO_INCREMENT,
    piece_id INT NOT NULL,
    
    type_mouvement ENUM('entree', 'sortie', 'ajustement', 'inventaire') NOT NULL,
    quantite INT NOT NULL,
    
    -- Avant/après
    stock_avant INT,
    stock_apres INT,
    
    -- Coût unitaire au moment du mouvement
    cout_unitaire DECIMAL(8,2),
    
    -- Dates
    date_mouvement DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    -- Origine du mouvement
    reference_document VARCHAR(50), -- Bon de réception, bon de sortie, etc.
    vehicule_id INT, -- Si sortie pour réparation
    
    commentaire TEXT,
    
    FOREIGN KEY (piece_id) REFERENCES pieces_detachees(piece_id),
    FOREIGN KEY (vehicule_id) REFERENCES vehicules(vehicule_id),
    INDEX idx_piece (piece_id),
    INDEX idx_date_mouvement (date_mouvement),
    INDEX idx_type_mouvement (type_mouvement)
);

-- Interventions de maintenance
CREATE TABLE interventions_maintenance (
    intervention_id INT PRIMARY KEY AUTO_INCREMENT,
    numero_intervention VARCHAR(20) UNIQUE NOT NULL,
    
    -- Véhicule concerné
    vehicule_id INT,
    remorque_id INT,
    
    -- Type d'intervention
    type_intervention ENUM('preventive', 'corrective', 'controle_reglementaire', 'reparation') NOT NULL,
    
    -- Dates
    date_demande DATE NOT NULL,
    date_intervention DATE,
    date_fin_intervention DATE,
    
    -- Prestataire
    partenaire_prestataire_id INT,
    interne BOOLEAN DEFAULT TRUE,
    
    -- Kilométrage
    kilometrage_intervention INT,
    
    -- Description
    description_probleme TEXT,
    description_intervention TEXT,
    
    -- Coûts
    cout_main_oeuvre DECIMAL(8,2),
    cout_pieces DECIMAL(8,2),
    cout_total DECIMAL(10,2),
    
    -- Statut
    statut ENUM('demandee', 'planifiee', 'en_cours', 'terminee', 'annulee') DEFAULT 'demandee',
    
    FOREIGN KEY (vehicule_id) REFERENCES vehicules(vehicule_id),
    FOREIGN KEY (remorque_id) REFERENCES remorques(remorque_id),
    FOREIGN KEY (partenaire_prestataire_id) REFERENCES partenaires(partenaire_id),
    INDEX idx_numero_intervention (numero_intervention),
    INDEX idx_vehicule_maintenance (vehicule_id),
    INDEX idx_date_intervention (date_intervention),
    INDEX idx_type_intervention (type_intervention)
);

-- Pièces utilisées dans les interventions
CREATE TABLE pieces_utilisees (
    utilisation_id INT PRIMARY KEY AUTO_INCREMENT,
    intervention_id INT NOT NULL,
    piece_id INT NOT NULL,
    quantite_utilisee INT NOT NULL,
    cout_unitaire DECIMAL(8,2),
    
    FOREIGN KEY (intervention_id) REFERENCES interventions_maintenance(intervention_id) ON DELETE CASCADE,
    FOREIGN KEY (piece_id) REFERENCES pieces_detachees(piece_id),
    INDEX idx_intervention (intervention_id),
    INDEX idx_piece_utilisee (piece_id)
);

-- ==============================================================================
-- 9. GESTION DES DOCUMENTS ET CONFORMITÉ
-- ==============================================================================

-- Types de documents
CREATE TABLE types_documents (
    type_document_id INT PRIMARY KEY AUTO_INCREMENT,
    code_type VARCHAR(20) UNIQUE NOT NULL,
    libelle VARCHAR(100) NOT NULL,
    description TEXT,
    obligatoire BOOLEAN DEFAULT FALSE,
    duree_validite_mois INT -- NULL si pas de durée limite
);

-- Documents des véhicules, conducteurs, partenaires
CREATE TABLE documents (
    document_id INT PRIMARY KEY AUTO_INCREMENT,
    type_document_id INT NOT NULL,
    
    -- Entité concernée (un seul sera rempli)
    vehicule_id INT,
    remorque_id INT,
    conducteur_id INT,
    partenaire_id INT,
    
    numero_document VARCHAR(50),
    date_emission DATE,
    date_expiration DATE,
    
    -- Organisme émetteur
    organisme_emetteur VARCHAR(100),
    
    -- Stockage fichier
    nom_fichier VARCHAR(255),
    chemin_fichier VARCHAR(500),
    taille_fichier_ko INT,
    
    -- Statut
    statut ENUM('valide', 'expire', 'a_renouveler', 'suspendu') DEFAULT 'valide',
    
    -- Alertes
    alerte_expiration_jours INT DEFAULT 30,
    
    commentaires TEXT,
    
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (type_document_id) REFERENCES types_documents(type_document_id),
    FOREIGN KEY (vehicule_id) REFERENCES vehicules(vehicule_id),
    FOREIGN KEY (remorque_id) REFERENCES remorques(remorque_id),
    FOREIGN KEY (conducteur_id) REFERENCES conducteurs(conducteur_id),
    FOREIGN KEY (partenaire_id) REFERENCES partenaires(partenaire_id),
    INDEX idx_type_document (type_document_id),
    INDEX idx_vehicule_doc (vehicule_id),
    INDEX idx_conducteur_doc (conducteur_id),
    INDEX idx_date_expiration (date_expiration),
    INDEX idx_statut_doc (statut)
);

-- ==============================================================================
-- 10. GESTION DES ALERTES ET NOTIFICATIONS
-- ==============================================================================

-- Configuration des alertes
CREATE TABLE types_alertes (
    type_alerte_id INT PRIMARY KEY AUTO_INCREMENT,
    code_alerte VARCHAR(20) UNIQUE NOT NULL,
    libelle VARCHAR(100) NOT NULL,
    description TEXT,
    niveau_urgence ENUM('info', 'attention', 'urgent', 'critique') DEFAULT 'info',
    actif BOOLEAN DEFAULT TRUE
);

-- Alertes générées
CREATE TABLE alertes (
    alerte_id INT PRIMARY KEY AUTO_INCREMENT,
    type_alerte_id INT NOT NULL,
    
    -- Entité concernée
    vehicule_id INT,
    remorque_id INT,
    conducteur_id INT,
    partenaire_id INT,
    tournee_id INT,
    ordre_id INT,
    
    titre VARCHAR(200) NOT NULL,
    message TEXT,
    
    -- Dates
    date_detection DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_echeance DATETIME,
    date_traitement DATETIME,
    
    -- Statut
    statut ENUM('nouvelle', 'vue', 'en_cours', 'resolue', 'ignoree') DEFAULT 'nouvelle',
    
    -- Traitement
    utilisateur_traitement_id INT,
    commentaire_traitement TEXT,
    
    FOREIGN KEY (type_alerte_id) REFERENCES types_alertes(type_alerte_id),
    FOREIGN KEY (vehicule_id) REFERENCES vehicules(vehicule_id),
    FOREIGN KEY (remorque_id) REFERENCES remorques(remorque_id),
    FOREIGN KEY (conducteur_id) REFERENCES conducteurs(conducteur_id),
    FOREIGN KEY (partenaire_id) REFERENCES partenaires(partenaire_id),
    FOREIGN KEY (tournee_id) REFERENCES tournees(tournee_id),
    FOREIGN KEY (ordre_id) REFERENCES ordres_transport(ordre_id),
    INDEX idx_type_alerte (type_alerte_id),
    INDEX idx_statut_alerte (statut),
    INDEX idx_date_detection (date_detection),
    INDEX idx_vehicule_alerte (vehicule_id)
);

-- ==============================================================================
-- 11. GESTION DES UTILISATEURS ET SÉCURITÉ
-- ==============================================================================

-- Rôles et permissions
CREATE TABLE roles (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    nom_role VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    actif BOOLEAN DEFAULT TRUE
);

-- Permissions
CREATE TABLE permissions (
    permission_id INT PRIMARY KEY AUTO_INCREMENT,
    code_permission VARCHAR(50) UNIQUE NOT NULL,
    libelle VARCHAR(100) NOT NULL,
    module VARCHAR(50) NOT NULL,
    description TEXT
);

-- Attribution permissions aux rôles
CREATE TABLE roles_permissions (
    role_id INT NOT NULL,
    permission_id INT NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(permission_id) ON DELETE CASCADE
);

-- Utilisateurs du système
CREATE TABLE utilisateurs (
    utilisateur_id INT PRIMARY KEY AUTO_INCREMENT,
    nom_utilisateur VARCHAR(50) UNIQUE NOT NULL,
    mot_de_passe_hash VARCHAR(255) NOT NULL,
    
    -- Informations personnelles
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telephone VARCHAR(20),
    
    -- Sécurité
    role_id INT NOT NULL,
    actif BOOLEAN DEFAULT TRUE,
    derniere_connexion DATETIME,
    tentatives_connexion_echouees INT DEFAULT 0,
    compte_verrouille BOOLEAN DEFAULT FALSE,
    
    -- Dates
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    date_expiration_mot_de_passe DATE,
    
    FOREIGN KEY (role_id) REFERENCES roles(role_id),
    INDEX idx_nom_utilisateur (nom_utilisateur),
    INDEX idx_email (email),
    INDEX idx_actif (actif)
);

-- Historique des connexions
CREATE TABLE historique_connexions (
    connexion_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    utilisateur_id INT NOT NULL,
    date_connexion DATETIME DEFAULT CURRENT_TIMESTAMP,
    adresse_ip VARCHAR(45),
    user_agent TEXT,
    succes BOOLEAN DEFAULT TRUE,
    
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(utilisateur_id),
    INDEX idx_utilisateur_connexion (utilisateur_id),
    INDEX idx_date_connexion (date_connexion)
);

-- ==============================================================================
-- 12. DONNÉES DE RÉFÉRENCE ET PARAMÉTRAGE
-- ==============================================================================

-- Zones géographiques
CREATE TABLE zones_geographiques (
    zone_id INT PRIMARY KEY AUTO_INCREMENT,
    code_zone VARCHAR(10) UNIQUE NOT NULL,
    nom_zone VARCHAR(100) NOT NULL,
    type_zone ENUM('departement', 'region', 'pays', 'personnalisee') NOT NULL,
    zone_parent_id INT,
    
    FOREIGN KEY (zone_parent_id) REFERENCES zones_geographiques(zone_id),
    INDEX idx_code_zone (code_zone),
    INDEX idx_type_zone (type_zone)
);

-- Tarifs kilométriques par zone
CREATE TABLE tarifs_kilometriques (
    tarif_id INT PRIMARY KEY AUTO_INCREMENT,
    zone_origine_id INT NOT NULL,
    zone_destination_id INT NOT NULL,
    type_vehicule ENUM('porteur', 'tracteur', 'ensemble') NOT NULL,
    
    prix_km_ht DECIMAL(6,4) NOT NULL,
    prix_minimum_ht DECIMAL(8,2),
    
    date_debut DATE NOT NULL,
    date_fin DATE,
    
    actif BOOLEAN DEFAULT TRUE,
    
    FOREIGN KEY (zone_origine_id) REFERENCES zones_geographiques(zone_id),
    FOREIGN KEY (zone_destination_id) REFERENCES zones_geographiques(zone_id),
    INDEX idx_zones_tarif (zone_origine_id, zone_destination_id),
    INDEX idx_type_vehicule_tarif (type_vehicule),
    INDEX idx_date_debut (date_debut)
);

-- Paramètres système
CREATE TABLE parametres_systeme (
    parametre_id INT PRIMARY KEY AUTO_INCREMENT,
    code_parametre VARCHAR(50) UNIQUE NOT NULL,
    libelle VARCHAR(100) NOT NULL,
    valeur_texte TEXT,
    valeur_numerique DECIMAL(15,4),
    valeur_booleen BOOLEAN,
    valeur_date DATE,
    
    type_valeur ENUM('texte', 'numerique', 'booleen', 'date') NOT NULL,
    description TEXT,
    
    date_modification DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_code_parametre (code_parametre)
);

-- ==============================================================================
-- 13. VUES MÉTIER POUR REPORTING
-- ==============================================================================

-- Vue synthèse flotte
CREATE VIEW vue_synthese_flotte AS
SELECT 
    v.vehicule_id,
    v.immatriculation,
    v.marque,
    v.modele,
    v.statut_operationnel,
    v.kilometrage_actuel,
    cv.libelle AS categorie,
    DATEDIFF(v.date_prochaine_revision, CURDATE()) AS jours_avant_revision,
    DATEDIFF(v.date_prochain_controle, CURDATE()) AS jours_avant_controle,
    c.nom AS conducteur_nom,
    c.prenom AS conducteur_prenom
FROM vehicules v
LEFT JOIN categories_vehicules cv ON v.categorie_id = cv.categorie_id
LEFT JOIN affectations_vehicules av ON v.vehicule_id = av.vehicule_id AND av.date_fin IS NULL
LEFT JOIN conducteurs c ON av.conducteur_id = c.conducteur_id;

-- Vue tableau de bord tournées
CREATE VIEW vue_tableau_bord_tournees AS
SELECT 
    t.tournee_id,
    t.numero_tournee,
    t.date_tournee,
    t.statut,
    v.immatriculation AS vehicule,
    CONCAT(c.nom, ' ', c.prenom) AS conducteur,
    COUNT(et.etape_id) AS nb_etapes,
    SUM(CASE WHEN et.statut = 'terminee' THEN 1 ELSE 0 END) AS nb_etapes_terminees,
    t.km_total_calcule,
    t.cout_total_prevu
FROM tournees t
LEFT JOIN vehicules v ON t.vehicule_id = v.vehicule_id
LEFT JOIN conducteurs c ON t.conducteur_principal_id = c.conducteur_id
LEFT JOIN etapes_tournee et ON t.tournee_id = et.tournee_id
GROUP BY t.tournee_id, t.numero_tournee, t.date_tournee, t.statut, 
         v.immatriculation, c.nom, c.prenom, t.km_total_calcule, t.cout_total_prevu;

-- Vue alertes critiques
CREATE VIEW vue_alertes_critiques AS
SELECT 
    a.alerte_id,
    ta.libelle AS type_alerte,
    a.titre,
    a.message,
    a.date_detection,
    a.date_echeance,
    a.statut,
    ta.niveau_urgence,
    v.immatriculation AS vehicule,
    CONCAT(c.nom, ' ', c.prenom) AS conducteur,
    p.raison_sociale AS partenaire
FROM alertes a
JOIN types_alertes ta ON a.type_alerte_id = ta.type_alerte_id
LEFT JOIN vehicules v ON a.vehicule_id = v.vehicule_id
LEFT JOIN conducteurs c ON a.conducteur_id = c.conducteur_id
LEFT JOIN partenaires p ON a.partenaire_id = p.partenaire_id
WHERE a.statut IN ('nouvelle', 'en_cours') 
  AND ta.niveau_urgence IN ('urgent', 'critique');

-- ==============================================================================
-- 14. TRIGGERS POUR AUTOMATISATION
-- ==============================================================================

-- Trigger pour mise à jour automatique du stock après mouvement
DELIMITER $
CREATE TRIGGER trg_update_stock_after_mouvement
AFTER INSERT ON mouvements_stock
FOR EACH ROW
BEGIN
    IF NEW.type_mouvement = 'entree' THEN
        UPDATE pieces_detachees 
        SET stock_actuel = stock_actuel + NEW.quantite
        WHERE piece_id = NEW.piece_id;
    ELSEIF NEW.type_mouvement = 'sortie' THEN
        UPDATE pieces_detachees 
        SET stock_actuel = stock_actuel - NEW.quantite
        WHERE piece_id = NEW.piece_id;
    ELSEIF NEW.type_mouvement = 'ajustement' THEN
        UPDATE pieces_detachees 
        SET stock_actuel = NEW.stock_apres
        WHERE piece_id = NEW.piece_id;
    END IF;
END$

-- Trigger pour création d'alerte stock faible
CREATE TRIGGER trg_alerte_stock_faible
AFTER UPDATE ON pieces_detachees
FOR EACH ROW
BEGIN
    IF NEW.stock_actuel <= NEW.stock_minimum AND OLD.stock_actuel > OLD.stock_minimum THEN
        INSERT INTO alertes (type_alerte_id, titre, message, date_detection, statut)
        SELECT 
            ta.type_alerte_id,
            CONCAT('Stock faible: ', NEW.designation),
            CONCAT('Le stock de la pièce ', NEW.reference_piece, ' est tombé à ', NEW.stock_actuel, ' unités (minimum: ', NEW.stock_minimum, ')'),
            NOW(),
            'nouvelle'
        FROM types_alertes ta 
        WHERE ta.code_alerte = 'STOCK_FAIBLE';
    END IF;
END$

-- Trigger pour création d'alerte expiration document
CREATE TRIGGER trg_alerte_expiration_document
AFTER INSERT ON documents
FOR EACH ROW
BEGIN
    IF NEW.date_expiration IS NOT NULL AND NEW.alerte_expiration_jours IS NOT NULL THEN
        INSERT INTO alertes (type_alerte_id, vehicule_id, remorque_id, conducteur_id, partenaire_id, titre, message, date_detection, date_echeance, statut)
        SELECT 
            ta.type_alerte_id,
            NEW.vehicule_id,
            NEW.remorque_id,
            NEW.conducteur_id,
            NEW.partenaire_id,
            CONCAT('Document à renouveler: ', td.libelle),
            CONCAT('Le document ', NEW.numero_document, ' expire le ', DATE_FORMAT(NEW.date_expiration, '%d/%m/%Y')),
            DATE_SUB(NEW.date_expiration, INTERVAL NEW.alerte_expiration_jours DAY),
            NEW.date_expiration,
            'nouvelle'
        FROM types_alertes ta, types_documents td
        WHERE ta.code_alerte = 'EXPIRATION_DOCUMENT'
          AND td.type_document_id = NEW.type_document_id
          AND DATE_SUB(NEW.date_expiration, INTERVAL NEW.alerte_expiration_jours DAY) >= CURDATE();
    END IF;
END$

DELIMITER ;

-- ==============================================================================
-- 15. DONNÉES D'INITIALISATION
-- ==============================================================================

-- Types d'entités
INSERT INTO types_entites (code_type, libelle, description) VALUES
('CLIENT', 'Client', 'Entreprise cliente'),
('FOURNISS', 'Fournisseur', 'Fournisseur de services ou pièces'),
('SOUS_TRAIT', 'Sous-traitant', 'Transporteur sous-traitant'),
('PARTENAIRE', 'Partenaire', 'Partenaire commercial');

-- Catégories de véhicules selon normes européennes
INSERT INTO categories_vehicules (code_categorie, libelle, description, poids_min_kg, poids_max_kg) VALUES
('N1', 'Véhicule utilitaire léger', 'PTAC ≤ 3,5 tonnes', 0, 3500),
('N2', 'Véhicule utilitaire moyen', 'PTAC entre 3,5 et 12 tonnes', 3501, 12000),
('N3', 'Véhicule utilitaire lourd', 'PTAC > 12 tonnes', 12001, 44000),
('O1', 'Remorque légère', 'PTAC ≤ 0,75 tonne', 0, 750),
('O2', 'Remorque moyenne', 'PTAC entre 0,75 et 3,5 tonnes', 751, 3500),
('O3', 'Remorque lourde', 'PTAC entre 3,5 et 10 tonnes', 3501, 10000),
('O4', 'Semi-remorque', 'PTAC > 10 tonnes', 10001, 44000);

-- Types d'alertes
INSERT INTO types_alertes (code_alerte, libelle, description, niveau_urgence) VALUES
('STOCK_FAIBLE', 'Stock faible', 'Stock pièce détachée sous le seuil minimum', 'attention'),
('EXPIRATION_DOCUMENT', 'Document expirant', 'Document véhicule/conducteur bientôt expiré', 'urgent'),
('MAINTENANCE_DUE', 'Maintenance due', 'Maintenance préventive à programmer', 'attention'),
('EXCES_VITESSE', 'Excès de vitesse', 'Véhicule en excès de vitesse détecté', 'critique'),
('CONDUITE_DANGEREUSE', 'Conduite dangereuse', 'Comportement de conduite à risque', 'urgent'),
('RETARD_LIVRAISON', 'Retard livraison', 'Risque de retard sur livraison client', 'urgent');

-- Postes comptables
INSERT INTO postes_comptables (code_poste, libelle, type_poste, categorie) VALUES
('CARBU', 'Carburant', 'charge', 'Exploitation'),
('PEAGE', 'Péages', 'charge', 'Exploitation'),
('MAINT', 'Maintenance', 'charge', 'Exploitation'),
('ASSUR', 'Assurances', 'charge', 'Exploitation'),
('SALAIRE', 'Salaires', 'charge', 'Personnel'),
('TRANSP', 'Transport', 'produit', 'Chiffre d\'affaires');

-- Rôles utilisateurs
INSERT INTO roles (nom_role, description) VALUES
('Administrateur', 'Accès complet au système'),
('Dispatching', 'Gestion des tournées et planification'),
('Comptabilité', 'Gestion financière et facturation'),
('Maintenance', 'Gestion de la maintenance et des pièces'),
('Consultation', 'Consultation uniquement');

-- Permissions de base
INSERT INTO permissions (code_permission, libelle, module) VALUES
('VEHICULE_READ', 'Consulter véhicules', 'Flotte'),
('VEHICULE_WRITE', 'Modifier véhicules', 'Flotte'),
('TOURNEE_READ', 'Consulter tournées', 'Exploitation'),
('TOURNEE_WRITE', 'Modifier tournées', 'Exploitation'),
('FINANCE_READ', 'Consulter finances', 'Comptabilité'),
('FINANCE_WRITE', 'Modifier finances', 'Comptabilité'),
('MAINTENANCE_READ', 'Consulter maintenance', 'Maintenance'),
('MAINTENANCE_WRITE', 'Modifier maintenance', 'Maintenance'),
('ADMIN_SYSTEM', 'Administration système', 'Administration');

-- Paramètres système par défaut
INSERT INTO parametres_systeme (code_parametre, libelle, valeur_numerique, type_valeur, description) VALUES
('VITESSE_MAX_URBAIN', 'Vitesse maximale en ville', 50, 'numerique', 'Vitesse limite en agglomération (km/h)'),
('VITESSE_MAX_ROUTE', 'Vitesse maximale sur route', 80, 'numerique', 'Vitesse limite sur route (km/h)'),
('VITESSE_MAX_AUTOROUTE', 'Vitesse maximale autoroute', 90, 'numerique', 'Vitesse limite autoroute poids lourd (km/h)'),
('DUREE_CONDUITE_MAX', 'Durée conduite maximale', 540, 'numerique', 'Durée maximale de conduite continue (minutes)'),
('PAUSE_OBLIGATOIRE', 'Pause obligatoire', 45, 'numerique', 'Durée pause obligatoire (minutes)'),
('REPOS_JOURNALIER', 'Repos journalier', 660, 'numerique', 'Durée repos journalier minimum (minutes)');

INSERT INTO parametres_systeme (code_parametre, libelle, valeur_texte, type_valeur, description) VALUES
('DEVISE_DEFAUT', 'Devise par défaut', 'EUR', 'texte', 'Devise utilisée par défaut'),
('PAYS_DEFAUT', 'Pays par défaut', 'France', 'texte', 'Pays par défaut pour les adresses');

-- Types de documents
INSERT INTO types_documents (code_type, libelle, description, obligatoire, duree_validite_mois) VALUES
('CARTE_GRISE', 'Carte grise', 'Certificat d\'immatriculation', TRUE, NULL),
('CONTROLE_TECH', 'Contrôle technique', 'Certificat de contrôle technique', TRUE, 12),
('ASSURANCE', 'Assurance', 'Attestation d\'assurance véhicule', TRUE, 12),
('PERMIS_CONDUIRE', 'Permis de conduire', 'Permis de conduire', TRUE, 180),
('FIMO', 'FIMO', 'Formation Initiale Minimale Obligatoire', TRUE, NULL),
('FCO', 'FCO', 'Formation Continue Obligatoire', TRUE, 60),
('ADR', 'ADR', 'Certificat matières dangereuses', FALSE, 60),
('ATTESTATION_CAPACITE', 'Attestation capacité', 'Attestation de capacité transport', TRUE, NULL);

-- Catégories de pièces
INSERT INTO categories_pieces (code_categorie, libelle, description) VALUES
('MOTEUR', 'Moteur', 'Pièces du groupe motopropulseur'),
('FREINAGE', 'Freinage', 'Système de freinage'),
('PNEUMATI', 'Pneumatiques', 'Pneus et accessoires'),
('FILTRATI', 'Filtration', 'Filtres air, huile, carburant'),
('ELECTRIQ', 'Électrique', 'Système électrique et électronique'),
('CARROSSE', 'Carrosserie', 'Éléments de carrosserie'),
('HYDRAULI', 'Hydraulique', 'Système hydraulique'),
('ATTELAGE', 'Attelage', 'Système d\'attelage et remorquage');

-- ==============================================================================
-- INDEX SUPPLÉMENTAIRES POUR OPTIMISATION
-- ==============================================================================

-- Index composites pour requêtes fréquentes
CREATE INDEX idx_tournee_date_statut ON tournees(date_tournee, statut);
CREATE INDEX idx_ordre_client_statut ON ordres_transport(partenaire_client_id, statut);
CREATE INDEX idx_expedition_ordre_statut ON expeditions(ordre_id, statut);
CREATE INDEX idx_vehicule_statut_proprietaire ON vehicules(statut_operationnel, proprietaire);
CREATE INDEX idx_conducteur_statut_type ON conducteurs(statut_activite, type_contrat);
CREATE INDEX idx_position_vehicule_timestamp ON positions_gps(vehicule_id, timestamp_gps);
CREATE INDEX idx_depense_vehicule_date ON depenses(vehicule_id, date_operation);
CREATE INDEX idx_document_expiration_statut ON documents(date_expiration, statut);

-- Index pour alertes par type et statut
CREATE INDEX idx_alerte_type_statut ON alertes(type_alerte_id, statut   );
CREATE INDEX idx_alerte_date_detection ON alertes(date_detection);
CREATE INDEX idx_alerte_vehicule ON alertes(vehicule_id);
CREATE INDEX idx_alerte_conducteur ON alertes(conducteur_id);
CREATE INDEX idx_alerte_partenaire ON alertes(partenaire_id);
CREATE INDEX idx_alerte_tournee ON alertes(tournee_id);
CREATE INDEX idx_alerte_ordre ON alertes(ordre_id);
-- Index pour mouvements de stock par type et date
CREATE INDEX idx_mouvement_piece_date ON mouvements_stock(piece_id, date_mouvement);
CREATE INDEX idx_mouvement_type ON mouvements_stock(type_mouvement);
-- Index pour interventions de maintenance par statut et date
CREATE INDEX idx_intervention_statut_date ON interventions_maintenance(statut, date_intervention);
CREATE INDEX idx_intervention_vehicule ON interventions_maintenance(vehicule_id);
CREATE INDEX idx_intervention_remorque ON interventions_maintenance(remorque_id);
-- Index pour pièces utilisées par intervention
CREATE INDEX idx_piece_utilisee_intervention ON pieces_utilisees(intervention_id);
CREATE INDEX idx_piece_utilisee_piece ON pieces_utilisees(piece_id);
-- Index pour alertes par date d'échéance
CREATE INDEX idx_alerte_date_echeance ON alertes(date_echeance);
-- Index pour documents par type et date d'expiration
CREATE INDEX idx_document_type_expiration ON documents(type_document_id, date_expiration);
-- Index pour utilisateurs par rôle et statut
CREATE INDEX idx_utilisateur_role_statut ON utilisateurs(role_id, actif);
CREATE INDEX idx_utilisateur_email ON utilisateurs(email);
-- Index pour historique des connexions par utilisateur et date
CREATE INDEX idx_connexion_utilisateur_date ON historique_connexions(utilisateur_id, date_connexion);
-- Index pour alertes par utilisateur de traitement
CREATE INDEX idx_alerte_utilisateur_traitement ON alertes(utilisateur_traitement_id);
-- Index pour paramètres système par code
CREATE INDEX idx_parametre_code ON parametres_systeme(code_parametre);
-- Index pour zones géographiques par type
CREATE INDEX idx_zone_type ON zones_geographiques(type_zone);
-- Index pour tarifs kilométriques par zones
CREATE INDEX idx_tarif_zones ON tarifs_kilometriques(zone_origine_id, zone_destination_id, type_vehicule);
-- Index pour catégories de pièces par code
CREATE INDEX idx_categorie_piece_code ON categories_pieces(code_categorie);
-- Index pour pièces détachées par référence et catégorie
CREATE INDEX idx_piece_reference ON pieces_detachees(reference_piece);
CREATE INDEX idx_piece_categorie ON pieces_detachees(categorie_piece_id);
-- Index pour mouvements de stock par type et pièce
CREATE INDEX idx_mouvement_piece ON mouvements_stock(piece_id);
CREATE INDEX idx_mouvement_type_piece ON mouvements_stock(type_mouvement, piece_id);

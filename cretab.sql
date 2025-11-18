-- RUFFAULT--RAVENEL Gémino
-- VICAT Louis

SET SQLBLANKLINES ON
SET DEFINE OFF


-------------------------------------------
----------- CREATION DES TABLES -----------
-------------------------------------------

-- Suppression des tables existantes
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Inscriptions CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE CoursPrealables CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE ActivitesApprentissage CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE CoursEnseignes CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Cours CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE AdresseCivique CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Etudiants CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Enseignants CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Departements CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Personnes CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
COMMIT;

-- Personnes
CREATE TABLE Personnes (
    IdPersonne                      NUMBER(10)      PRIMARY KEY,
    PersonneNom                     VARCHAR2(50)    NOT NULL,
    PersonnePrenom                  VARCHAR2(50)    NOT NULL,
    PersonneNumeroAssuranceSocial   NUMBER(20)      NOT NULL UNIQUE,
    PersonneCourriel                VARCHAR2(100)   NOT NULL,
    PersonneTel                     VARCHAR2(20),
    PersonneDateDeNaissance         DATE
);
COMMIT;

-- Départements
CREATE TABLE Departements (
    IdDepartement                   NUMBER(10)      PRIMARY KEY,
    DepartementNom                  VARCHAR2(100)   NOT NULL UNIQUE,
    DepartementNum                  NUMBER(10)      NOT NULL,
    DepartementDirecteur            NUMBER(10)      DEFAULT NULL
    -- DepartementDirecteur est une clé étrangère vers Enseignants, mais la table n'existe pas encore. La contrainte serra ajouter via un ALTER TABLE a la fin.
);
COMMIT;

-- Enseignants
CREATE TABLE Enseignants (
    IdEnseignant                    NUMBER(10)      PRIMARY KEY,
    EnseignantDateEmbauche          DATE            DEFAULT SYSDATE NOT NULL,
    EnseignantStatutEnseignant      NUMBER(2)       NOT NULL,
    EnseignantNumLocal              VARCHAR2(7)     NOT NULL,
    EnseignantNumPoste              NUMBER(4)       NOT NULL,
    EnseignantAdresseCivique        VARCHAR2(100)   NOT NULL,
    EnseignantCourriel              VARCHAR2(100)   NOT NULL,
    EnseignantDepartement           NUMBER(10)      NOT NULL,
    
    CONSTRAINT FK_ENSEIGNANT_PERSONNE FOREIGN KEY (IdEnseignant) REFERENCES Personnes (IdPersonne),
    CONSTRAINT FK_ENSEIGNANT_DEPT FOREIGN KEY (EnseignantDepartement) REFERENCES Departements (IdDepartement),
    CONSTRAINT CHK_ENSEIGNANT_STATUT CHECK (EnseignantStatutEnseignant IN (0,1,2,3,4)),
    CONSTRAINT CHK_ENSEIGNANT_LOCAL_FORMAT CHECK (REGEXP_LIKE(EnseignantNumLocal, '^[A-G][0-9]-[1-4][0-9]{3}$')),
    CONSTRAINT CHK_ENSEIGNANT_POSTE CHECK (EnseignantNumPoste BETWEEN 0 AND 9999)
);
COMMIT;

-- Un département a un directeur (qui est un enseignant)
ALTER TABLE Departements
ADD CONSTRAINT FK_DEPT_DIRECTEUR FOREIGN KEY (DepartementDirecteur) REFERENCES Enseignants (IdEnseignant);
COMMIT;

-- Étudiants
CREATE TABLE Etudiants (
    IdEtudiant                      NUMBER(10)      PRIMARY KEY,
    EtudiantCodePermanent           VARCHAR2(30)    NOT NULL UNIQUE,
    EtudiantDateInscription         DATE            DEFAULT SYSDATE NOT NULL,
    EtudiantStatut                  VARCHAR2(1)     NOT NULL,
    EtudiantCourriel                VARCHAR2(100)   NOT NULL,
    EtudiantDepartement             NUMBER(10)      NOT NULL,

    CONSTRAINT FK_ETUDIANT_PERSONNE FOREIGN KEY (IdEtudiant) REFERENCES Personnes (IdPersonne),
    CONSTRAINT FK_ETUDIANT_DEPT FOREIGN KEY (EtudiantDepartement) REFERENCES Departements (IdDepartement),
    CONSTRAINT CHK_ETUDIANT_STATUT CHECK (EtudiantStatut IN ('C','A','T','S','P'))
);
COMMIT;

-- Adresse civique
CREATE TABLE AdresseCivique (
    IdAdresseCivique                NUMBER(10)      PRIMARY KEY,
    AdresseCiviqueTitre             VARCHAR2(30),
    AdresseCivique                  VARCHAR2(100)   NOT NULL,
    AdresseCiviqueEtudiant          NUMBER(10)      NOT NULL, -- id étudiant

    CONSTRAINT FK_ADRESSE_ETUDIANT FOREIGN KEY (AdresseCiviqueEtudiant) REFERENCES Etudiants (IdEtudiant)
);
COMMIT;

-- Cours
CREATE TABLE Cours (
    IdCours                         NUMBER(10)      PRIMARY KEY,
    CoursTitre                      VARCHAR2(100)   NOT NULL,
    CoursSigle                      VARCHAR2(7)     NOT NULL,
    CoursDescription                VARCHAR2(200)   NOT NULL,
    CoursAdresseSiteWeb             VARCHAR2(100),
    CoursNbCredits                  NUMBER(5)       NOT NULL,
    CoursNbHeuresCours              NUMBER(5)       NOT NULL,
    CoursNbHeuresLabo               NUMBER(5)       NOT NULL,
    CoursNbHeuresPerso              NUMBER(5)       NOT NULL,

    CONSTRAINT CHK_COURS_NBCREDITS CHECK (CoursNbCredits > 0),
    CONSTRAINT CHK_COURS_SIGLE_FORMAT CHECK (REGEXP_LIKE(CoursSigle, '^[0-9]+[A-Z]{3}[0-9]{3}$')),
    CONSTRAINT CHK_COURS_NBHEURES_COURS CHECK (CoursNbHeuresCours > 0),
    CONSTRAINT CHK_COURS_NBHEURES_LABO CHECK (CoursNbHeuresLabo > 0),
    CONSTRAINT CHK_COURS_NBHEURES_PERSO CHECK (CoursNbHeuresPerso > 0)
);
COMMIT;

-- CoursEnseignes
CREATE TABLE CoursEnseignes (
    IdCoursEnseigne                 NUMBER(10)      PRIMARY KEY,
    CoursEnseigneSession            NUMBER(6)       NOT NULL,
    CoursEnseigneGroupe             NUMBER(2)       NOT NULL,
    CourEnseigneEnseignant          NUMBER(10)      NOT NULL,
    CourEnseigneCours               NUMBER(10)      NOT NULL,

    CONSTRAINT FK_COURSENSEIGNES_ENSEIGNANT FOREIGN KEY (CourEnseigneEnseignant) REFERENCES Enseignants (IdEnseignant),
    CONSTRAINT FK_COURSENSEIGNES_COURS FOREIGN KEY (CourEnseigneCours) REFERENCES Cours (IdCours),
    CONSTRAINT CHK_COURSENSEIGNE_SESSION CHECK (REGEXP_LIKE(CoursEnseigneSession, '^[0-9]{4}[123]$')),
    CONSTRAINT CHK_COURSENSEIGNE_GROUPE CHECK (CoursEnseigneGroupe BETWEEN 1 AND 99)
);
COMMIT;

-- Inscriptions
CREATE TABLE Inscriptions (
    IdEtudiant                      NUMBER(10),
    IdCoursEnseigne                 NUMBER(10),
    EtudiantCoursStatut             VARCHAR2(2)     DEFAULT 'X' NOT NULL,
    
    CONSTRAINT PK_INSCRIPTIONS PRIMARY KEY (IdEtudiant, IdCoursEnseigne),
    CONSTRAINT FK_INSCRIPTIONS_ETUDIANT FOREIGN KEY (IdEtudiant) REFERENCES Etudiants (IdEtudiant),
    CONSTRAINT FK_INSCRIPTIONS_COURSENSEIGNE FOREIGN KEY (IdCoursEnseigne) REFERENCES CoursEnseignes (IdCoursEnseigne),
    CONSTRAINT CHK_INSCRIPTIONS_STATUT CHECK (EtudiantCoursStatut IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','S','E','I','X','Y','Z'))
);
COMMIT;

-- Activités d'apprentissage
CREATE TABLE ActivitesApprentissage (
    IdActivite                      NUMBER(10)      PRIMARY KEY,
    ActiviteCours                   NUMBER(10)      NOT NULL,
    ActiviteType                    VARCHAR2(20)    NOT NULL,
    ActiviteJourSemaine             NUMBER(1)       NOT NULL,
    ActiviteHeure                   DATE            NOT NULL,
    ActiviteLocal                   VARCHAR2(7)     NOT NULL,

    CONSTRAINT FK_ACTIVITE_COURS FOREIGN KEY (ActiviteCours) REFERENCES Cours (IdCours),
    CONSTRAINT CHK_ACTIVITE_JOUR CHECK (ActiviteJourSemaine BETWEEN 0 AND 6)
);
COMMIT;

-- Table de cours préalables
CREATE TABLE CoursPrealables (
    IdCours                         NUMBER(10)    NOT NULL,
    IdCoursPrealable                NUMBER(10)    NOT NULL,

    CONSTRAINT PK_COURS_PREALABLES PRIMARY KEY (IdCours, IdCoursPrealable),
    CONSTRAINT FK_CP_COURS FOREIGN KEY (IdCours) REFERENCES Cours (IdCours),
    CONSTRAINT FK_CP_PREALABLE FOREIGN KEY (IdCoursPrealable) REFERENCES Cours (IdCours)
);
COMMIT;


--------------------------------
----------- TRIGGERS -----------
--------------------------------

-- Le directeur d'un département doit être un enseignant appartenant à ce département
CREATE OR REPLACE TRIGGER TRG_DEPT_DIR_ENSEIGN
BEFORE UPDATE OF DepartementDirecteur ON Departements
FOR EACH ROW
DECLARE
    v_dept_enseignant NUMBER(10);
BEGIN
    -- Ne rien faire si le directeur est mis à NULL
    IF :NEW.DepartementDirecteur IS NOT NULL THEN
        
        -- Trouver le département de l'enseignant promu directeur
        SELECT EnseignantDepartement INTO v_dept_enseignant FROM Enseignants WHERE IdEnseignant = :NEW.DepartementDirecteur;

        -- Comparer le département de l'enseignant avec l'ID du département
        IF v_dept_enseignant != :NEW.IdDepartement THEN
            RAISE_APPLICATION_ERROR(-20001, 'Erreur : Le directeur doit être un enseignant du même département.');
        END IF;
    END IF;
EXCEPTION
    -- Gérer le cas où l'enseignant n'existe pas (le SELECT renvoie 0 ligne)
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Erreur : L''enseignant désigné comme directeur n''existe pas.');
END;
/
COMMIT;

-- Un departement doit avoir un directeur si un cours est donné 
CREATE OR REPLACE TRIGGER TRG_DEPT_DIR_REQ
BEFORE INSERT ON CoursEnseignes
FOR EACH ROW
DECLARE
    v_id_dept NUMBER(10);
    v_directeur_id NUMBER(10);
BEGIN
    -- 1. Trouver le département de l'enseignant qui donne le cours
    SELECT EnseignantDepartement INTO v_id_dept FROM Enseignants WHERE IdEnseignant = :NEW.CourEnseigneEnseignant;

    -- 2. Vérifier si ce département a un directeur
    SELECT DepartementDirecteur INTO v_directeur_id FROM Departements WHERE IdDepartement = v_id_dept;

    -- 3. Si le directeur est NULL, bloquer l'insertion [cite: 8]
    IF v_directeur_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20003, 'Erreur : Le département de l''enseignant n''a pas de directeur. Impossible d''ajouter un cours.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Gère le cas où l'enseignant ou le département n'est pas trouvé
        RAISE_APPLICATION_ERROR(-20004, 'Erreur : Enseignant ou département non trouvé lors de la vérification du directeur.');
END;
/
COMMIT;

-- Limite de 6 cours par enseignants
CREATE OR REPLACE TRIGGER TRG_ENSEIGN_LIM_CR
BEFORE INSERT ON CoursEnseignes
FOR EACH ROW
DECLARE
    v_nb_cours NUMBER;
BEGIN
    -- Compter les cours que l'enseignant donne DÉJÀ dans la MÊME session
    SELECT COUNT(*) INTO v_nb_cours
    FROM CoursEnseignes
    WHERE CourEnseigneEnseignant = :NEW.CourEnseigneEnseignant
      AND CoursEnseigneSession = :NEW.CoursEnseigneSession;

    -- Si l'enseignant en a déjà 6, le nouveau (le 7ème) est refusé [cite: 31]
    IF v_nb_cours >= 6 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Erreur : L''enseignant ' || :NEW.CourEnseigneEnseignant || ' a déjà atteint la limite de 6 cours pour la session ' || :NEW.CoursEnseigneSession || '.');
    END IF;
END;
/
COMMIT;

-- Lorsque l'on delete une inscription, si le nombre d'inscription aux CoursEnseigné liée est inférieur a 8, alors ont passe toute ses inscriptions en Inscriptions.EtudiantCoursStatut = 'Z'
CREATE OR REPLACE TRIGGER TRG_INSCRIPTIONS_UPDATE_Z 
AFTER DELETE ON Inscriptions
FOR EACH ROW
DECLARE
    v_nb_inscriptions NUMBER;
BEGIN
    -- Compter le nombre d'inscriptions restantes pour ce cours enseigné
    SELECT COUNT(*) INTO v_nb_inscriptions
    FROM Inscriptions
    WHERE IdCoursEnseigne = :OLD.IdCoursEnseigne;

    -- Si moins de 8 inscriptions, mettre à jour le statut de toutes les inscriptions liées
    IF v_nb_inscriptions < 8 THEN
        UPDATE Inscriptions
        SET EtudiantCoursStatut = 'Z'
        WHERE IdCoursEnseigne = :OLD.IdCoursEnseigne;
    END IF;
END;
/
COMMIT;


----------------------------------
----------- PROCEDURES -----------
----------------------------------

-- Supressions des sequences existantes
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_DEPARTEMENTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_PERSONNES'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_COURS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_ADDR_CIVIQUE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/

-- Création de toute les sequences
CREATE SEQUENCE SEQ_DEPARTEMENTS START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_PERSONNES START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_COURS START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_ADDR_CIVIQUE START WITH 1 INCREMENT BY 1;

-------------------------------------------
---- Procédure de création d'un département
CREATE OR REPLACE PROCEDURE P_CREATE_DEPARTEMENT (
    d_nom IN VARCHAR2,
    d_num IN NUMBER
) IS
BEGIN
    INSERT INTO Departements (
        IdDepartement,
        DepartementNom,
        DepartementNum
    ) VALUES (
        SEQ_DEPARTEMENTS.NEXTVAL,
        d_nom,
        d_num
    );

    COMMIT;
END;
/

------------------------------------------------------------
---- Procédure d'assignation d'un directeur à un département
CREATE OR REPLACE PROCEDURE P_DEP_ASSIGN_DIR (
    d_idDepartement IN NUMBER,
    d_idEnseignant  IN NUMBER
) IS
BEGIN
    UPDATE Departements SET DepartementDirecteur = d_idEnseignant WHERE IdDepartement = d_idDepartement;
    COMMIT;
END;
/

-------------------------------------------------------------------------------
---- Procédure de création d'un enseignant (incluant la personne si nécessaire)
CREATE OR REPLACE PROCEDURE P_CREATE_ENSEIGNANT (
    -- Personne
    p_nom              IN VARCHAR2,
    p_prenom           IN VARCHAR2,
    p_nas              IN NUMBER,
    p_courriel         IN VARCHAR2,
    p_tel              IN VARCHAR2,
    p_date_naissance   IN DATE,

    -- Enseignant
    e_statut           IN NUMBER,
    e_num_local        IN VARCHAR2,
    e_num_poste        IN NUMBER,
    e_adresse_civique  IN VARCHAR2,
    e_courriel         IN VARCHAR2,
    e_departement      IN NUMBER
) IS
    v_id_personne      NUMBER;
    v_nb_personnes     NUMBER;
BEGIN
    -- Vérifier si une personne existe déjà via son numéro d'assurance sociale
    SELECT COUNT(*) INTO v_nb_personnes FROM Personnes WHERE PersonneNumeroAssuranceSocial = p_nas;

    IF v_nb_personnes > 0 THEN
        -- Une personne existe déjà -> récupérer son identifiant
        SELECT IdPersonne INTO v_id_personne FROM Personnes WHERE PersonneNumeroAssuranceSocial = p_nas;

        -- La mettre a jour
        UPDATE Personnes
        SET PersonneNom = p_nom,
            PersonnePrenom = p_prenom,
            PersonneCourriel = p_courriel,
            PersonneTel = p_tel,
            PersonneDateDeNaissance = p_date_naissance
        WHERE IdPersonne = v_id_personne;

    ELSE
    
        -- Générer une nouvelle personne
        SELECT SEQ_PERSONNES.NEXTVAL INTO v_id_personne FROM DUAL;

        INSERT INTO Personnes (IdPersonne, PersonneNom, PersonnePrenom, PersonneNumeroAssuranceSocial, PersonneCourriel, PersonneTel, PersonneDateDeNaissance) VALUES 
        (
            v_id_personne,
            p_nom,
            p_prenom,
            p_nas,
            p_courriel,
            p_tel,
            p_date_naissance
        );
    END IF;

    -- Créer l'enseignant
    INSERT INTO Enseignants (IdEnseignant, EnseignantStatutEnseignant, EnseignantNumLocal, EnseignantNumPoste, EnseignantAdresseCivique, EnseignantCourriel, EnseignantDepartement) VALUES
    (
        v_id_personne,
        e_statut,
        e_num_local,
        e_num_poste,
        e_adresse_civique,
        e_courriel,
        e_departement
    );

    COMMIT;
END;
/

--------------------------------------------------
---- Modifier un enseignant (incluant la personne)
CREATE OR REPLACE PROCEDURE P_UPDATE_ENSEIGNANT (
    p_id_personne            IN NUMBER,

    -- Personne
    p_nom                    IN VARCHAR2,
    p_prenom                 IN VARCHAR2,
    p_nas                    IN NUMBER,
    p_courriel_personne      IN VARCHAR2,
    p_tel                    IN VARCHAR2,
    p_date_naissance         IN DATE,

    -- Enseignant
    e_statut                 IN NUMBER,
    e_num_local              IN VARCHAR2,
    e_num_poste              IN NUMBER,
    e_adresse_civique        IN VARCHAR2,
    e_courriel_enseignant    IN VARCHAR2,
    e_departement            IN NUMBER
) IS
BEGIN
    UPDATE Personnes
    SET PersonneNom = p_nom,
        PersonnePrenom = p_prenom,
        PersonneNumeroAssuranceSocial = p_nas,
        PersonneCourriel = p_courriel_personne,
        PersonneTel = p_tel,
        PersonneDateDeNaissance = p_date_naissance
    WHERE IdPersonne = p_id_personne;

    UPDATE Enseignants
    SET EnseignantStatutEnseignant = e_statut,
        EnseignantNumLocal = e_num_local,
        EnseignantNumPoste = e_num_poste,
        EnseignantAdresseCivique = e_adresse_civique,
        EnseignantCourriel = e_courriel_enseignant,
        EnseignantDepartement = e_departement
    WHERE IdEnseignant = p_id_personne;

    COMMIT;
END;
/

----------------------------------------------------------------
---- Création d'un étudiant (incluant la personne si nécessaire)
CREATE OR REPLACE PROCEDURE P_CREATE_ETUDIANT (
    -- Personne
    p_nom                  IN VARCHAR2,
    p_prenom               IN VARCHAR2,
    p_nas                  IN NUMBER,
    p_courriel_personne    IN VARCHAR2,
    p_tel                  IN VARCHAR2,
    p_date_naissance       IN DATE,

    -- Etudiant
    s_code_permanent       IN VARCHAR2,
    s_statut               IN VARCHAR2,
    s_courriel             IN VARCHAR2,
    s_departement          IN NUMBER
) IS
    v_id_personne NUMBER;
    v_nb_personnes       NUMBER;
BEGIN
    -- Vérifier si une personne existe déjà via son numéro d'assurance sociale
    SELECT COUNT(*) INTO v_nb_personnes FROM Personnes WHERE PersonneNumeroAssuranceSocial = p_nas;

    IF v_nb_personnes > 0 THEN

        -- Une personne existe déjà -> récupérer son identifiant
        SELECT IdPersonne INTO v_id_personne FROM Personnes WHERE PersonneNumeroAssuranceSocial = p_nas;

        -- La mettre a jour
        UPDATE Personnes
        SET PersonneNom = p_nom,
            PersonnePrenom = p_prenom,
            PersonneCourriel = p_courriel_personne,
            PersonneTel = p_tel,
            PersonneDateDeNaissance = p_date_naissance
        WHERE IdPersonne = v_id_personne;
    ELSE
        -- Générer une nouvelle personne
        SELECT SEQ_PERSONNES.NEXTVAL INTO v_id_personne FROM DUAL;

        INSERT INTO Personnes (IdPersonne, PersonneNom, PersonnePrenom, PersonneNumeroAssuranceSocial, PersonneCourriel, PersonneTel, PersonneDateDeNaissance) VALUES
        (
            v_id_personne,
            p_nom,
            p_prenom,
            p_nas,
            p_courriel_personne,
            p_tel,
            p_date_naissance
        );
    END IF;

    -- Créer l'étudiant
    INSERT INTO Etudiants (IdEtudiant, EtudiantCodePermanent, EtudiantStatut, EtudiantCourriel, EtudiantDepartement) VALUES
    (
        v_id_personne,
        s_code_permanent,
        s_statut,
        s_courriel,
        s_departement
    );

    COMMIT;
END;
/

-- Procédure de modification d'un étudiant et de la personne liée (utilise IdPersonne)
CREATE OR REPLACE PROCEDURE P_UPDATE_ETUDIANT (
    p_id_personne           IN NUMBER,

    -- champs Personne
    p_nom                   IN VARCHAR2,
    p_prenom                IN VARCHAR2,
    p_nas                   IN NUMBER,
    p_courriel_personne     IN VARCHAR2,
    p_tel                   IN VARCHAR2 DEFAULT NULL,
    p_date_naissance        IN DATE DEFAULT NULL,

    -- champs Etudiant
    s_code_permanent        IN VARCHAR2,
    s_statut                IN VARCHAR2, -- attendu VARCHAR2(1)
    s_courriel              IN VARCHAR2,
    s_departement           IN NUMBER
) IS
BEGIN
    -- Met à jour la personne
    UPDATE Personnes
    SET PersonneNom = p_nom,
        PersonnePrenom = p_prenom,
        PersonneNumeroAssuranceSocial = p_nas,
        PersonneCourriel = p_courriel_personne,
        PersonneTel = p_tel,
        PersonneDateDeNaissance = p_date_naissance
    WHERE IdPersonne = p_id_personne;

    -- Met à jour l'étudiant
    UPDATE Etudiants
    SET EtudiantCodePermanent = s_code_permanent,
        EtudiantStatut = s_statut,
        EtudiantCourriel = s_courriel,
        EtudiantDepartement = s_departement
    WHERE IdEtudiant = p_id_personne;

    COMMIT;
END;
/

------------------------------------------
---- Modifier un étudiant (et la personne)
CREATE OR REPLACE PROCEDURE P_UPDATE_ETUDIANT (
    p_id_personne           IN NUMBER,

    -- champs Personne
    p_nom                   IN VARCHAR2,
    p_prenom                IN VARCHAR2,
    p_nas                   IN NUMBER,
    p_courriel_personne     IN VARCHAR2,
    p_tel                   IN VARCHAR2,
    p_date_naissance        IN DATE,

    -- champs Etudiant
    s_code_permanent        IN VARCHAR2,
    s_statut                IN VARCHAR2,
    s_courriel              IN VARCHAR2,
    s_departement           IN NUMBER
) IS
BEGIN
    -- Met à jour la personne
    UPDATE Personnes
    SET PersonneNom = p_nom,
        PersonnePrenom = p_prenom,
        PersonneNumeroAssuranceSocial = p_nas,
        PersonneCourriel = p_courriel_personne,
        PersonneTel = p_tel,
        PersonneDateDeNaissance = p_date_naissance
    WHERE IdPersonne = p_id_personne;

    -- Met à jour l'étudiant
    UPDATE Etudiants
    SET EtudiantCodePermanent = s_code_permanent,
        EtudiantStatut = s_statut,
        EtudiantCourriel = s_courriel,
        EtudiantDepartement = s_departement
    WHERE IdEtudiant = p_id_personne;

    COMMIT;
END;
/

------------------------------------------------------------------
---- Procédure de modification d'une adresse civique d'un étudiant
CREATE OR REPLACE PROCEDURE P_UPDATE_ETU_ADR_CIVIQUE (
    p_id_adresse_civique    IN NUMBER,
    p_adresse_civique_titre IN VARCHAR2,
    p_adresse_civique       IN VARCHAR2,
    p_id_etudiant           IN NUMBER
) IS
BEGIN
    UPDATE AdresseCivique
    SET IdAdresseCivique = p_id_adresse_civique,
        AdresseCiviqueTitre = p_adresse_civique_titre,
        AdresseCivique = p_adresse_civique,
        AdresseCiviqueEtudiant = p_id_etudiant

    WHERE IdAdresseCivique = p_id_adresse_civique;

    COMMIT;
END;
/

------------------------------------------------------------------
---- Procédure d'ajout d'une adresse civique d'un étudiant

CREATE OR REPLACE PROCEDURE P_CREATE_ETU_ADR_CIVIQUE (
    p_adresse_civique_titre IN VARCHAR2,
    p_adresse_civique       IN VARCHAR2,
    p_id_etudiant           IN NUMBER
        
) IS
BEGIN
    INSERT INTO AdresseCivique(IdAdresseCivique, AdresseCiviqueTitre, AdresseCivique, AdresseCiviqueEtudiant) VALUES
    (
        SEQ_ADDR_CIVIQUE.NEXTVAL,
        p_adresse_civique_titre,
        p_adresse_civique,
        p_id_etudiant
    );

    COMMIT;
END;
/

------------------------
---- Création d'un cours
CREATE OR REPLACE PROCEDURE P_CREATE_COURS (
    p_titre               IN VARCHAR2,
    p_sigle               IN VARCHAR2,
    p_description         IN VARCHAR2,
    p_site_web            IN VARCHAR2,
    p_nb_credits          IN NUMBER,
    p_nb_heures_cours     IN NUMBER,
    p_nb_heures_labo      IN NUMBER,
    p_nb_heures_perso     IN NUMBER
) IS
BEGIN
    INSERT INTO Cours (IdCours, CoursTitre, CoursSigle, CoursDescription, CoursAdresseSiteWeb, CoursNbCredits, CoursNbHeuresCours, CoursNbHeuresLabo, CoursNbHeuresPerso) VALUES
    (
        SEQ_COURS.NEXTVAL,
        p_titre,
        p_sigle,
        p_description,
        p_site_web,
        p_nb_credits,
        p_nb_heures_cours,
        p_nb_heures_labo,
        p_nb_heures_perso
    );

    COMMIT;
END;
/

----------------------------
---- Modification d'un cours
CREATE OR REPLACE PROCEDURE P_UPDATE_COURS (
    p_id_cours            IN NUMBER,
    p_titre               IN VARCHAR2,
    p_sigle               IN VARCHAR2,
    p_description         IN VARCHAR2,
    p_site_web            IN VARCHAR2,
    p_nb_credits          IN NUMBER,
    p_nb_heures_cours     IN NUMBER,
    p_nb_heures_labo      IN NUMBER,
    p_nb_heures_perso     IN NUMBER
) IS
BEGIN
    UPDATE Cours
    SET CoursTitre = p_titre,
        CoursSigle = p_sigle,
        CoursDescription = p_description,
        CoursAdresseSiteWeb = p_site_web,
        CoursNbCredits = p_nb_credits,
        CoursNbHeuresCours = p_nb_heures_cours,
        CoursNbHeuresLabo = p_nb_heures_labo,
        CoursNbHeuresPerso = p_nb_heures_perso
    WHERE IdCours = p_id_cours;

    COMMIT;
END;
/

--------------------------------
---- Assigner un cours préalable
CREATE OR REPLACE PROCEDURE P_ASSIGNER_COURS_PREALABLE (
    p_id_cours             IN NUMBER,
    p_id_cours_prealable   IN NUMBER
) IS
    v_count NUMBER;
BEGIN
    -- On compte les doublons
    SELECT COUNT(*) INTO v_count FROM CoursPrealables WHERE IdCours = p_id_cours AND IdCoursPrealable = p_id_cours_prealable;

    -- S'il n'y en a pas, on insère l'enregistrement
    IF v_count = 0 THEN
        INSERT INTO CoursPrealables (IdCours, IdCoursPrealable) VALUES
        (
            p_id_cours,
            p_id_cours_prealable
        );

        COMMIT;
    END IF;
END;
/

--------------------------------------------
---- Supprimer un cours préalable d'un cours
CREATE OR REPLACE PROCEDURE P_SUPPRIMER_COURS_PREALABLE (
    p_id_cours             IN NUMBER,
    p_id_cours_prealable   IN NUMBER
) IS
BEGIN
    DELETE FROM CoursPrealables WHERE IdCours = p_id_cours AND IdCoursPrealable = p_id_cours_prealable;

    COMMIT;
END;
/

---------------------------------------
---- Assigner un départ d'un enseignant
CREATE OR REPLACE PROCEDURE P_ASSIGNER_DEPART (
    p_id_enseignant   IN NUMBER
) IS
BEGIN
    UPDATE Enseignants SET EnseignantStatutEnseignant = 0 WHERE IdEnseignant = p_id_enseignant;

    COMMIT;
END;
/

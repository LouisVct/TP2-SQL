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
    AdresseCiviqueEtudiant          NUMBER(10)      NOT NULL,

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

-- Suppression & Création des sequences
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_DEPARTEMENTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
CREATE SEQUENCE SEQ_DEPARTEMENTS START WITH 1 INCREMENT BY 1 NOCACHE;
/

-- Procédure de création d'un département
CREATE OR REPLACE PROCEDURE P_CREATE_DEPARTEMENT (
    d_nom IN VARCHAR2,
    d_num IN NUMBER
) IS
    s_id NUMBER;
BEGIN
    -- Génération de l'identifiant
    SELECT SEQ_DEPARTEMENTS.NEXTVAL INTO s_id FROM DUAL;

    -- Insertion, directeur mis à NULL par défaut
    INSERT INTO Departements (
        IdDepartement,
        DepartementNom,
        DepartementNum
    ) VALUES (
        s_id,
        d_nom,
        d_num
    );

    COMMIT;
END;
/

-- Exemple d'appel
EXEC P_CREATE_DEPARTEMENT('Mathematiques', 202);

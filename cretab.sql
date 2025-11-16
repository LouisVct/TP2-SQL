--  Assurez-vous de bien identifier les contraintes de valeur (NOT NULL) dans vos tables, ainsi que les cle´s candidates (UNIQUE). 

-- Suppression des tables si elles existent, ordre inverse des dépendances
SET SQLBLANKLINES ON
SET DEFINE OFF

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

-- Création de la table Personnes
CREATE TABLE Personnes (
    IdPersonne                      NUMBER(10)      PRIMARY KEY,
    PersonneNom                     VARCHAR2(50)    NOT NULL,
    PersonnePrenom                  VARCHAR2(50)    NOT NULL,
    PersonneNumeroAssuranceSocial   NUMBER(20)      NOT NULL UNIQUE,
    PersonneCourriel                VARCHAR2(100)   NOT NULL,
    PersonneTel                     VARCHAR2(20),
    PersonneDateDeNaissance         DATE,
    
    CONSTRAINT FK_PERSONNE_CONTACT  FOREIGN KEY (PersonneCoordonneePerso) REFERENCES Personnes (IdPersonne)
);

-- Départements
CREATE TABLE Departements (
    IdDepartement                   NUMBER(10)      PRIMARY KEY,
    DepartementNom                  VARCHAR2(100)   NOT NULL UNIQUE,
    DepartementNum                  NUMBER(10)      NOT NULL,
    DepartementDirecteur            NUMBER(10)
);

-- Enseignants, clé primaire réutilise IdPersonne (relation "is-a")
CREATE TABLE Enseignants (
    IdEnseignant                    NUMBER(10)      PRIMARY KEY,
    EnseignantDateEmbauche          DATE            NOT NULL DEFAULT SYSDATE,
    EnseignantStatutEnseignant      NUMBER(2)       NOT NULL,
    EnseignantNumLocal              VARCHAR2(7)     NOT NULL,
    EnseignantNumPoste              NUMBER(10)      NOT NULL,
    EnseignantAdresseCivique        VARCHAR2(100)   NOT NULL,
    EnseignantCourriel              VARCHAR2(100)   NOT NULL,
    EnseignantDepartement           NUMBER(10)      NOT NULL,
    
    CONSTRAINT FK_ENSEIGNANT_PERSONNE FOREIGN KEY (IdEnseignant) REFERENCES Personnes (IdPersonne),
    CONSTRAINT FK_ENSEIGNANT_DEPT FOREIGN KEY (EnseignantDepartement) REFERENCES Departements (IdDepartement),
    CONSTRAINT CHK_ENSEIGNANT_STATUT CHECK (EnseignantStatutEnseignant IN (0,1,2,3,4))
);

-- Étudiants, clé primaire réutilise IdPersonne
CREATE TABLE Etudiants (
    IdEtudiant                      NUMBER(10)      PRIMARY KEY,
    EtudiantCodePermanent           VARCHAR2(30)    NOT NULL UNIQUE,
    EtudiantDateInscription         DATE            NOT NULL DEFAULT SYSDATE,
    EtudiantStatut                  VARCHAR2(1)     NOT NULL,
    EtudiantCourriel                VARCHAR2(100)   NOT NULL,
    EtudiantDepartement             NUMBER(10)      NOT NULL,

    CONSTRAINT FK_ETUDIANT_PERSONNE FOREIGN KEY (IdEtudiant) REFERENCES Personnes (IdPersonne),
    CONSTRAINT FK_ETUDIANT_DEPT FOREIGN KEY (EtudiantDepartement) REFERENCES Departements (IdDepartement),
    CONSTRAINT CHK_ETUDIANT_STATUT CHECK (EtudiantStatut IN ('C','A','T','S','P'))
);

-- Adresse civique, peut référencer un étudiant (optionnel)
CREATE TABLE AdresseCivique (
    IdAdresseCivique                NUMBER(10)      PRIMARY KEY,
    AdresseCiviqueTitre             VARCHAR2(30),
    AdresseCivique                  VARCHAR2(100)   NOT NULL,
    AdresseCiviqueEtudiant          NUMBER(10)      NOT NULL,

    CONSTRAINT FK_ADRESSE_ETUDIANT FOREIGN KEY (AdresseCiviqueEtudiant) REFERENCES Etudiants (IdEtudiant)
);

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

    CONSTRAINT CHK_COURS_NBCREDITS CHECK (CoursNbCredits > 0)
);

-- CoursEnseignes
CREATE TABLE CoursEnseignes (
    IdCoursEnseigne                 NUMBER(10)      PRIMARY KEY,
    CoursEnseigneSession            NUMBER(4)       NOT NULL,
    CoursEnseigneGroupe             NUMBER(4)       NOT NULL,
    CourEnseigneEnseignant          NUMBER(10)      NOT NULL,
    CourEnseigneCours               NUMBER(10)      NOT NULL,

    CONSTRAINT FK_COURSENSEIGNES_ENSEIGNANT FOREIGN KEY (CourEnseigneEnseignant) REFERENCES Enseignants (IdEnseignant),
    CONSTRAINT FK_COURSENSEIGNES_COURS FOREIGN KEY (CourEnseigneCours) REFERENCES Cours (IdCours)
);

-- Inscriptions (associations étudiant <-> cours enseigné)
CREATE TABLE Inscriptions (
    IdEtudiant                      NUMBER(10),
    IdCoursEnseigne                 NUMBER(10),
    EtudiantCoursStatut             VARCHAR2(2)     NOT NULL,
    
    CONSTRAINT PK_INSCRIPTIONS PRIMARY KEY (IdEtudiant, IdCoursEnseigne),
    CONSTRAINT FK_INSCRIPTIONS_ETUDIANT FOREIGN KEY (IdEtudiant) REFERENCES Etudiants (IdEtudiant),
    CONSTRAINT FK_INSCRIPTIONS_COURSENSEIGNE FOREIGN KEY (IdCoursEnseigne) REFERENCES CoursEnseignes (IdCoursEnseigne),
    CONSTRAINT CHK_INSCRIPTIONS_STATUT CHECK (EtudiantCoursStatut IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','S','E','I','X','Y','Z'))
);

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

-- Table de prérequis entre cours (relation many-to-many)
CREATE TABLE CoursPrealables (
    IdCours                         NUMBER(10)    NOT NULL,
    IdCoursPrealable                NUMBER(10)    NOT NULL,

    CONSTRAINT PK_COURS_PREALABLES PRIMARY KEY (IdCours, IdCoursPrealable),
    CONSTRAINT FK_CP_COURS FOREIGN KEY (IdCours) REFERENCES Cours (IdCours),
    CONSTRAINT FK_CP_PREALABLE FOREIGN KEY (IdCoursPrealable) REFERENCES Cours (IdCours)
);

-- Contraintes additionnelles relationnelles
-- Un département peut avoir un directeur qui est un enseignant
ALTER TABLE Departements
ADD CONSTRAINT FK_DEPT_DIRECTEUR FOREIGN KEY (DepartementDirecteur) REFERENCES Enseignants (IdEnseignant);

COMMIT;

-- -----------------------------------------------------------------
-- Triggers pour appliquer la règle métier :
-- "Un département peut ne pas avoir de directeur, sauf s'il contient
--  au moins un cours via la chaîne Cours->CoursEnseignes->Enseignants."
-- -----------------------------------------------------------------

-- 1) Empêcher d'affecter un enseignant à un cours si son département
--    n'a pas de directeur.
CREATE OR REPLACE TRIGGER trg_coursenseigne_check_directeur
BEFORE INSERT OR UPDATE ON CoursEnseignes
FOR EACH ROW
WHEN (NEW.CourEnseigneEnseignant IS NOT NULL)
DECLARE
    v_dept Departements.IdDepartement%TYPE;
    v_dir  Departements.DepartementDirecteur%TYPE;
BEGIN
    SELECT e.EnseignantDepartement
        INTO v_dept
        FROM Enseignants e
     WHERE e.IdEnseignant = :NEW.CourEnseigneEnseignant;

    SELECT d.DepartementDirecteur
        INTO v_dir
        FROM Departements d
     WHERE d.IdDepartement = v_dept;

    IF v_dir IS NULL THEN
        RAISE_APPLICATION_ERROR(-20010, 'Le département de l''enseignant doit avoir un directeur.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20011, 'Enseignant ou département introuvable.');
END;
/

-- 2) Empêcher de retirer ou supprimer le directeur d'un département
--    si ce département contient des cours (via la chaîne).
CREATE OR REPLACE TRIGGER trg_dept_protect_directeur
BEFORE UPDATE OR DELETE ON Departements
FOR EACH ROW
DECLARE
    cnt NUMBER;
BEGIN
    IF UPDATING AND :NEW.DepartementDirecteur IS NULL THEN
        SELECT COUNT(*) INTO cnt
            FROM CoursEnseignes ce JOIN Enseignants e ON ce.CourEnseigneEnseignant = e.IdEnseignant
         WHERE e.EnseignantDepartement = :OLD.IdDepartement;
        IF cnt > 0 THEN
            RAISE_APPLICATION_ERROR(-20012, 'Impossible de retirer le directeur : le département contient des cours.');
        END IF;
    END IF;

    IF DELETING THEN
        SELECT COUNT(*) INTO cnt
            FROM CoursEnseignes ce JOIN Enseignants e ON ce.CourEnseigneEnseignant = e.IdEnseignant
         WHERE e.EnseignantDepartement = :OLD.IdDepartement;
        IF cnt > 0 THEN
            RAISE_APPLICATION_ERROR(-20013, 'Impossible de supprimer le département : il contient des cours.');
        END IF;
    END IF;
END;
/

-- 3) Empêcher de supprimer/déplacer un enseignant qui est directeur
--    si son département contient des cours.
CREATE OR REPLACE TRIGGER trg_enseignant_protect_directeur
BEFORE UPDATE OR DELETE ON Enseignants
FOR EACH ROW
DECLARE
    is_dir NUMBER;
    cnt    NUMBER;
BEGIN
    SELECT COUNT(*) INTO is_dir FROM Departements d WHERE d.DepartementDirecteur = :OLD.IdEnseignant;
    IF is_dir > 0 THEN
        SELECT COUNT(*) INTO cnt
            FROM CoursEnseignes ce JOIN Enseignants e ON ce.CourEnseigneEnseignant = e.IdEnseignant
         WHERE e.EnseignantDepartement = :OLD.EnseignantDepartement;
        IF cnt > 0 THEN
            RAISE_APPLICATION_ERROR(-20014, 'Impossible de supprimer/deplacer cet enseignant : il est directeur et le departement a des cours.');
        END IF;
    END IF;
END;
/

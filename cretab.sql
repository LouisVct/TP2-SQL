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
    PersonneCoordonneePerso         NUMBER(10),     -- référence possible vers une autre personne (contact)
    PersonneNom                     VARCHAR2(50)    NOT NULL,
    PersonnePrenom                  VARCHAR2(50)    NOT NULL,
    PersonneNumeroAssuranceSocial   NUMBER(20)      UNIQUE,
    PersonneCourriel                VARCHAR2(100),
    PersonneTel                     VARCHAR2(20),
    PersonneDateDeNaissance         DATE,
    
    CONSTRAINT FK_PERSONNE_CONTACT  FOREIGN KEY (PersonneCoordonneePerso) REFERENCES Personnes (IdPersonne)
);

-- Départements
CREATE TABLE Departements (
    IdDepartement                   NUMBER(10)      PRIMARY KEY,
    DepartementNom                  VARCHAR2(100)   NOT NULL UNIQUE,
    DepartementNum                  NUMBER(10),
    DepartementDirecteur            NUMBER(10)
);

-- Enseignants, clé primaire réutilise IdPersonne (relation "is-a")
CREATE TABLE Enseignants (
    IdEnseignant                    NUMBER(10)      PRIMARY KEY,
    EnseignantDateEmbauche          DATE,
    EnseignantStatutEnseignant      NUMBER(2),
    EnseignantNumLocal              VARCHAR2(7),
    EnseignantNumPoste              NUMBER(10),
    EnseignantAdresseCivique        VARCHAR2(100),
    EnseignantCourriel              VARCHAR2(100),
    EnseignantDepartement           NUMBER(10),
    
    CONSTRAINT FK_ENSEIGNANT_PERSONNE FOREIGN KEY (IdEnseignant) REFERENCES Personnes (IdPersonne),
    CONSTRAINT FK_ENSEIGNANT_DEPT FOREIGN KEY (EnseignantDepartement) REFERENCES Departements (IdDepartement),
    CONSTRAINT CHK_ENSEIGNANT_STATUT CHECK (EnseignantStatutEnseignant IN (0,1,2,3,4))
);

-- Étudiants, clé primaire réutilise IdPersonne
CREATE TABLE Etudiants (
    IdEtudiant                      NUMBER(10)      PRIMARY KEY,
    EtudiantCodePermanent           VARCHAR2(30)    NOT NULL UNIQUE,
    EtudiantDateInscription         DATE,
    EtudiantStatut                  VARCHAR2(1),
    EtudiantCourriel                VARCHAR2(100),
    EtudiantDepartement             NUMBER(10),

    CONSTRAINT FK_ETUDIANT_PERSONNE FOREIGN KEY (IdEtudiant) REFERENCES Personnes (IdPersonne),
    CONSTRAINT FK_ETUDIANT_DEPT FOREIGN KEY (EtudiantDepartement) REFERENCES Departements (IdDepartement),
    CONSTRAINT CHK_ETUDIANT_STATUT CHECK (EtudiantStatut IN ('C','A','T','S','P'))
);

-- Adresse civique, peut référencer un étudiant (optionnel)
CREATE TABLE AdresseCivique (
    IdAdresseCivique                NUMBER(10)      PRIMARY KEY,
    AdresseCiviqueTitre             VARCHAR2(30),
    AdresseCiviqueTexte             VARCHAR2(100)   NOT NULL,
    AdresseCiviqueEtudiant          NUMBER(10),

    CONSTRAINT FK_ADRESSE_ETUDIANT FOREIGN KEY (AdresseCiviqueEtudiant) REFERENCES Etudiants (IdEtudiant)
);

-- Cours
CREATE TABLE Cours (
    IdCours                         NUMBER(10)      PRIMARY KEY,
    CoursTitre                      VARCHAR2(100)   NOT NULL,
    CoursSigle                      VARCHAR2(7)     NOT NULL,
    CoursDescription                VARCHAR2(200),
    CoursAdresseSiteWeb             VARCHAR2(100),
    CoursNbCredits                  NUMBER(5),
    CoursNbHeuresCours              NUMBER(5),
    CoursNbHeuresLabo               NUMBER(5),
    CoursNbHeuresPerso              NUMBER(5),

    CONSTRAINT CHK_COURS_NBCREDITS CHECK (CoursNbCredits > 0)
);

-- CoursEnseignes
CREATE TABLE CoursEnseignes (
    IdCoursEnseigne                 NUMBER(10)      PRIMARY KEY,
    CoursEnseigneSession            NUMBER(4),
    CoursEnseigneGroupe             NUMBER(4),
    CourEnseigneEnseignant          NUMBER(10),
    CourEnseigneCours               NUMBER(10),

    CONSTRAINT FK_COURSENSEIGNES_ENSEIGNANT FOREIGN KEY (CourEnseigneEnseignant) REFERENCES Enseignants (IdEnseignant),
    CONSTRAINT FK_COURSENSEIGNES_COURS FOREIGN KEY (CourEnseigneCours) REFERENCES Cours (IdCours)
);

-- Inscriptions (associations étudiant <-> cours enseigné)
CREATE TABLE Inscriptions (
    IdEtudiant                      NUMBER(10)      NOT NULL,
    IdCoursEnseigne                 NUMBER(10)      NOT NULL,
    EtudiantCoursStatut             VARCHAR2(2),
    
    CONSTRAINT PK_INSCRIPTIONS PRIMARY KEY (IdEtudiant, IdCoursEnseigne),
    CONSTRAINT FK_INSCRIPTIONS_ETUDIANT FOREIGN KEY (IdEtudiant) REFERENCES Etudiants (IdEtudiant),
    CONSTRAINT FK_INSCRIPTIONS_COURSENSEIGNE FOREIGN KEY (IdCoursEnseigne) REFERENCES CoursEnseignes (IdCoursEnseigne),
    CONSTRAINT CHK_INSCRIPTIONS_STATUT CHECK (EtudiantCoursStatut IN ('A+','A','A-','B+','B','B-','C+','C','C-','D+','D','S','E','I','X','Y','Z'))
);

-- Activités d'apprentissage
CREATE TABLE ActivitesApprentissage (
    IdActivite                      NUMBER(10)      PRIMARY KEY,
    ActiviteCours                   NUMBER(10),
    ActiviteType                    VARCHAR2(20),
    ActiviteJourSemaine             NUMBER(1),
    ActiviteHeure                   DATE,
    ActiviteLocal                   VARCHAR2(7),

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

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
    EnseignantNumPoste              NUMBER(4)      NOT NULL,
    EnseignantAdresseCivique        VARCHAR2(100)   NOT NULL,
    EnseignantCourriel              VARCHAR2(100)   NOT NULL,
    EnseignantDepartement           NUMBER(10)      NOT NULL,
    
    CONSTRAINT FK_ENSEIGNANT_PERSONNE FOREIGN KEY (IdEnseignant) REFERENCES Personnes (IdPersonne),
    CONSTRAINT FK_ENSEIGNANT_DEPT FOREIGN KEY (EnseignantDepartement) REFERENCES Departements (IdDepartement),
    CONSTRAINT CHK_ENSEIGNANT_STATUT CHECK (EnseignantStatutEnseignant IN (0,1,2,3,4)),
    CONSTRAINT CHK_ENSEIGNANT_LOCAL_FORMAT CHECK (REGEXP_LIKE(EnseignantNumLocal, '^[A-G][0-9]-[1-4][0-9]{3}$')),
    CONSTRAINT CHK_ENSEIGNANT_POSTE CHECK (EnseignantNumPoste BETWEEN 0 AND 9999)
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

    CONSTRAINT CHK_COURS_NBCREDITS CHECK (CoursNbCredits > 0),
    CONSTRAINT CHK_COURS_SIGLE_FORMAT CHECK (REGEXP_LIKE(CoursSigle, '^[0-9]+[A-Z]{3}[0-9]{3}$')),
    CONSTRAINT CHK_COURS_NBHEURES_COURS CHECK (CoursNbHeuresCours > 0),
    CONSTRAINT CHK_COURS_NBHEURES_LABO CHECK (CoursNbHeuresLabo > 0),
    CONSTRAINT CHK_COURS_NBHEURES_PERSO CHECK (CoursNbHeuresPerso > 0)
);

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


-- Le directeur d'un département doit être un enseignant appartenant à ce département
CREATE OR REPLACE TRIGGER TRG_DEPT_DIRECTEUR_ENSEIGNANT
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


-- Un departement doit avoir un directeur si un cours est donné 
CREATE OR REPLACE TRIGGER TRG_DEPT_DIRECTEUR_REQUIS
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


-- Limite de 6 cours par enseignants
CREATE OR REPLACE TRIGGER TRG_ENSEIGNANT_LIMITE_COURS
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


-- Annule toute les inscriptions a un cours si moins de 8 inscrits
-- TODO: vérifier si on peut ajouter des inscriptions a la base
CREATE OR REPLACE TRIGGER TRG_INSCRIPTION_STATUT_AUTO
FOR INSERT, DELETE ON Inscriptions
COMPOUND TRIGGER

    -- Collection pour stocker les IdCoursEnseigne affectés
    TYPE t_cours_id IS TABLE OF CoursEnseignes.IdCoursEnseigne%TYPE INDEX BY PLS_INTEGER;
    g_cours_affectes t_cours_id;

-- 1. Se déclenche APRÈS chaque ligne modifiée (INSERT ou DELETE)
AFTER EACH ROW IS
BEGIN
    -- Stocker l'ID du cours affecté.
    IF INSERTING THEN
        g_cours_affectes(g_cours_affectes.COUNT + 1) := :NEW.IdCoursEnseigne;
    ELSIF DELETING THEN
        g_cours_affectes(g_cours_affectes.COUNT + 1) := :OLD.IdCoursEnseigne;
    END IF;
END AFTER EACH ROW;

-- 2. Se déclenche UNE SEULE FOIS après la fin de TOUTE la transaction
AFTER STATEMENT IS
    v_nb_inscrits NUMBER;
    v_id_cours_traite NUMBER;
BEGIN
    -- S'il n'y a rien à faire
    IF g_cours_affectes.COUNT = 0 THEN
        RETURN;
    END IF;

    -- 3. Boucler sur tous les cours qui ont été modifiés
    FOR i IN 1 .. g_cours_affectes.COUNT
    LOOP
        v_id_cours_traite := g_cours_affectes(i);

        -- Compter le nombre total d'inscrits pour CE cours
        SELECT COUNT(*) INTO v_nb_inscrits
        FROM Inscriptions
        WHERE IdCoursEnseigne = v_id_cours_traite;

        -- Appliquer la nouvelle règle d'affaire
        IF v_nb_inscrits < 8 THEN
            -- ANNULATION : Mettre toutes les inscriptions à 'Z'
            UPDATE Inscriptions
            SET EtudiantCoursStatut = 'Z'
            WHERE IdCoursEnseigne = v_id_cours_traite;
        ELSE
            -- RÉACTIVATION : Si le cours n'est plus annulé,
            -- on réinitialise les statuts 'Z' à ' ' (en cours)
            UPDATE Inscriptions
            SET EtudiantCoursStatut = ' '
            WHERE IdCoursEnseigne = v_id_cours_traite
              AND EtudiantCoursStatut = 'Z';
        END IF;
    END LOOP;

END TRG_INSCRIPTION_STATUT_AUTO;
/


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

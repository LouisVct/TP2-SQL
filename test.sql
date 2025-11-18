-- Supressions des sequences existantes
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_DEPARTEMENTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_PERSONNES'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/

-- Création de toute les sequences
CREATE SEQUENCE SEQ_DEPARTEMENTS START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_PERSONNES START WITH 1 INCREMENT BY 1;

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

    -- Insérer dans la table Enseignants avec la même clé
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
-- Supressions des sequences existantes
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_DEPARTEMENTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/

-- Création de toute les sequences
CREATE SEQUENCE SEQ_DEPARTEMENTS START WITH 1 INCREMENT BY 1;

-- Procédure de création d'un département
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

-- Procédure d'assignation d'un directeur à un département
CREATE OR REPLACE PROCEDURE P_ASSIGNER_DIRECTEUR_DEPARTEMENT (
    d_idDepartement IN NUMBER,
    d_idEnseignant  IN NUMBER
) IS
BEGIN
    UPDATE Departements SET DepartementDirecteur = d_idEnseignant WHERE IdDepartement = d_idDepartement;
    COMMIT;
END;
/


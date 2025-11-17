-- Création des utilisateurs pour Oracle Express 11g
-- À exécuter en tant que SYSTEM ou SYS AVANT la création des tables

-- =====================================================
-- 1. UTILISATEUR ADMINISTRATEUR/DBA
-- =====================================================

-- Supprimer l'utilisateur s'il existe déjà
BEGIN
    EXECUTE IMMEDIATE 'DROP USER tp2_admin CASCADE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1918 THEN
            RAISE;
        END IF;
END;
/

-- Créer l'utilisateur administrateur
CREATE USER tp2_admin 
IDENTIFIED BY Admin123
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON USERS;

-- Accorder tous les privilèges à l'administrateur
GRANT CONNECT TO tp2_admin;
GRANT RESOURCE TO tp2_admin;
GRANT DBA TO tp2_admin;
GRANT CREATE SESSION TO tp2_admin;
GRANT CREATE TABLE TO tp2_admin;
GRANT CREATE SEQUENCE TO tp2_admin;
GRANT CREATE PROCEDURE TO tp2_admin;
GRANT CREATE TRIGGER TO tp2_admin;
GRANT CREATE VIEW TO tp2_admin;
GRANT CREATE SYNONYM TO tp2_admin;
GRANT UNLIMITED TABLESPACE TO tp2_admin;

-- =====================================================
-- 2. UTILISATEUR STANDARD (LECTURE SEULE)
-- =====================================================

-- Supprimer l'utilisateur s'il existe déjà
BEGIN
    EXECUTE IMMEDIATE 'DROP USER tp2_user CASCADE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1918 THEN
            RAISE;
        END IF;
END;
/

-- Créer l'utilisateur standard
CREATE USER tp2_user 
IDENTIFIED BY User123
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA 0 ON USERS;

-- Accorder seulement les privilèges de connexion
GRANT CONNECT TO tp2_user;
GRANT CREATE SESSION TO tp2_user;

COMMIT;

-- =====================================================
-- ÉTAPE SUIVANTE
-- =====================================================
/*
MAINTENANT :
1. Connectez-vous comme tp2_admin : sqlplus tp2_admin/Admin123@xe
2. Exécutez cretab.sql pour créer les tables
3. Exécutez user2.sql pour donner les privilèges à tp2_user
*/
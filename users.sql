-- créer l'utilisateur administrateur qui créera les tables et procédures
CREATE USER tp2admin IDENTIFIED BY mdp
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

-- créer l'utilisateur lecture seule
CREATE USER tp2user IDENTIFIED BY mdp
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA 0 ON USERS;

GRANT DBA TO tp2admin;

GRANT CREATE SESSION TO tp2user;
CREATE ROLE tp2_readonly;
GRANT tp2_readonly TO tp2user;

-- exemple, si tp2admin a créé les tables EMPLOYES et PROJETS
-- GRANT SELECT ON tp2admin.Cours TO tp2_readonly;

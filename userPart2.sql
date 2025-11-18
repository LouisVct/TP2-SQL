-- Attribution des privilèges sur les tables existantes
-- À exécuter en tant que tp2_admin APRÈS avoir créé les tables avec cretab.sql

-- =====================================================
-- PRIVILÈGES DE LECTURE POUR L'UTILISATEUR STANDARD
-- =====================================================

-- Accorder les privilèges SELECT sur toutes les tables
GRANT SELECT ON Personnes TO tp2_user;
GRANT SELECT ON Departements TO tp2_user;
GRANT SELECT ON Enseignants TO tp2_user;
GRANT SELECT ON Etudiants TO tp2_user;
GRANT SELECT ON AdresseCivique TO tp2_user;
GRANT SELECT ON Cours TO tp2_user;
GRANT SELECT ON CoursEnseignes TO tp2_user;
GRANT SELECT ON Inscriptions TO tp2_user;
GRANT SELECT ON ActivitesApprentissage TO tp2_user;
GRANT SELECT ON CoursPrealables TO tp2_user;

COMMIT;

-- =====================================================
-- TESTS POUR LE RAPPORT
-- =====================================================
/*
PROCÉDURE SIMPLE QUI MARCHE :

1. Exécuter userPart1.sql en tant que SYSTEM/SYS
2. Exécuter cretab.sql + data.sql en tant que tp2_admin  
3. Exécuter userPart2.sql en tant que tp2_admin
4. Se connecter en tant que tp2_user et tester

TESTS avec tp2_user :

1. Connectez-vous : sqlplus tp2_user/User123@xe

2. Test lecture (UTILISER tp2_admin.NomTable) :
   SELECT COUNT(*) FROM tp2_admin.Cours;
   SELECT * FROM tp2_admin.Departements;

3. Test insertion (DOIT ÉCHOUER avec ORA-01031) :
   INSERT INTO tp2_admin.Cours VALUES (999, 'Test', '9TST999', 'Test', NULL, 1, 15, 0, 30);

C'EST TOUT ! Ça marche, c'est simple, on utilise juste tp2_admin.NomTable
*/
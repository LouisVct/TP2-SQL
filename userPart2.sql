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

-- Créer des synonymes publics pour faciliter l'accès
-- (optionnel - permet à tp2_user d'utiliser juste "Cours" au lieu de "tp2_admin.Cours")
CREATE PUBLIC SYNONYM Personnes FOR tp2_admin.Personnes;
CREATE PUBLIC SYNONYM Departements FOR tp2_admin.Departements;
CREATE PUBLIC SYNONYM Enseignants FOR tp2_admin.Enseignants;
CREATE PUBLIC SYNONYM Etudiants FOR tp2_admin.Etudiants;
CREATE PUBLIC SYNONYM AdresseCivique FOR tp2_admin.AdresseCivique;
CREATE PUBLIC SYNONYM Cours FOR tp2_admin.Cours;
CREATE PUBLIC SYNONYM CoursEnseignes FOR tp2_admin.CoursEnseignes;
CREATE PUBLIC SYNONYM Inscriptions FOR tp2_admin.Inscriptions;
CREATE PUBLIC SYNONYM ActivitesApprentissage FOR tp2_admin.ActivitesApprentissage;
CREATE PUBLIC SYNONYM CoursPrealables FOR tp2_admin.CoursPrealables;

COMMIT;

-- =====================================================
-- TESTS POUR LE RAPPORT
-- =====================================================
/*
Maintenant vous pouvez tester avec tp2_user :

1. Connectez-vous : sqlplus tp2_user/User123@xe

2. Test lecture (DOIT FONCTIONNER) :
   SELECT * FROM Cours;

3. Test insertion cours (DOIT ÉCHOUER) :
   INSERT INTO Cours VALUES (1, 'Test', '8INF111', 'Description test', NULL, 3, 45, 0, 90);

4. Test insertion enseignant (DOIT ÉCHOUER) :
   INSERT INTO Enseignants VALUES (1, SYSDATE, 1, 'P1-1001', 1234, '123 Rue Test', 'test@uqac.ca', 1);
*/
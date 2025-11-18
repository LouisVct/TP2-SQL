-- Création des synonymes pour tp2_user
-- À exécuter en tant que tp2_user APRÈS avoir reçu les privilèges

-- =====================================================
-- CRÉATION DES SYNONYMES PRIVÉS
-- =====================================================
-- Ces commandes permettent à tp2_user d'utiliser les noms de tables
-- sans préfixe (ex: "SELECT * FROM Cours" au lieu de "SELECT * FROM tp2_admin.Cours")

CREATE SYNONYM Personnes FOR tp2_admin.Personnes;
CREATE SYNONYM Departements FOR tp2_admin.Departements;
CREATE SYNONYM Enseignants FOR tp2_admin.Enseignants;
CREATE SYNONYM Etudiants FOR tp2_admin.Etudiants;
CREATE SYNONYM AdresseCivique FOR tp2_admin.AdresseCivique;
CREATE SYNONYM Cours FOR tp2_admin.Cours;
CREATE SYNONYM CoursEnseignes FOR tp2_admin.CoursEnseignes;
CREATE SYNONYM Inscriptions FOR tp2_admin.Inscriptions;
CREATE SYNONYM ActivitesApprentissage FOR tp2_admin.ActivitesApprentissage;
CREATE SYNONYM CoursPrealables FOR tp2_admin.CoursPrealables;

COMMIT;

-- =====================================================
-- TESTS POUR VÉRIFIER L'ACCÈS
-- =====================================================

-- Test 1: Lister les tables accessibles
SELECT table_name FROM user_synonyms WHERE table_name IN 
    ('PERSONNES', 'DEPARTEMENTS', 'ENSEIGNANTS', 'ETUDIANTS', 'COURS');

-- Test 2: Lire une table (DOIT FONCTIONNER)
SELECT COUNT(*) as "Nombre de cours" FROM Cours;

-- Test 3: Lire avec jointure (DOIT FONCTIONNER)
SELECT d.DepartementNom, COUNT(c.IdCours) as NbCours
FROM Departements d
LEFT JOIN Enseignants e ON d.IdDepartement = e.EnseignantDepartement
LEFT JOIN CoursEnseignes ce ON e.IdEnseignant = ce.CourEnseigneEnseignant
LEFT JOIN Cours c ON ce.CourEnseigneCours = c.IdCours
GROUP BY d.DepartementNom;

-- Test 4: Insertion (DOIT ÉCHOUER avec ORA-01031: insufficient privileges)
-- INSERT INTO Cours VALUES (999, 'Test', '8TST999', 'Test', NULL, 1, 15, 0, 30);
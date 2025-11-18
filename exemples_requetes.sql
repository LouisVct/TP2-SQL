-- EXEMPLES DE REQUÊTES POUR TESTER LES PERMISSIONS
-- Après avoir exécuté userPart1.sql, cretab.sql, data.sql, userPart2.sql 
-- ET créé les synonymes manuellement

-- =====================================================
-- 1. TESTS AVEC tp2_user (LECTURE SEULE)
-- =====================================================
-- À exécuter après connexion : sqlplus tp2_user/User123@xe

-- ÉTAPE 1: Créer les synonymes manuellement (une seule fois)
/*
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
*/

-- ÉTAPE 2: Tests de lecture

-- Test 1: Vérifier les synonymes créés
SELECT table_name FROM user_synonyms ORDER BY table_name;

-- Test 2: Lister tous les cours (DOIT FONCTIONNER)
SELECT CoursTitre, CoursSigle, CoursNbCredits 
FROM Cours 
ORDER BY CoursSigle;

-- Test 3: Voir les départements et leurs directeurs (DOIT FONCTIONNER)
SELECT d.DepartementNom, 
       p.PersonnePrenom || ' ' || p.PersonneNom as DirecteurNom
FROM Departements d
LEFT JOIN Enseignants e ON d.DepartementDirecteur = e.IdEnseignant
LEFT JOIN Personnes p ON e.IdEnseignant = p.IdPersonne;

-- Test 4: Compter les cours par département (DOIT FONCTIONNER)
SELECT d.DepartementNom, COUNT(c.IdCours) as NombreCours
FROM Departements d
LEFT JOIN Enseignants e ON d.IdDepartement = e.EnseignantDepartement
LEFT JOIN CoursEnseignes ce ON e.IdEnseignant = ce.CourEnseigneEnseignant
LEFT JOIN Cours c ON ce.CourEnseigneCours = c.IdCours
GROUP BY d.DepartementNom
ORDER BY d.DepartementNom;

-- Test 5: Lister tous les enseignants avec leurs infos (DOIT FONCTIONNER)
SELECT p.PersonnePrenom || ' ' || p.PersonneNom as NomComplet,
       d.DepartementNom,
       e.EnseignantNumLocal,
       e.EnseignantNumPoste
FROM Enseignants e
JOIN Personnes p ON e.IdEnseignant = p.IdPersonne
JOIN Departements d ON e.EnseignantDepartement = d.IdDepartement
ORDER BY d.DepartementNom, p.PersonneNom;

-- Test 6: Requête avec jointure multiple (DOIT FONCTIONNER)
SELECT c.CoursTitre,
       c.CoursSigle,
       p.PersonnePrenom || ' ' || p.PersonneNom as Enseignant,
       d.DepartementNom
FROM Cours c
JOIN CoursEnseignes ce ON c.IdCours = ce.CourEnseigneCours
JOIN Enseignants e ON ce.CourEnseigneEnseignant = e.IdEnseignant
JOIN Personnes p ON e.IdEnseignant = p.IdPersonne
JOIN Departements d ON e.EnseignantDepartement = d.IdDepartement
ORDER BY d.DepartementNom, c.CoursSigle;

-- =====================================================
-- 2. TESTS D'INSERTION (DOIVENT ÉCHOUER)
-- =====================================================

-- Test 7: Tentative d'insertion dans Cours (DOIT ÉCHOUER avec ORA-01031)
-- INSERT INTO Cours VALUES (999, 'Cours Test', '9TST999', 'Test description', NULL, 1, 15, 0, 30);

-- Test 8: Tentative d'insertion dans Departements (DOIT ÉCHOUER avec ORA-01031)
-- INSERT INTO Departements VALUES (999, 'Test Dept', 999, NULL);

-- Test 9: Tentative de modification (DOIT ÉCHOUER avec ORA-01031)
-- UPDATE Cours SET CoursTitre = 'Nouveau titre' WHERE IdCours = 1;

-- Test 10: Tentative de suppression (DOIT ÉCHOUER avec ORA-01031)
-- DELETE FROM Cours WHERE IdCours = 1;

-- =====================================================
-- 3. TESTS AVEC PRÉFIXE SCHEMA (ALTERNATIVE)
-- =====================================================

-- Ces requêtes fonctionnent même SANS les synonymes
-- En utilisant le préfixe tp2_admin.

SELECT COUNT(*) as "Total cours" FROM tp2_admin.Cours;

SELECT d.DepartementNom, COUNT(*) as NbEnseignants
FROM tp2_admin.Departements d
LEFT JOIN tp2_admin.Enseignants e ON d.IdDepartement = e.EnseignantDepartement
GROUP BY d.DepartementNom;

-- =====================================================
-- 4. TESTS DE VÉRIFICATION DES PERMISSIONS
-- =====================================================

-- Voir quelles tables sont accessibles
SELECT table_name 
FROM all_tables 
WHERE owner = 'TP2_ADMIN' 
ORDER BY table_name;

-- Voir les privilèges accordés
SELECT table_name, privilege 
FROM user_tab_privs 
WHERE grantor = 'TP2_ADMIN'
ORDER BY table_name, privilege;

-- =====================================================
-- RÉSULTATS ATTENDUS :
-- =====================================================
/*
✅ Tests 1-6 : SUCCÈS (lecture autorisée)
❌ Tests 7-10 : ÉCHEC avec "ORA-01031: insufficient privileges" (normal!)
✅ Tests avec tp2_admin. : SUCCÈS (accès avec préfixe schema)
✅ Tests de vérification : SUCCÈS (voir les permissions)

SOLUTION MANUELLE - AVANTAGES :
- Un seul fichier userPart2.sql à gérer
- Instructions claires dans les commentaires
- Pas de fichier userSynonyms.sql séparé
- Plus simple pour les étudiants

SI UN TEST DE LECTURE ÉCHOUE :
- Vérifiez que userPart2.sql a bien été exécuté par tp2_admin
- Vérifiez que vous avez créé les synonymes manuellement en tant que tp2_user
- Vérifiez la connexion : vous devez être connecté en tant que tp2_user
*/
-- TEST DIAGNOSTIQUE ORACLE XE 11g
-- À exécuter en tant que tp2_user pour vérifier les accès

-- =====================================================
-- TESTS DE DIAGNOSTIC
-- =====================================================

-- 1. Vérifier la connexion utilisateur
SELECT USER as "Utilisateur connecté", SYSDATE as "Date connexion" FROM DUAL;

-- 2. Lister les tables du propriétaire tp2_admin accessibles
SELECT table_name as "Tables TP2_ADMIN" 
FROM all_tables 
WHERE owner = 'TP2_ADMIN' 
ORDER BY table_name;

-- 3. Vérifier les privilèges accordés
SELECT table_name, privilege, grantable
FROM user_tab_privs 
WHERE grantor = 'TP2_ADMIN'
ORDER BY table_name, privilege;

-- 4. Vérifier les synonymes publics disponibles
SELECT synonym_name as "Synonymes publics", table_owner, table_name
FROM all_synonyms 
WHERE table_owner = 'TP2_ADMIN' 
  AND owner = 'PUBLIC'
ORDER BY synonym_name;

-- 5. Vérifier les synonymes privés de l'utilisateur
SELECT synonym_name as "Synonymes privés", table_owner, table_name
FROM user_synonyms
ORDER BY synonym_name;

-- =====================================================
-- TESTS DE LECTURE (DOIVENT FONCTIONNER)
-- =====================================================

-- Test 6: Lecture avec préfixe schema (doit toujours fonctionner)
SELECT COUNT(*) as "Nombre de cours (avec préfixe)" FROM tp2_admin.Cours;

-- Test 7: Lecture sans préfixe (fonctionne si synonymes créés)
SELECT COUNT(*) as "Nombre de cours (sans préfixe)" FROM Cours;

-- Test 8: Lecture simple des départements
SELECT DepartementNom, DepartementNum FROM Departements ORDER BY DepartementNum;

-- Test 9: Jointure simple
SELECT d.DepartementNom, COUNT(*) as NbEnseignants
FROM Departements d
LEFT JOIN Enseignants e ON d.IdDepartement = e.EnseignantDepartement
GROUP BY d.DepartementNom
ORDER BY d.DepartementNom;

-- =====================================================
-- TESTS D'ÉCRITURE (DOIVENT ÉCHOUER)
-- =====================================================

-- Test 10: Insertion (doit échouer avec ORA-01031)
-- INSERT INTO Cours VALUES (999, 'Test', '9TST999', 'Test description', NULL, 1, 15, 0, 30);

-- Test 11: Mise à jour (doit échouer avec ORA-01031)
-- UPDATE Cours SET CoursTitre = 'Nouveau titre' WHERE IdCours = 1;

-- Test 12: Suppression (doit échouer avec ORA-01031)
-- DELETE FROM Cours WHERE IdCours = 1;

-- =====================================================
-- ANALYSE DES RÉSULTATS
-- =====================================================
/*
RÉSULTATS ATTENDUS pour Oracle XE 11g :

✅ Tests 1-5 : SUCCÈS (informations sur l'environnement)
✅ Tests 6-9 : SUCCÈS (lecture autorisée)
❌ Tests 10-12 : ÉCHEC avec "ORA-01031: insufficient privileges" (normal)

SI LES TESTS 6-9 ÉCHOUENT :
1. Vérifiez que userPart1.sql a été exécuté par SYSTEM
2. Vérifiez que cretab.sql + data.sql ont été exécutés par tp2_admin
3. Vérifiez que userPart2.sql a été exécuté par tp2_admin
4. Reconnectez-vous en tant que tp2_user

SI LE TEST 7 ÉCHOUE MAIS LE TEST 6 FONCTIONNE :
- Les synonymes publics n'ont pas été créés
- Utilisez tp2_admin.TableName au lieu de TableName

COMMANDES DE RÉCUPÉRATION si nécessaire :
-- En tant que tp2_admin, créer manuellement les synonymes :
-- CREATE PUBLIC SYNONYM Cours FOR tp2_admin.Cours;
-- CREATE PUBLIC SYNONYM Departements FOR tp2_admin.Departements;
-- ... etc
*/
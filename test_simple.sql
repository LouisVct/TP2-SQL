-- TEST RAPIDE ET SIMPLE
-- À exécuter en tant que tp2_user

-- Vérifier la connexion
SELECT USER as "Utilisateur", SYSDATE as "Date" FROM DUAL;

-- Test de lecture (DOIT MARCHER)
SELECT COUNT(*) as "Nombre de cours" FROM tp2_admin.Cours;

-- Lister les départements (DOIT MARCHER)  
SELECT DepartementNom, DepartementNum FROM tp2_admin.Departements;

-- Test jointure simple (DOIT MARCHER)
SELECT d.DepartementNom, COUNT(e.IdEnseignant) as NbEnseignants
FROM tp2_admin.Departements d
LEFT JOIN tp2_admin.Enseignants e ON d.IdDepartement = e.EnseignantDepartement
GROUP BY d.DepartementNom;

-- Test insertion (DOIT ÉCHOUER avec ORA-01031)
-- INSERT INTO tp2_admin.Cours VALUES (999, 'Test', '9TST999', 'Test', NULL, 1, 15, 0, 30);

-- C'EST TOUT ! Si ça marche, c'est bon pour ton rendu !
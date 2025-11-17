CREATE VIEW VueDepartementsComplets AS
SELECT 
    d.IdDepartement, --peux être retiré si inutile
    d.DepartementNom,
    d.DepartementNum,
    d.DepartementDirecteur AS IdDirecteur,--peux être retiré si inutile
    p.PersonneNom AS DirecteurNom,
    p.PersonnePrenom AS DirecteurPrenom
FROM Departements d
LEFT JOIN Enseignants e ON d.DepartementDirecteur = e.IdEnseignant
LEFT JOIN Personnes p ON e.IdEnseignant = p.IdPersonne;
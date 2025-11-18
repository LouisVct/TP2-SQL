-- RUFFAULT--RAVENEL Gémino
-- VICAT Louis

--------------------------------------------
----------- INSERTION DES DONNEES ----------
--------------------------------------------

EXEC P_CREATE_DEPARTEMENT('Informatique', 420);
EXEC P_CREATE_DEPARTEMENT('Genie Electrique', 243);

EXEC P_CREATE_ENSEIGNANT('Tremblay', 'Jean', 123456789012345, 'jean.tremblay@cegep.qc.ca', '514-555-0001', DATE '1975-03-15', 3, 'A1-1001', 1001, '123 Rue Principale, Montreal', 'jean.tremblay@cegep.qc.ca', 1);

EXEC P_CREATE_ENSEIGNANT('Lavoie', 'Marie', 234567890123456, 'marie.lavoie@cegep.qc.ca', '514-555-0002', DATE '1980-07-22', 2, 'A2-2002', 1002, '456 Boulevard Saint-Laurent, Montreal', 'marie.lavoie@cegep.qc.ca', 1);

EXEC P_CREATE_ENSEIGNANT('Bouchard', 'Pierre', 345678901234567, 'pierre.bouchard@cegep.qc.ca', '514-555-0003', DATE '1970-11-08', 4, 'B1-3001', 1003, '789 Avenue du Parc, Montreal', 'pierre.bouchard@cegep.qc.ca', 2);

EXEC P_CREATE_ENSEIGNANT('Gagnon', 'Louise', 456789012345678, 'louise.gagnon@cegep.qc.ca', '514-555-0004', DATE '1985-02-14', 1, 'B2-4002', 1004, '321 Rue Sherbrooke, Montreal', 'louise.gagnon@cegep.qc.ca', 2);

EXEC P_DEP_ASSIGN_DIR(1, 1);

EXEC P_DEP_ASSIGN_DIR(2, 3);

EXEC P_CREATE_COURS('Introduction a la programmation', '4INF101', 'Concepts de base de la programmation orientee objet en Java', 'https://inf101.cegep.qc.ca', 3, 45, 30, 90);

EXEC P_CREATE_COURS('Structures de donnees', '4INF201', 'Etude des structures de donnees fondamentales et des algorithmes', 'https://inf201.cegep.qc.ca', 3, 45, 30, 90);

EXEC P_CREATE_COURS('Base de donnees relationnelles', '4INF301', 'Conception et manipulation de bases de donnees avec SQL', 'https://inf301.cegep.qc.ca', 4, 60, 30, 120);

EXEC P_CREATE_COURS('Developpement Web', '4INF401', 'Creation d''applications web avec HTML, CSS, JavaScript', 'https://inf401.cegep.qc.ca', 3, 45, 45, 90);

EXEC P_CREATE_COURS('Genie logiciel', '4INF501', 'Methodologies de developpement et gestion de projets logiciels', 'https://inf501.cegep.qc.ca', 4, 60, 15, 120);

EXEC P_CREATE_COURS('Circuits electriques', '2ELE101', 'Analyse des circuits electriques en courant continu et alternatif', 'https://ele101.cegep.qc.ca', 4, 60, 30, 120);

EXEC P_CREATE_COURS('Electronique analogique', '2ELE201', 'Etude des composants et circuits electroniques analogiques', 'https://ele201.cegep.qc.ca', 3, 45, 45, 90);

EXEC P_CREATE_COURS('Systemes numeriques', '2ELE301', 'Conception et analyse de systemes numeriques', 'https://ele301.cegep.qc.ca', 3, 45, 30, 90);

EXEC P_CREATE_COURS('Microprocesseurs', '2ELE401', 'Programmation et interfacage de microprocesseurs', 'https://ele401.cegep.qc.ca', 4, 45, 60, 120);

EXEC P_CREATE_COURS('Automatisation industrielle', '2ELE501', 'Systemes d''automatisation et controle industriel', 'https://ele501.cegep.qc.ca', 4, 60, 45, 120);

COMMIT;

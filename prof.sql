-- Script SQL Oracle de cr�ation de deux types avec relation 1-n bidirectionnelles
-- Suppression du sch�ma
DROP TABLE Livre 
/
DROP TABLE Editeur 
/
DROP TYPE tableRefLivresType FORCE
/
DROP TYPE LivreRefType 
/
DROP TYPE LivreType 
/
DROP TYPE EditeurType
/
DROP TYPE TypeDonn�esAnn�e
/
DROP TABLE Utilisateur
/
DROP TYPE UtilisateurType
/
DROP TYPE PersonneType
/

-- Cr�ation du sch�ma
CREATE OR REPLACE TYPE TypeDonn�esAnn�e AS OBJECT
(valeurAnn�e	INTEGER)
/
CREATE OR REPLACE TYPE EditeurType
/
CREATE TYPE LivreType AS OBJECT
(ISBN				CHAR(13),
 titre			VARCHAR(50),
 ann�eParution		TypeDonn�esAnn�e,
 �diteur			REF EditeurType
)
/
CREATE OR REPLACE TYPE LivreRefType AS OBJECT
(livreRef	REF	LivreType)
/
CREATE TYPE tableRefLivresType AS
TABLE OF LivreRefType
/
CREATE OR REPLACE TYPE EditeurType AS OBJECT
(nomEditeur 		VARCHAR(20),
 ville 			VARCHAR(20),
 lesLivres			tableRefLivresType
)
/
CREATE TABLE Editeur OF EditeurType
(PRIMARY KEY(nomEditeur))
NESTED TABLE lesLivres STORE AS tableLesLivres
/
CREATE TABLE Livre OF LivreType
(PRIMARY KEY(ISBN),
CONSTRAINT ann�eSup0 CHECK(ann�eParution.valeurAnn�e > 0),
CONSTRAINT referenceTableEditeur �diteur SCOPE IS Editeur)
/
-- Insertion de deux �diteurs 
INSERT INTO Editeur VALUES
 	('Pearsons', 'Ontario',tableRefLivresType())
/
INSERT INTO Editeur VALUES
 	('Addison-Wesley', 'Reading, MA',tableRefLivresType())
/
-- Insertion de livres
INSERT INTO Livre
SELECT '0-201-12227-8', 'Automatic Text Processing',
 	TypeDonn�esAnn�e(1989), REF(e)
	FROM Editeur e WHERE nomEditeur = 'Addison-Wesley'
/
INSERT INTO THE
 	(SELECT e.lesLivres FROM Editeur e 
 	 WHERE e.nomEditeur = 'Addison-Wesley')
	SELECT REF(l) FROM Livre l 
 	WHERE l.ISBN = '0-201-12227-8'
/
INSERT INTO Livre
SELECT '0-8053-1755-4', 'Fundamentals of Database Systems',
 	TypeDonn�esAnn�e(2000), REF(e)
	FROM Editeur e WHERE nomEditeur = 'Addison-Wesley'
/
INSERT INTO THE
 	(SELECT e.lesLivres FROM Editeur e 
 	 WHERE e.nomEditeur = 'Addison-Wesley')
	SELECT REF(l) FROM Livre l 
 	WHERE l.ISBN = '0-8053-1755-4'
/
-- Exemples de requ�tes
SELECT l.�diteur.nomEditeur, l.ISBN
FROM Livre l
WHERE l.�diteur.ville = 'Reading, MA'
/
SELECT livres.livreRef.ISBN, livres.livreRef.titre
FROM THE 
(SELECT e.lesLivres FROM Editeur e WHERE nomEditeur = 'Addison-Wesley') livres
/
CREATE TYPE PersonneType AS OBJECT
(nom		VARCHAR(10),
 pr�nom 	VARCHAR(10)) NOT FINAL
/
CREATE TYPE UtilisateurType UNDER PersonneType
(idUtilisateur		VARCHAR(10),
 motPasse		VARCHAR(10),
 cat�gorieUtilisateur	VARCHAR(14))
/
CREATE TABLE Utilisateur OF UtilisateurType
/
INSERT INTO Utilisateur VALUES('Marshal', 'Amanda', 1,'cocorico','membre')
/
INSERT INTO Utilisateur VALUES('Degas', 'Edgar', 2,'cocorico','membre')
/
INSERT INTO Utilisateur VALUES('Lecommis', 'Coco', 3,'cocorico','employ�')
/
INSERT INTO Utilisateur VALUES('Lecommis', 'Toto', 4,'cocorico','employ�')
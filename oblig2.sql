-- Oppgave 1 gikk helt fint.

-- Oppgave 2
-- a - Fjernet join.
SELECT Navn
FROM Planet
WHERE Stjerne = 'Proxima Centauri';

-- b - Fjernet join.
SELECT DISTINCT Oppdaget
FROM Planet
WHERE Stjerne = 'TRAPPIST-1' OR Stjerne = 'Kepler-154';

-- c - Implementert retter sitt forslag.
SELECT COUNT(*) AS antall_null_verdier
FROM Planet
WHERE Masse IS NULL;

-- d - Uforandret
SELECT Navn, Masse
FROM Planet
WHERE Oppdaget = 2020 AND Masse > (SELECT AVG(Masse) FROM Planet);

-- e - Uforandret
SELECT MAX(Oppdaget) - MIN(Oppdaget) AS "Antall aar"
FROM Planet;


-- Oppgave 3
-- a - Uforandret
SELECT Navn
FROM Planet AS p, Materie AS m
WHERE m.Planet = p.Navn AND p.Masse > 3 AND p.Masse < 10 AND m.Molekyl = 'H2O';

-- b - Fikset soek paa molekyler, uten aa faa duplikater.
SELECT DISTINCT p.Navn
FROM Stjerne AS s 
     INNER JOIN Planet AS p ON (s.Navn = p.Stjerne)
     INNER JOIN Materie AS m ON (p.Navn = m.Planet)
WHERE Molekyl LIKE '%H%' AND Avstand < (s.Masse * 12);

-- c - Uforandret
SELECT Duo.navn1, Duo.navn2
FROM (SELECT p1.Navn AS navn1, p2.Navn AS navn2, p1.Stjerne AS stjerne1, p2.Stjerne AS stjerne2
      FROM Planet AS p1 INNER JOIN Planet AS p2 ON (p1.Navn < p2.Navn AND p1.Masse > 10 AND p2.Masse > 10)) AS Duo
      INNER JOIN Stjerne AS s ON (s.Navn = Duo.stjerne1 AND s.Navn = Duo.stjerne2)
WHERE s.Avstand < 50;


-- Oppgave 4
--  
-- Natural join brukes for aa kombinere relasjoner basert paa
-- like kolonner og datatyper. Den proever altsaa aa kombinere
-- kolonnene navn og masse respektivt hos Stjerne-relasjonen og Planet-relasjonen,
-- men siden disse kolonnene ikke inneholder lik data paa tvers av
-- relasjonene, faar man heller ingen rader ut av det.


-- Oppgave 5
-- a - Uforandret
INSERT INTO Stjerne
VALUES ('Sola', 0, 1);

-- b - Uforandret
INSERT INTO Planet
VALUES ('Jorda', 0.003146, NULL, 'Sola');


-- Oppgave 6 - Fikset "timestamp" datatype til "Tidspunkt".
CREATE TABLE Observasjon (
    Observasjons_id int PRIMARY KEY,
    Tidspunkt timestamp NOT NULL,
    Planet text NOT NULL REFERENCES Planet (Navn),
    Kommentar text
);

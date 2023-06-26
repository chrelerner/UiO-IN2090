-- Oppgave 1
SELECT p.Firstname, p.Lastname, fc.Filmcharacter
FROM Filmparticipation AS fp 
     INNER JOIN Person AS p USING (Personid) 
     INNER JOIN Film AS f USING (Filmid)
     INNER JOIN Filmcharacter AS fc USING (Partid)
WHERE f.Title = 'Star Wars' AND fp.Parttype = 'cast';


-- Oppgave 2
SELECT Country, COUNT(Filmid) AS number_of_movies
FROM Filmcountry
GROUP BY Country;


-- Oppgave 3
SELECT Country, COUNT(Time) AS average_runtime
FROM Runningtime
WHERE (Time ~ '^\d+$') AND (Country IS NOT NULL)
GROUP BY Country
HAVING COUNT(Time) >= 200;


-- Oppgave 4
-- Maatte inkludere filmid for at filmer med samme tittel ikke skal blandes.
SELECT f.Filmid, f.Title, COUNT(fg.Genre) AS number_of_genres
FROM Film AS f INNER JOIN Filmgenre AS fg USING (Filmid)
GROUP BY f.Filmid, f.title
ORDER BY number_of_genres DESC,
         f.Title
LIMIT 10;


-- Oppgave 5
-- Her antar jeg at med 'rating' saa menes det 'rank'
WITH country_allgenre_number AS ( -- Alle land, med sine sjangre og antall filmer innenfor sine sjangre.
     SELECT fc.Country, fg.Genre, COUNT(fg.filmid) AS number_of_movies
     FROM Filmcountry AS fc INNER JOIN Filmgenre AS fg USING (Filmid)
     GROUP BY fc.Country, fg.Genre
     ORDER BY fc.Country
),
country_number AS ( -- Alle land, med hoeyeste antall filmer fra en sjanger.
     SELECT Country, MAX(number_of_movies) AS number_of_movies
     FROM country_allgenre_number
     GROUP BY Country 
),
country_top_genre AS ( -- Alle land med hver sin top sjanger. Noen land har like populaere sjangre, saa velger foerste forekomst per land.
     SELECT DISTINCT ON (can.Country) can.Country, can.Genre AS top_genre
     FROM country_allgenre_number AS can INNER JOIN country_number AS cn ON ((can.Country = can.Country))
     WHERE can.Country = cn.Country AND can.number_of_movies = cn.number_of_movies 
),
country_number_movies AS ( -- Alle land, med antall filmer i landet.
     SELECT Country, COUNT(Filmid) AS number_of_movies
     FROM Filmcountry
     GROUP BY Country
     ORDER BY Country
),
country_rating_movies AS ( -- Alle land, med gjennomsnittlig rating per film i landet.
     SELECT fc.Country, AVG(fr.Rank) AS average_rating
     FROM Filmcountry AS fc INNER JOIN Filmrating AS fr USING (Filmid)
     GROUP BY fc.Country
     ORDER BY fc.Country
)

SELECT result.Country, result.number_of_movies, result.average_rating, result.top_genre 
FROM (country_number_movies AS cnm 
     INNER JOIN country_rating_movies AS crm USING (Country)
     INNER JOIN country_top_genre AS ctp USING (Country)) as result;


-- Oppgave 6
-- Fungerer ikke, men gir mening logisk.
WITH pfc AS ( -- Alle personer som har jobbet med norske filmer, og deres filmer.
     SELECT p.Firstname, p.Lastname, p.Personid, fp.Filmid
     FROM Filmparticipation AS fp
          INNER JOIN Person AS p USING (Personid)
          INNER JOIN Filmcountry AS fc USING (Filmid)
     WHERE fc.Country = 'Norway'
),
actor_pair AS ( -- Alle par av personer som har jobbet sammen med norske filmer, og deres filmer.
     SELECT p1.Firstname AS first_name1, p1.Lastname AS last_name1,
                     p2.Firstname AS first_name2, p2.Lastname AS last_name2,
                     p1.Filmid
     FROM pfc AS p1 
          INNER JOIN pfc AS p2 ON ((p1.Personid < p2.Personid) AND (p1.Filmid = p2.Filmid))
)

SELECT first_name1, last_name1, first_name2, last_name2, COUNT(filmid)
FROM actor_pair
GROUP BY first_name1, last_name1, first_name2, last_name2
HAVING COUNT(filmid) > 40;


-- Oppgave 7
SELECT DISTINCT f.Title, f.Prodyear
FROM Film AS f 
     INNER JOIN Filmgenre AS fg USING (Filmid)
     INNER JOIN Filmcountry AS fc USING (Filmid)
WHERE (f.Title LIKE '%Dark%' OR f.Title LIKE '%Night%') 
       AND (fc.Country = 'Romania' OR fg.Genre = 'Horror');


-- Oppgave 8
SELECT result.Title, COUNT(result.Personid) as deltakere
FROM (SELECT DISTINCT f.Title, fp.Personid -- En person kan ha flere roller.
      FROM Film AS f INNER JOIN Filmparticipation AS fp USING (Filmid)
      WHERE f.Prodyear >= 2010) as result
GROUP BY result.Title
HAVING COUNT(result.Personid) <= 2;


-- Oppgave 9
SELECT COUNT(result.Filmid) AS number_of_movies
FROM (SELECT f.Filmid
      FROM Film AS f
      WHERE f.Filmid NOT IN (SELECT Filmid
                             FROM Filmgenre
                             WHERE Genre = 'Horror' OR Genre = 'Sci-fi')) AS result;


-- Oppgave 10. Disse loesningene er lagt under kriterier.
-- Kriterie 1.
WITH film_languages AS (
     SELECT f.Filmid, COUNT(fl.Language) AS number_of_languages
     FROM Film AS f INNER JOIN Filmlanguage AS fl USING (Filmid)
     GROUP BY f.Filmid
)
SELECT f.Title, fl.number_of_languages
FROM Film AS F 
     INNER JOIN Filmrating AS fr USING (Filmid)
     INNER JOIN film_languages AS fl USING (Filmid)
WHERE fr.Rank > 8 AND fr.Votes > 1000
ORDER BY fr.Rank DESC, fr.Votes DESC
LIMIT 10;


-- Kriterie 2.
WITH film_languages AS (
     SELECT f.Filmid, COUNT(fl.Language) AS number_of_languages
     FROM Film AS f INNER JOIN Filmlanguage AS fl USING (Filmid)
     GROUP BY f.Filmid
)
SELECT f.Title, fl.number_of_languages
FROM Filmparticipation AS fp
     INNER JOIN Film AS f USING (Filmid)
     INNER JOIN Person AS p USINg (Personid)
     INNER JOIN Filmrating AS fr USING (Filmid)
     INNER JOIN film_languages AS fl USING (Filmid)
WHERE fr.Rank > 8 AND fr.Votes > 1000
      AND (p.Firstname = 'Harrison' AND p.Lastname = 'Ford');


-- Kriterie 3
WITH film_languages AS (
     SELECT f.Filmid, COUNT(fl.Language) AS number_of_languages
     FROM Film AS f INNER JOIN Filmlanguage AS fl USING (Filmid)
     GROUP BY f.Filmid
)
SELECT f.Title, fl.number_of_languages
FROM Film AS f 
     INNER JOIN Filmgenre AS fg USING (Filmid)
     INNER JOIN film_languages AS fl USING (Filmid)
     INNER JOIN Filmrating AS fr USING (Filmid)
WHERE fr.Rank > 8 AND fr.Votes > 1000
      AND (fg.Genre = 'Comedy' OR fg.Genre = 'Romance')
ORDER BY f.Title;

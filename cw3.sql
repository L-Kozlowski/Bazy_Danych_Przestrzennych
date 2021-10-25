CREATE EXTENSION postgis;

-- 4 Wyznacz liczbę budynków (tabela: popp, atrybut: f_codedesc, reprezentowane, jako punkty) położonych w odległości mniejszej niż 1000 m
-- od głównych rzek. Budynki spełniające to kryterium zapisz do osobnej tabeli tableB.

SELECT geom FROM rivers
UNION
SELECT geom FROM popp;

Select ST_Buffer(r.geom,1000) FROM rivers r
UNION
SELECT p.geom  FROM rivers r, popp p WHERE ST_Contains(ST_Buffer(r.geom,1000),p.geom)


CREATE TABLE slected_buildings AS
SELECT  p.gid, p.cat, p.type, p.geom FROM rivers r, popp p WHERE ST_Contains(ST_Buffer(r.geom,1000),p.geom);

-- 5 Utwórz tabelę o nazwie airportsNew. Z tabeli airports do zaimportuj nazwy lotnisk, ich geometrię,
-- a także atrybut elev, reprezentujący wysokość n.p.m.  


CREATE TABLE airportsNew AS
SELECT a.name, a.geom, a.elev FROM airports a;

-- a) Znajdź lotnisko, które położone jest najbardziej na zachód i najbardziej na wschód.  


SELECT aN.name, ST_AsText(aN.geom), aN.geom FROM airportsNew aN 
WHERE ST_X(aN.geom) = ( SELECT MAX(ST_X(aN.geom)) FROM  airportsNew aN )
OR ST_X(aN.geom) = ( SELECT MIN(ST_X(aN.geom)) FROM  airportsNew aN )
UNION
SELECT aN.name, ST_AsText(aN.geom), aN.geom FROM airportsNew aN 
WHERE ST_Y(aN.geom) = ( SELECT MAX(ST_Y(aN.geom)) FROM  airportsNew aN )
OR ST_Y(aN.geom) = ( SELECT MIN(ST_Y(aN.geom)) FROM  airportsNew aN );

-- Do tabeli airportsNew dodaj nowy obiekt - lotnisko, które położone jest w punkcie środkowym drogi pomiędzy lotniskami znalezionymi w punkcie a. 
-- Lotnisko nazwij airportB. Wysokość n.p.m. przyjmij dowolną.


SELECT ST_Centroid(ST_ShortestLine(a1.geom, a2.geom))
FROM airportsNew a1, airportsNew a2
WHERE ST_Y(a1.geom) = ( SELECT MAX(ST_Y(aN.geom)) FROM  airportsNew aN )
AND ST_Y(a2.geom) = ( SELECT MIN(ST_Y(aN.geom)) FROM  airportsNew aN );

INSERT INTO airportsNew 
SELECT 'airportB', ST_Centroid(ST_ShortestLine(a1.geom, a2.geom)), 100.000
FROM airportsNew a1, airportsNew a2
WHERE ST_X(a1.geom) = ( SELECT MAX(ST_X(aN.geom)) FROM  airportsNew aN )
AND ST_X(a2.geom) = ( SELECT MIN(ST_X(aN.geom)) FROM  airportsNew aN );

SELECT * FROM airportsNew ORDER BY name;

DELETE  FROM airportsNew WHERE name = 'airportB'

-- 6 6.	Wyznacz pole powierzchni obszaru, który oddalony jest mniej niż 1000 jednostek od najkrótszej linii łączącej jezioro 
-- o nazwie ‘Iliamna Lake’ i lotnisko o nazwie „AMBLER”

SELECT ST_Area(ST_Buffer(ST_ShortestLine(l.geom, a.geom),1000))FROM lakes l, airportsNew a
WHERE l.names = 'Iliamna Lake' 
AND a.name = 'AMBLER'

-- 7.	Napisz zapytanie, które zwróci sumaryczne pole powierzchni poligonów reprezentujących poszczególne typy drzew 
-- znajdujących się na obszarze tundry i bagien (swamps).  

SELECT geom FROM swamp
UNION
SELECT geom FROM trees

SELECT tr.vegdesc, SUM(tr.area_km2) FROM swamp s, trees tr, tundra tu 
WHERE ST_Contains(s.geom, tr.geom)
OR ST_Contains(tu.geom, tr.geom)
GROUP BY
tr.vegdesc

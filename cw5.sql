CREATE EXTENSION postgis;

CREATE TABLE obiekty(name VARCHAR(50), geom GEOMETRY);

INSERT INTO obiekty VALUES('obiekt1',ST_GeomFromEWKT('COMPOUNDCURVE((0 1, 1 1),CIRCULARSTRING(1 1, 2 0, 3 1),
													 CIRCULARSTRING(3 1, 4 2, 5 1),(5 1, 6 1))'));
INSERT INTO obiekty VALUES('obiekt2',ST_GeomFromEWKT('CURVEPOLYGON(COMPOUNDCURVE((10 6, 14 6),CIRCULARSTRING(14 6, 16 4, 14 2),
													 CIRCULARSTRING(14 2, 12 0, 10 2),(10 2, 10 6)),CIRCULARSTRING(11 2, 13 2, 11 2)) '))
INSERT INTO obiekty VALUES('obiekt3',ST_GeomFromEWKT('MULTILINESTRING((7 15,10 17),(10 17,12 13),(12 13,7 15))'));													 
INSERT INTO obiekty VALUES('obiekt4',ST_GeomFromEWKT('MULTILINESTRING((20 20,25 25),(25 25,27 24),(27 24,25 22),(25 22,26 21),
													(26 21,22 19),(22 19,20.5 19.5))'));													 
INSERT INTO obiekty VALUES('obiekt5',ST_GeomFromEWKT('MULTIPOINTM(30 30 59,38 32 234)'));	
INSERT INTO obiekty VALUES('obiekt6',ST_GeomFromEWKT('GEOMETRYCOLLECTION(POINT(4 2),LINESTRING(1 1,3 2))'));	

SELECT * FROM obiekty

-- zad1
SELECT ST_Area(ST_Buffer(ST_ShortestLine(o1.geom, o2.geom),5)) 
FROM obiekty o1, obiekty o2 WHERE o1.name = 'obiekt3' AND o2.name = 'obiekt4';

--zad2 
SELECT ST_MakePolygon(ST_LineMerge(o.geom)) FROM obiekty o WHERE o.name = 'obiekt4';
SELECT ST_MakePolygon(ST_LineMerge(ST_GeomFromEWKT('MULTILINESTRING((20 20,25 25),(25 25,27 24),(27 24,25 22),(25 22,26 21),(26 21,22 19),(22 19,20.5 19.5),(20.5 19.5,20 20))'))) 

--ERROR:  Shell is not a line
-- SQL state: XX000
-- ERROR:  lwpoly_from_lwlines: shell must be closed

--zad3 
INSERT INTO obiekty VALUES(
'obiekt7',
	(SELECT ST_Collect(o1.geom, o2.geom)
FROM obiekty o1, obiekty o2 WHERE o1.name = 'obiekt3' AND o2.name = 'obiekt4')
)
SELECT * FROM obiekty WHERE obiekty.name = 'obiekt7'
--zad4
SELECT SUM(ST_Area(ST_Buffer(obiekty.geom,5))) FROM obiekty WHERE obiekty.name != 'obiekt1' AND obiekty.name != 'obiekt2'





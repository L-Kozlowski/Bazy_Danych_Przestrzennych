CREATE EXTENSION postgis;

CREATE TABLE buildings( id_building INTEGER PRIMARY KEY, geometry GEOMETRY, name VARCHAR(60));
CREATE TABLE roads( id_roads INTEGER PRIMARY KEY, geometry GEOMETRY, name VARCHAR(60));
CREATE TABLE poi( id_poi INTEGER PRIMARY KEY, geometry GEOMETRY, name VARCHAR(60));

INSERT INTO buildings VALUES( 1, ST_GeometryFromText('POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))',0),'BuildingA');
INSERT INTO buildings VALUES( 2, ST_GeometryFromText('POLYGON((4 7, 6 7, 6 5, 4 5, 4 7))',0),'BuildingB');
INSERT INTO buildings VALUES( 3, ST_GeometryFromText('POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))',0),'BuildingC');
INSERT INTO buildings VALUES( 4, ST_GeometryFromText('POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))',0),'BuildingD');
INSERT INTO buildings VALUES( 5, ST_GeometryFromText('POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))',0),'BuildingF');

INSERT INTO roads VALUES( 1, ST_SetSRID(ST_MakeLine(ST_GeometryFromText('POINT(7.5 10.5)'),
													ST_GeometryFromText('POINT(7.5 0)')),0),'RoadY');
INSERT INTO roads VALUES( 2, ST_SetSRID(ST_MakeLine(ST_GeometryFromText('POINT(0 4.5)'),
												    ST_GeometryFromText('POINT(12 4.5)')),0),'RoadX');

INSERT INTO poi VALUES( 1, ST_GeometryFromText('POINT(1 3.5)',0),'G');
INSERT INTO poi VALUES( 2, ST_GeometryFromText('POINT(5.5 1.5)',0),'H');
INSERT INTO poi VALUES( 3, ST_GeometryFromText('POINT(9 5.6)',0),'I');
INSERT INTO poi VALUES( 4, ST_GeometryFromText('POINT(6.5 6)',0),'J');
INSERT INTO poi VALUES( 5, ST_GeometryFromText('POINT(6 9.5)',0),'K');

SELECT * FROM buildings
UNION
SELECT * FROM roads
UNION
SELECT * FROM poi


--6
--a
SELECT SUM(ST_Length(geometry)) FROM roads ;

--b
SELECT name, ST_AsText(geometry), ST_Area(geometry) ,ST_Perimeter(geometry) FROM buildings WHERE name = 'BuildingA';

--c
SELECT name, ST_Area(geometry) FROM buildings ORDER BY name;

--d
SELECT name, ST_Perimeter(geometry) FROM buildings ORDER BY ST_Perimeter(geometry) DESC LIMIT 2;

--e
SELECT ST_Distance(b.geometry, p.geometry )
FROM buildings b, poi p
WHERE b.name = 'BuildingC' AND p.name = 'G';

--f
SELECT ST_Area(ST_Difference(bC.geometry,ST_Buffer(bB.geometry, 0.5))) FROM buildings bB, buildings bC
WHERE bB.name = 'BuildingB' AND bC.name = 'BuildingC';


--g
SELECT b.name, ST_AsText(b.geometry)  FROM buildings b, roads r 
WHERE r.name =  'RoadX' AND ST_Y(ST_Centroid(b.geometry)) > ST_Y(ST_Centroid(r.geometry));

SELECT ST_AREA(ST_AsText(ST_SymDifference(b.geometry, ST_GeometryFromText('POLYGON(( 4 7, 6 7, 6 8, 4 8, 4 7))'))))
FROM buildings b WHERE b.name = 'BuildingC';


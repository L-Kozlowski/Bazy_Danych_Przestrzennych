--2. Podziel warstwę trees na trzy warstwy. Na każdej z nich umieść inny typ lasu.

CREATE TABLE mixed_trees AS
SELECT * FROM trees WHERE vegdesc = 'Mixed Trees';

CREATE TABLE evergreen AS
SELECT * FROM trees WHERE vegdesc = 'Evergreen';

CREATE TABLE deciduous AS
SELECT * FROM trees WHERE vegdesc = 'Deciduous';


--3. Oblicz długość linii kolejowych dla regionu Matanuska-Susitna. 
SELECT reg.geom FROM regions reg, railroads rai WHERE reg.name_2 = 'Matanuska-Susitna'
UNION
SELECT rai.geom FROM regions reg, railroads rai WHERE reg.name_2 = 'Matanuska-Susitna' AND ST_Contains(reg.geom, rai.geom)

SELECT SUM(ST_Length( rai.geom)) FROM regions reg, railroads rai WHERE reg.name_2 = 'Matanuska-Susitna' AND ST_Contains(reg.geom, rai.geom)

--4 . Oblicz, na jakiej średniej wysokości nad poziomem morza położone są lotniska o charakterze 
-- militarnym. Ile jest takich lotnisk? Usuń z warstwy airports lotniska o charakterze militarnym, które są 
-- dodatkowo położone powyżej 1400 m n.p.m. Ile było takich lotnisk?

SELECT AVG(elev) FROM airports WHERE use = 'Military' OR use = 'Joint Military/Civilian'

SELECT COUNT(elev) FROM airports WHERE use = 'Military' OR use = 'Joint Military/Civilian'

DELETE FROM airports WHERE (use = 'Military' OR use = 'Joint Military/Civilian') AND elev > 1400

-- 5 Utwórz warstwę, na której znajdować się będą jedynie budynki położone w regionie Bristol Bay
-- (wykorzystaj warstwę popp). Podaj liczbę budynków. Na warstwie zostaw tylko te budynki, które są 
-- położone nie dalej niż 100 km od rzek (rivers). Ile jest takich budynków?
 
 
SELECT reg.geom FROM regions reg WHERE reg.name_2 = 'Bristol Bay'
UNION
SELECT p.geom FROM regions reg, popp p WHERE reg.name_2 = 'Bristol Bay' AND St_Contains(reg.geom, p.geom) AND f_codedesc ='Building'

SELECT COUNT(p.geom) FROM regions reg, popp p WHERE reg.name_2 = 'Bristol Bay' AND St_Contains(reg.geom, p.geom) AND f_codedesc ='Building'

SELECT COUNT(p.geom) FROM regions reg, popp p , rivers r
WHERE reg.name_2 = 'Bristol Bay' AND St_Contains(reg.geom, p.geom) AND p.f_codedesc ='Building' AND ST_Contains(ST_Buffer(r.geom,100000), p.geom )
 
 
 -- 6. Sprawdź w ilu miejscach przecinają się rzeki (majrivers) z liniami kolejowymi (railroads).
SELECT COUNT(r.geom) FROM majrivers m, railroads r WHERE  ST_Intersects(m.geom, r.geom)
 
SELECT ST_Intersection(m.geom, r.geom) FROM majrivers m, railroads r WHERE  ST_Intersects(m.geom, r.geom)
 
 
 -- 7. Wydobądź węzły dla warstwy railroads. Ile jest takich węzłów?

SELECT (ST_DumpPoints(r.geom)).geom FROM railroads r 
 
SELECT ((ST_DumpPoints(r.geom)).path) FROM railroads r 

 
-- 8. Wyszukaj najlepsze lokalizacje do budowy hotelu. Hotel powinien być oddalony od lotniska nie 
-- więcej niż 100 km i nie mniej niż 50 km od linii kolejowych. Powinien leżeć także w pobliżu sieci 
-- drogowej. 
 
 SELECT ST_Difference(ST_Buffer(a.geom, 100000), ST_Buffer(r.geom, 50000)) FROM  airports a, railroads r 
 

SELECT ST_Buffer(a.geom, 100000) FROM  airports a
UNION
SELECT ST_Buffer(r.geom, 50000) FROM  railroads r 

 
 
 
 
 
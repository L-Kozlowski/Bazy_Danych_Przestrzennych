CREATE DATABASE firma;

CREATE SCHEMA ksiegowosc;

CREATE TABLE ksiegowosc.pracownicy(id_pracownika INT PRIMARY KEY, imie varchar(40) NOT NULL, nazwisko varchar(40) NOT NULL,
								   adres  varchar(80) NOT NULL, telefon varchar(15) );

CREATE TABLE ksiegowosc.godziny(id_godziny integer  PRIMARY KEY ,data date NOT NULL,liczba_godzin integer NOT NULL,
								id_pracownika integer);

CREATE TABLE ksiegowosc.pensja(id_pensji integer PRIMARY KEY, stanowisko varchar(40) NOT NULL, kwota money NOT NULL);

CREATE TABLE ksiegowosc.premia(id_premii varchar(5) PRIMARY KEY, rodzaj varchar(40), kwota money NOT NULL);

CREATE TABLE ksiegowosc.wynagrodzenia(id_wynagrodzenia integer  PRIMARY KEY, data DATE NOT NULL, id_pracownika integer, 
									  id_godziny integer, id_pensji integer, id_premii varchar(5));
									  
COMMENT ON TABLE ksiegowosc.pracownicy IS ' Dane pracowników ';
COMMENT ON TABLE ksiegowosc.godziny IS ' Przepracowane godziny pracowników ';
COMMENT ON TABLE ksiegowosc.pensja IS 'Wynagrodzenia dla pracownikow ';
COMMENT ON TABLE ksiegowosc.premia IS 'Premia dla pracownikow ';
COMMENT ON TABLE ksiegowosc.wynagrodzenia IS 'Tabela łącząca tabele pracowników z tabelą pensji i premi ';


select obj_description('ksiegowosc.pracownicy'::regclass, 'pg_class') as pracownicy,
obj_description('ksiegowosc.godziny'::regclass, 'pg_class') as godziny,
obj_description('ksiegowosc.pensja'::regclass, 'pg_class') as pensja,
obj_description('ksiegowosc.premia'::regclass, 'pg_class') as premia,
obj_description('ksiegowosc.wynagrodzenia'::regclass, 'pg_class') as wynagrodzenia;


ALTER TABLE ksiegowosc.godziny ADD FOREIGN KEY (id_pracownika) REFERENCES ksiegowosc.pracownicy(id_pracownika) ON DELETE CASCADE;
ALTER TABLE ksiegowosc.wynagrodzenia ADD FOREIGN KEY (id_pracownika) REFERENCES ksiegowosc.pracownicy(id_pracownika) ON DELETE CASCADE;
ALTER TABLE ksiegowosc.wynagrodzenia ADD FOREIGN KEY (id_godziny) REFERENCES ksiegowosc.godziny(id_godziny) ON DELETE CASCADE;
ALTER TABLE ksiegowosc.wynagrodzenia ADD FOREIGN KEY (id_pensji) REFERENCES ksiegowosc.pensja(id_pensji) ON DELETE CASCADE;
ALTER TABLE ksiegowosc.wynagrodzenia ADD FOREIGN KEY (id_premii) REFERENCES ksiegowosc.premia(id_premii) ON DELETE CASCADE;

--5 cw wypełnianie tabeli


INSERT INTO ksiegowosc.pracownicy VALUES (1, 'Szymon','Nowak','os.Urocze 21/69, 31-871 Kraków ','605134854');
INSERT INTO ksiegowosc.pracownicy VALUES (2, 'Adrian','Kowalski','os.Słoneczne 12/31, 31-921 Kraków ',null);
INSERT INTO ksiegowosc.pracownicy VALUES (3, 'Anna','Wójcik','os.Zielone 15/1, 31-911 Kraków ',null);
INSERT INTO ksiegowosc.pracownicy VALUES (4, 'Julia','Knap','os.Sportowe 2/45, 31-922 Kraków ','504430312');
INSERT INTO ksiegowosc.pracownicy VALUES (5, 'Grzegorz','Piotrowski','os.Wandy 6/11, 31-913 Kraków ','631457643');
INSERT INTO ksiegowosc.pracownicy VALUES (6, 'Aleksandra','Karaś','os.Szkolne 22/42, 31-912 Kraków ','773228853');
INSERT INTO ksiegowosc.pracownicy VALUES (7, 'Wojciech','Skrzyński','os.Na Skarpie 12/23, 31-981 Kraków ',null);
INSERT INTO ksiegowosc.pracownicy VALUES (8, 'Marian','Wątroba','ul. Bulwarowa 17/19, 31-849 Kraków ','888534212');
INSERT INTO ksiegowosc.pracownicy VALUES (9, 'Monika','Bańka','os.Górali 9/9, 31-927 Kraków ','655423367');
INSERT INTO ksiegowosc.pracownicy VALUES (10, 'Jakub','Kubańczyk','os.Krakowiaków 2/52, 31-877 Kraków ','554223556');

INSERT INTO ksiegowosc.godziny VALUES (11, '2020-12-22',160,1);
INSERT INTO ksiegowosc.godziny VALUES (12, '2020-12-21',166,2);
INSERT INTO ksiegowosc.godziny VALUES (13, '2020-12-24',169,3);
INSERT INTO ksiegowosc.godziny VALUES (14, '2020-12-22',154,4);
INSERT INTO ksiegowosc.godziny VALUES (15, '2020-12-21',157,5);
INSERT INTO ksiegowosc.godziny VALUES (16, '2020-12-19',170,6);
INSERT INTO ksiegowosc.godziny VALUES (17, '2020-12-27',180,7);
INSERT INTO ksiegowosc.godziny VALUES (18, '2020-12-23',146,8);
INSERT INTO ksiegowosc.godziny VALUES (19, '2020-12-25',174,9);
INSERT INTO ksiegowosc.godziny VALUES (20, '2020-12-26',161,10);

INSERT INTO ksiegowosc.premia VALUES ('A1', 'Roczna',2000);
INSERT INTO ksiegowosc.premia VALUES ('A2', 'Miesieczna',500);
INSERT INTO ksiegowosc.premia VALUES ('A3', 'Pracownik Miesiąca',1000);
INSERT INTO ksiegowosc.premia VALUES ('A4', 'Pracownik Tygodnia',100);
INSERT INTO ksiegowosc.premia VALUES ('A5',null,1500);
INSERT INTO ksiegowosc.premia VALUES ('A6',null,2500);
INSERT INTO ksiegowosc.premia VALUES ('A7', 'Na samochód',30000);
INSERT INTO ksiegowosc.premia VALUES ('A8', 'Na mieszkanie',50000);
INSERT INTO ksiegowosc.premia VALUES ('A9',null,150);
INSERT INTO ksiegowosc.premia VALUES ('A10', 'Pracownik Roku',3000);

INSERT INTO ksiegowosc.pensja VALUES (1, 'Kierownik',12000);
INSERT INTO ksiegowosc.pensja VALUES (2, 'Sekretarka',5000);
INSERT INTO ksiegowosc.pensja VALUES (3, 'Pracownik',4000);
INSERT INTO ksiegowosc.pensja VALUES (4, 'Praktykant',1000);
INSERT INTO ksiegowosc.pensja VALUES (5, 'Dyrektor marketingu',8000);
INSERT INTO ksiegowosc.pensja VALUES (6, 'Księgowy',5000);
INSERT INTO ksiegowosc.pensja VALUES (7, 'Specjalista ds. personalnych',6000);
INSERT INTO ksiegowosc.pensja VALUES (8, 'Operator produkcji',4500);
INSERT INTO ksiegowosc.pensja VALUES (9, 'Inżynier produkcji ',4500);
INSERT INTO ksiegowosc.pensja VALUES (10, 'Sprzątaczka',3000);


INSERT INTO ksiegowosc.wynagrodzenia VALUES (1, '2020-12-27', 1, 11, 1, 'A1');
INSERT INTO ksiegowosc.wynagrodzenia VALUES (2, '2020-12-12', 2, 12 ,2, 'A2');
INSERT INTO ksiegowosc.wynagrodzenia VALUES (3, '2020-12-11', 3, 13, 3, 'A3');
INSERT INTO ksiegowosc.wynagrodzenia VALUES (4, '2020-12-14', 4, 14, 4, 'A4');
INSERT INTO ksiegowosc.wynagrodzenia VALUES (5, '2020-12-28', 5, 15, 5, NULL);
INSERT INTO ksiegowosc.wynagrodzenia VALUES (6, '2020-12-30', 6, 16, 6, 'A6');
INSERT INTO ksiegowosc.wynagrodzenia VALUES (7, '2020-12-2', 7, 17, 7, 'A7');
INSERT INTO ksiegowosc.wynagrodzenia VALUES (8, '2020-12-10', 8, 18, 8, NULL);
INSERT INTO ksiegowosc.wynagrodzenia VALUES (9, '2020-12-23', 9, 19, 9, 'A9');
INSERT INTO ksiegowosc.wynagrodzenia VALUES (10, '2020-12-9', 10, 20, 10, 'A10');

UPDATE ksiegowosc.wynagrodzenia SET id_premii = null where id_wynagrodzenia = 8

--6.Napisz zapytanie

--A
SELECT id_pracownika,nazwisko From ksiegowosc.pracownicy;

--B
SELECT pracownicy.id_pracownika,pensja.kwota
FROM ksiegowosc.pracownicy 
INNER JOIN ksiegowosc.pensja 
INNER JOIN ksiegowosc.wynagrodzenia
ON pensja.id_pensji = wynagrodzenia.id_pensji
ON pracownicy.id_pracownika = wynagrodzenia.id_pracownika
WHERE pensja.kwota > MONEY(1000.00)

--C
SELECT pracownicy.id_pracownika,pensja.kwota
FROM ksiegowosc.pracownicy
INNER JOIN ksiegowosc.pensja
INNER JOIN ksiegowosc.wynagrodzenia
ON pensja.id_pensji = wynagrodzenia.id_pensji
ON pracownicy.id_pracownika = wynagrodzenia.id_pracownika
WHERE pensja.kwota > MONEY(2000.00) AND wynagrodzenia.id_premii IS NULL

--D
SELECT id_pracownika,imie,nazwisko FROM ksiegowosc.pracownicy WHERE imie LIKE 'J%';

--E
SELECT id_pracownika,imie,nazwisko FROM ksiegowosc.pracownicy WHERE nazwisko LIKE '%n%' AND imie LIKE '%a'; 

--F
SELECT pracownicy.imie, pracownicy.nazwisko,godziny.liczba_godzin
FROM ksiegowosc.pracownicy 
INNER JOIN ksiegowosc.godziny 
INNER JOIN ksiegowosc.wynagrodzenia  
ON godziny.id_godziny = wynagrodzenia.id_godziny
ON pracownicy.id_pracownika = wynagrodzenia.id_pracownika
WHERE godziny.liczba_godzin > 160

--G
SELECT pracownicy.imie, pracownicy.nazwisko,pensja.kwota
FROM ksiegowosc.pracownicy 
INNER JOIN ksiegowosc.pensja 
INNER JOIN ksiegowosc.wynagrodzenia  
ON pensja.id_pensji = wynagrodzenia.id_pensji
ON pracownicy.id_pracownika = wynagrodzenia.id_pracownika
WHERE pensja.kwota >= MONEY(1500) AND pensja.kwota <= MONEY(3000)

--H
UPDATE ksiegowosc.godziny SET liczba_godzin = 190 where id_godziny = 18

SELECT pracownicy.imie, pracownicy.nazwisko, godziny.liczba_godzin
FROM ksiegowosc.pracownicy
INNER JOIN ksiegowosc.godziny 
INNER JOIN ksiegowosc.wynagrodzenia 
ON godziny.id_godziny = wynagrodzenia.id_godziny
ON pracownicy.id_pracownika = wynagrodzenia.id_pracownika
WHERE godziny.liczba_godzin > 160 AND wynagrodzenia.id_premii IS NULL

--I
SELECT pracownicy.imie, pracownicy.nazwisko, pensja.kwota
FROM ksiegowosc.pracownicy 
INNER JOIN ksiegowosc.pensja 
INNER JOIN ksiegowosc.wynagrodzenia 
ON pensja.id_pensji = wynagrodzenia.id_pensji
ON pracownicy.id_pracownika = wynagrodzenia.id_pracownika
ORDER BY pensja.kwota

--J
SELECT pracownicy.imie, pracownicy.nazwisko, pensja.kwota, premia.kwota
FROM ksiegowosc.pracownicy 
INNER JOIN ksiegowosc.pensja 
INNER JOIN ksiegowosc.premia 
INNER JOIN ksiegowosc.wynagrodzenia 
ON premia.id_premii = wynagrodzenia.id_premii
ON pensja.id_pensji = wynagrodzenia.id_pensji
ON pracownicy.id_pracownika = wynagrodzenia.id_pracownika
ORDER BY pensja.kwota DESC, premia.kwota DESC

--K
SELECT COUNT(pensja.stanowisko),pensja.stanowisko
FROM ksiegowosc.pensja
GROUP BY pensja.stanowisko

--L
UPDATE ksiegowosc.pensja SET stanowisko ='kierownik' where id_pensji = 5;

SELECT ROUND(AVG( pensja.kwota::numeric),2) AS AVG, MIN(pensja.kwota) AS MIN, MAX(pensja.kwota) AS MAX
FROM ksiegowosc.pensja
WHERE pensja.stanowisko LIKE 'kierownik'

--M
SELECT SUM(pensja.kwota) AS SUMA_PENSJI
FROM ksiegowosc.pensja

--N
SELECT  pensja.stanowisko, SUM(pensja.kwota) AS SUMA_PENSJI
FROM ksiegowosc.pensja
GROUP BY pensja.stanowisko

--O
UPDATE ksiegowosc.pensja SET stanowisko ='Sprzątaczka' where id_pensji = 6

SELECT COUNT(premia.kwota) AS LICZBA_PREMII, pensja.stanowisko
FROM ksiegowosc.pensja
INNER JOIN ksiegowosc.premia
INNER JOIN ksiegowosc.wynagrodzenia
ON premia.id_premii = wynagrodzenia.id_premii
ON pensja.id_pensji = wynagrodzenia.id_pensji
GROUP BY pensja.stanowisko

--P
DELETE FROM ksiegowosc.pracownicy 
WHERE pracownicy.id_pracownika IN (SELECT id_pracownika 
								   FROM  ksiegowosc.wynagrodzenia
								   INNER JOIN ksiegowosc.pensja
								   ON pensja.id_pensji = wynagrodzenia.id_pensji
								   WHERE pensja.kwota < MONEY(1200))
RETURNING *;

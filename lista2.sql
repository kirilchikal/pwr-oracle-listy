ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

--Zadanie 17
SELECT pseudo "POLUJE W POLU", przydzial_myszy "PRZYDZIAL MYSZY", nazwa "BANDA"
FROM Kocury JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy
WHERE teren IN ('CALOSC', 'POLE') AND przydzial_myszy > 50
ORDER BY przydzial_myszy DESC;

--Zadanie 18
SELECT K1.imie, K1.w_stadku_od "POLUJE OD"
FROM Kocury K1 JOIN Kocury K2 ON K2.imie = 'JACEK'
WHERE K1.w_stadku_od < K2.w_stadku_od
ORDER BY K1.w_stadku_od DESC;

--Zadanie 19
--A
SELECT K1.imie, K1.funkcja, K2.imie "Szef 1", NVL(K3.imie, ' ') "Szef 2", NVL(K4.imie, ' ') "Szef 3"
FROM Kocury K1 LEFT JOIN Kocury K2 ON K1.szef = K2.pseudo
                LEFT JOIN Kocury K3 ON K2.szef = K3.pseudo
                LEFT JOIN Kocury K4 ON K3.szef = K4.pseudo
WHERE K1.funkcja IN ('KOT', 'MILUSIA');
--B
SELECT *
FROM (SELECT CONNECT_BY_ROOT imie, CONNECT_BY_ROOT funkcja, imie "Im", LEVEL "L"
      FROM Kocury
      CONNECT BY PRIOR szef = pseudo
      START WITH funkcja IN ('KOT', 'MILUSIA'))
      PIVOT (
      MIN("Im")
      FOR "L"
      IN (2 "SZEF 1", 3 "SZEF 2", 4 "SZEF 3")
      );
--C
SELECT CONNECT_BY_ROOT imie "Imie", CONNECT_BY_ROOT funkcja "Funkcja", 
        LTRIM(SYS_CONNECT_BY_PATH(DECODE(level,1,'', RPAD(imie, 10)), '| '), '| ') "Imiona kolejnych szefow" 
FROM Kocury
WHERE szef IS NULL
CONNECT BY PRIOR szef = pseudo
START WITH funkcja IN ('KOT', 'MILUSIA');

--Zad 20
SELECT K.imie "Imie kotki", B.nazwa "Nazwa bandy", W.imie_wroga "Imie wroga", W.stopien_wrogosci "Ocena wroga", WK.data_incydentu "Data inc."
FROM Wrogowie W JOIN Wrogowie_Kocurow WK ON W.imie_wroga=WK.imie_wroga
                JOIN Kocury K ON WK.pseudo = K.pseudo
                JOIN Bandy B ON K.nr_bandy=B.nr_bandy
WHERE K.plec = 'D' AND WK.data_incydentu > TO_DATE('2007-01-01');

--Zad 21
SELECT nazwa "Nazwa bandy", COUNT(imie) "Koty z wrogami"
FROM Bandy JOIN (SELECT DISTINCT imie, nr_bandy
                 FROM Kocury NATURAL JOIN Wrogowie_Kocurow)
            USING (nr_bandy)
GROUP BY nazwa;

--Zad 22
SELECT funkcja, pseudo, count(*) "Liczba wrogow"
FROM Kocury NATURAL JOIN Wrogowie_Kocurow
GROUP BY pseudo, funkcja
HAVING COUNT(*) > 1;

--Zad 23
SELECT imie, 12*(NVL(przydzial_myszy, 0)+myszy_extra) "DAWKA ROCZNA", 'powyzej 864' "DAWKA"
FROM Kocury 
WHERE myszy_extra IS NOT NULL AND 12*(NVL(przydzial_myszy, 0)+myszy_extra) > 864
UNION
SELECT imie, 12*(NVL(przydzial_myszy, 0)+myszy_extra) "DAWKA ROCZNA", '864' "DAWKA"
FROM Kocury 
WHERE myszy_extra IS NOT NULL AND 12*(NVL(przydzial_myszy, 0)+myszy_extra) = 864
UNION
SELECT imie, 12*(NVL(przydzial_myszy, 0)+myszy_extra) "DAWKA ROCZNA", 'ponizej 864' "DAWKA"
FROM Kocury 
WHERE myszy_extra IS NOT NULL AND 12*(NVL(przydzial_myszy, 0)+myszy_extra) < 864
ORDER BY 2 DESC;

--Zad 24
--1 sposob
SELECT nr_bandy "NR BANDY", nazwa, teren
FROM Bandy LEFT JOIN Kocury USING(nr_bandy)
WHERE imie IS NULL;
--2sposob
SELECT nr_bandy "NR BANDY", nazwa, teren
FROM Bandy
MINUS 
SELECT nr_bandy "NR BANDY", nazwa, teren
FROM Bandy JOIN Kocury USING(nr_bandy);


--Zad 25
SELECT imie, funkcja, przydzial_myszy
FROM Kocury
WHERE NVL(przydzial_myszy, 0) >= ALL(SELECT 3*NVL(przydzial_myszy, 0)
                                     FROM Kocury NATURAL JOIN Bandy
                                     WHERE funkcja='MILUSIA' AND teren IN ('SAD', 'CALOSC'));

--Zad 26
WITH Sr AS
    (SELECT funkcja, ROUND(AVG(NVL(przydzial_myszy, 0)+NVL(myszy_extra, 0))) sredni
    FROM Kocury
    WHERE funkcja != 'SZEFUNIO'
    GROUP BY funkcja)
SELECT funkcja "Funkcja", sredni "Srednio najw. i najm. myszy"
FROM (SELECT * FROM Sr
    WHERE sredni IN((SELECT MIN(sredni) FROM Sr), (SELECT MAX(sredni) FROM Sr)))
;

--Zad 27
ACCEPT n PROMPT 'Prosze podac wartosc dla n: ';
--27 sposob a (skorelowane)
SELECT pseudo, NVL(przydzial_myszy,0)+NVL(myszy_extra,0) "ZJADA"
FROM Kocury K
WHERE (SELECT COUNT(DISTINCT NVL(przydzial_myszy,0)+NVL(myszy_extra,0))
        FROM Kocury
        WHERE NVL(przydzial_myszy,0)+NVL(myszy_extra,0) > NVL(K.przydzial_myszy,0)+NVL(K.myszy_extra,0)) < '&n'
ORDER BY 2 DESC;

--27 sposob b
SELECT pseudo, NVL(przydzial_myszy,0)+NVL(myszy_extra,0) "ZJADA"
FROM Kocury
WHERE NVL(przydzial_myszy,0)+NVL(myszy_extra,0) = ANY(
                    SELECT *
                    FROM (SELECT DISTINCT NVL(przydzial_myszy,0)+NVL(myszy_extra,0) "ZD"
                        FROM Kocury
                        ORDER BY 1 DESC)
                    WHERE ROWNUM <= '&n' ); --rownum ??????????? ?????? order
                    
--27 sposob c
--??? ???? ?????- ?? ????? ??????? ????????
--????? ????? ?.?????. ????? ???? ??????????? (????? ?????)
SELECT K1.pseudo, AVG(NVL(K1.przydzial_myszy,0)+NVL(K1.myszy_extra,0)) "ZJADA"
FROM Kocury K1 JOIN Kocury K2 
    ON NVL(K1.przydzial_myszy,0)+NVL(K1.myszy_extra,0) <= NVL(K2.przydzial_myszy,0)+NVL(K2.myszy_extra,0)
GROUP BY K1.pseudo
HAVING COUNT(DISTINCT NVL(K2.przydzial_myszy,0)+NVL(K2.myszy_extra,0)) <= '&n'
ORDER BY 2 DESC;

--27 sposob d
SELECT pseudo, zjada
FROM (SELECT pseudo, NVL(przydzial_myszy,0)+NVL(myszy_extra,0) zjada, 
        DENSE_RANK()
        OVER(ORDER BY NVL(przydzial_myszy,0)+NVL(myszy_extra,0) DESC) pozycja
      FROM Kocury)
WHERE pozycja <= '&n';


--Zad 28
WITH Suma AS 
    (SELECT TO_CHAR(EXTRACT(year FROM w_stadku_od)) rok, COUNT(*) liczba
    FROM Kocury
    GROUP BY EXTRACT(year FROM w_stadku_od))
SELECT rok, liczba "LICZBA WYSTAPIEN"
FROM (SELECT *
    FROM Suma
    WHERE liczba = (SELECT MAX(liczba) FROM suma WHERE liczba <= (SELECT ROUND(AVG(liczba), 7) FROM Suma))
    OR liczba = (SELECT MIN(liczba) FROM suma WHERE liczba >= (SELECT ROUND(AVG(liczba), 7) FROM Suma))
    UNION 
    SELECT 'Srednia' " ", ROUND(AVG(liczba), 7)
    FROM Suma)
ORDER BY 2
;

--Zad 29
--29 sposob a
SELECT K1.imie, AVG(NVL(K1.przydzial_myszy,0)+NVL(K1.myszy_extra,0)) "ZJADA", MIN(K1.nr_bandy), AVG(NVL(K2.przydzial_myszy,0)+NVL(K2.myszy_extra,0)) "SREDNIA BANDY"
FROM Kocury K1 JOIN Kocury K2 ON K1.nr_bandy = K2.nr_bandy
WHERE K1.plec='M'
GROUP BY K1.imie
HAVING MIN(NVL(K1.przydzial_myszy,0)+NVL(K1.myszy_extra,0)) <= AVG(NVL(K2.przydzial_myszy,0)+NVL(K2.myszy_extra,0))
;
--29 sposob b
SELECT K1.imie, NVL(K1.przydzial_myszy,0)+NVL(K1.myszy_extra,0) "ZJADA", K1.nr_bandy, K2.srednio "SREDNIA BANDY"
FROM Kocury K1 JOIN (SELECT nr_bandy, AVG(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)) srednio
                    FROM Kocury
                    GROUP BY nr_bandy) K2
    ON K1.nr_bandy=K2.nr_bandy AND NVL(K1.przydzial_myszy,0)+NVL(K1.myszy_extra,0) <= K2.srednio
WHERE K1.plec='M'
;
--29 sposob c
SELECT imie, NVL(przydzial_myszy,0)+NVL(myszy_extra,0) "ZJADA", nr_bandy, (
                SELECT AVG(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)) "ZJADA"
                FROM Kocury
                WHERE nr_bandy=K.nr_bandy) "SREDNIA BANDY"
FROM Kocury K
WHERE plec='M' AND NVL(przydzial_myszy,0)+NVL(myszy_extra,0) <= (
                SELECT AVG(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)) "ZJADA"
                FROM Kocury
                WHERE nr_bandy=K.nr_bandy)
;

--Zad 30
SELECT imie, w_stadku_od||' <---' "WSTAPIL DO STADKA ", 'NAJMLODSZY STAZEM W BANDZIE '||nazwa " "
FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy 
WHERE w_stadku_od = (SELECT MIN(w_stadku_od) FROM Kocury WHERE nr_bandy = K.nr_bandy)
    UNION
SELECT imie, w_stadku_od||' <---' "WSTAPIL DO STADKA ", 'NAJSTARZE STAZEM W BANDZIE '||nazwa " "
FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy 
WHERE w_stadku_od = (SELECT MAX(w_stadku_od) FROM Kocury WHERE nr_bandy = K.nr_bandy)
    UNION
SELECT imie, w_stadku_od||'     ' "WSTAPIL DO STADKA ", ' ' " "
FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy 
WHERE w_stadku_od != (SELECT MIN(w_stadku_od) FROM Kocury WHERE nr_bandy = K.nr_bandy)
    AND w_stadku_od != (SELECT MAX(w_stadku_od) FROM Kocury WHERE nr_bandy = K.nr_bandy)
;

--Zad 31
DROP VIEW Info_bandy;
CREATE VIEW Info_bandy (nazwa_bandy, sre_spoz, max_spoz, min_spoz, koty, koty_z_dod)
AS 
SELECT nazwa, AVG(przydzial_myszy), MAX(przydzial_myszy), MIN(przydzial_myszy), COUNT(*), COUNT(myszy_extra)
FROM Kocury, Bandy
WHERE Kocury.nr_bandy=Bandy.nr_bandy
GROUP BY nazwa;
--select * from info_bandy;
ACCEPT pseudo PROMPT 'Prosze podac wartosc dla pseudo: ';
SELECT pseudo, imie, funkcja, przydzial_myszy "ZJADA", 'OD '||min_spoz||' DO '||max_spoz "GRANICE SPOZYCIA", w_stadku_od "LOWI OD"
FROM Kocury JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy
            JOIN Info_bandy ON Bandy.nazwa = Info_bandy.nazwa_bandy
WHERE pseudo = '&pseudo'
;

--Zad 32
--perspektywa: koty o trzech najdluzszym stazach w polaczonych bandach
DROP VIEW Koty;
CREATE VIEW Koty
AS
SELECT * FROM 
        (SELECT pseudo FROM Kocury LEFT JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy 
        WHERE Bandy.nazwa = 'CZARNI RYCERZE' 
        ORDER BY w_stadku_od)
    WHERE ROWNUM < 4
        UNION
    SELECT * FROM 
        (SELECT pseudo FROM Kocury LEFT JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy 
        WHERE Bandy.nazwa = 'LACIACI MYSLIWI' 
        ORDER BY w_stadku_od)
WHERE ROWNUM < 4;
--Przed zmianami
SELECT pseudo, plec, przydzial_myszy "Myszy przed podw.", NVL(myszy_extra,0) "Extra przed podw."
FROM Kocury LEFT JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy
WHERE pseudo IN (SELECT * FROM Koty);
--Zmiany
UPDATE Kocury
SET przydzial_myszy = CASE plec WHEN 'M' THEN przydzial_myszy+10
        ELSE przydzial_myszy + (SELECT MIN(przydzial_myszy) FROM Kocury)*0.1 END,
    myszy_extra = NVL(myszy_extra,0) + 0.15*(SELECT AVG(NVL(myszy_extra,0)) FROM Kocury K WHERE Kocury.nr_bandy=K.nr_bandy)
WHERE pseudo IN (SELECT * FROM Koty);
--Po zmianach
SELECT pseudo, plec, przydzial_myszy "Myszy po podw.", NVL(myszy_extra,0) "Extra po podw."
FROM Kocury LEFT JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy
WHERE pseudo IN (SELECT * FROM Koty);
--Wycofanie zmian
ROLLBACK;


--Zad 33
--33 sposob a
SELECT * FROM
(SELECT B.nazwa "NAZWA BANDY",
      TO_CHAR(DECODE(plec, 'D', 'Kotka', 'Kocor')) "PLEC",
      TO_CHAR(COUNT(pseudo)) "ILE",
      TO_CHAR(SUM((DECODE(funkcja,'SZEFUNIO',przydzial_myszy + NVL(myszy_extra, 0),0)))) "SZEFUNIO",
      TO_CHAR(SUM((DECODE(funkcja,'BANDZIOR',przydzial_myszy + NVL(myszy_extra, 0),0)))) "BANDZIOR",
      TO_CHAR(SUM((DECODE(funkcja,'LOWCZY',przydzial_myszy + NVL(myszy_extra, 0),0)))) "LOWCZY",
      TO_CHAR(SUM((DECODE(funkcja,'LAPACZ',przydzial_myszy + NVL(myszy_extra, 0),0)))) "LAPACZ",
      TO_CHAR(SUM((DECODE(funkcja,'KOT',przydzial_myszy + NVL(myszy_extra, 0),0)))) "KOT",
      TO_CHAR(SUM((DECODE(funkcja,'MILUSIA',przydzial_myszy + NVL(myszy_extra, 0),0)))) "MILUSIA",
      TO_CHAR(SUM((DECODE(funkcja,'DZIELCZY',przydzial_myszy + NVL(myszy_extra, 0),0)))) "DZIELCZY",
      TO_CHAR(NVL((SELECT SUM(przydzial_myszy + NVL(myszy_extra, 0)) FROM Kocury K WHERE K.nr_bandy= K1.nr_bandy AND K.plec = K1.plec),0)) "SUMA"
FROM (Kocury K1 JOIN Bandy B ON K1.nr_bandy = B.nr_bandy)
GROUP BY B.nazwa, plec, K1.nr_bandy
ORDER BY B.nazwa)
UNION ALL
SELECT 'Z--------------', '----', '--------', '---------', '-------', '------', '-------', '-------', '--------', '--------', '-------' FROM DUAL
UNION ALL
SELECT 'ZJADA RAZEM', ' ', ' ',
       TO_CHAR(SUM(DECODE(funkcja, 'SZEFUNIO', przydzial_myszy + NVL(myszy_extra, 0), 0))),
       TO_CHAR(SUM(DECODE(funkcja, 'BANDZIOR', przydzial_myszy + NVL(myszy_extra, 0), 0))),
       TO_CHAR(SUM(DECODE(funkcja, 'LOWCZY', przydzial_myszy + NVL(myszy_extra, 0), 0))),
       TO_CHAR(SUM(DECODE(funkcja, 'LAPACZ', przydzial_myszy + NVL(myszy_extra, 0), 0))),
       TO_CHAR(SUM(DECODE(funkcja, 'KOT', przydzial_myszy + NVL(myszy_extra, 0), 0))),
       TO_CHAR(SUM(DECODE(funkcja, 'MILUSIA', przydzial_myszy + NVL(myszy_extra, 0), 0))),
       TO_CHAR(SUM(DECODE(funkcja, 'DZIELCZY', przydzial_myszy + NVL(myszy_extra, 0), 0))),
       TO_CHAR(SUM(przydzial_myszy + NVL(myszy_extra, 0)))
FROM (Kocury JOIN Bandy ON Kocury.nr_bandy= Bandy.nr_bandy);

--33 sposob b
SELECT *
FROM (
  SELECT nazwa "NAZWA BANDY",
    TO_CHAR(DECODE(plec, 'D', 'Kotka', 'Kocur')) "PLEC",
    TO_CHAR("Ile") "ILE",
    TO_CHAR(NVL(SZEFUNIO, 0)) "SZEFUNIO",
    TO_CHAR(NVL(BANDZIOR,0)) "BANDZIOR",
    TO_CHAR(NVL(LOWCZY,0)) "LOWCZY",
    TO_CHAR(NVL(LAPACZ,0)) "LAPACZ",
    TO_CHAR(NVL(KOT,0)) "KOT",
    TO_CHAR(NVL(MILUSIA,0)) "MILUSIA",
    TO_CHAR(NVL(DZIELCZY,0)) "DZIELCZY",
    TO_CHAR(NVL(suma,0)) "SUMA"
  FROM
    (SELECT nazwa, plec, funkcja, przydzial_myszy + NVL(myszy_extra, 0) liczba
     FROM Kocury K1 JOIN Bandy B ON K1.nr_bandy= B.nr_bandy) 
  PIVOT 
    (SUM(liczba) FOR funkcja IN (
      'SZEFUNIO' SZEFUNIO, 'BANDZIOR' BANDZIOR, 'LOWCZY' LOWCZY, 'LAPACZ' LAPACZ,
      'KOT' KOT, 'MILUSIA' MILUSIA, 'DZIELCZY' DZIELCZY)) 
  JOIN 
  (SELECT nazwa "N", plec "Pl", COUNT(imie) "Ile", SUM(przydzial_myszy + NVL(myszy_extra, 0)) suma
    FROM Kocury JOIN Bandy ON Kocury.nr_bandy= Bandy.nr_bandy
    GROUP BY nazwa, plec
    ORDER BY nazwa) 
  ON "N" = nazwa AND "Pl" = plec)
UNION ALL
SELECT 'Z--------------', '----', '--------', '---------', '-------', '------', '-------', '-------', '--------', '--------', '-------' FROM DUAL
UNION ALL
SELECT 'ZJADA RAZEM',' ', ' ',
    TO_CHAR(SZEFUNIO),
    TO_CHAR(BANDZIOR),
    TO_CHAR(LOWCZY),
    TO_CHAR(LAPACZ),
    TO_CHAR(KOT),
    TO_CHAR(MILUSIA),
    TO_CHAR(DZIELCZY),
    TO_CHAR(suma)
FROM (SELECT funkcja, przydzial_myszy + NVL(myszy_extra, 0) liczba
    FROM Kocury) 
PIVOT (SUM(liczba) FOR funkcja IN (
  'SZEFUNIO' SZEFUNIO, 'BANDZIOR' BANDZIOR, 'LOWCZY' LOWCZY, 'LAPACZ' LAPACZ,
  'KOT' KOT, 'MILUSIA' MILUSIA, 'DZIELCZY' DZIELCZY))
NATURAL JOIN (SELECT SUM(przydzial_myszy + NVL(myszy_extra, 0)) suma
      FROM Kocury);
      
      
    

    
    
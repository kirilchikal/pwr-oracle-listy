ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

--Zadanie 1
SELECT imie_wroga "WROG", opis_incydentu "PRZEWINA"
FROM Wrogowie_kocurow
WHERE EXTRACT(YEAR FROM data_incydentu) = 2009;

--Zadanie 2
SELECT imie, funkcja, w_stadku_od "Z NAMI OD"
FROM kocury
WHERE w_stadku_od BETWEEN TO_DATE('2005-09-01', 'YYYY-MM-DD') AND TO_DATE('2007-07-31', 'YYYY-MM-DD')
    AND plec='D';

--Zadanie 3    
SELECT imie_wroga "WROG", gatunek, stopien_wrogosci "STOPIEN WROGOSCI"
FROM wrogowie
WHERE lapowka IS NULL
ORDER BY stopien_wrogosci;

--Zadanie 4
SELECT imie||' zwany '||pseudo||' (fun. '||funkcja||') lowi myszki w bandzie '||nr_bandy||' od '||w_stadku_od "WSZYSTKO O KOCURACH"
FROM Kocury
WHERE plec='M'
ORDER BY w_stadku_od DESC, pseudo;

--Zadanie 5
SELECT pseudo, REGEXP_REPLACE(REGEXP_REPLACE(pseudo, '?A', '#', 1, 1), 'L','%', 1, 1) "Po wymianie A na # oraz L na %"
FROM kocury
WHERE pseudo LIKE '%A%' AND pseudo LIKE '%L%';

--Zadanie 6
SELECT imie, w_stadku_od "W stadku", ROUND(NVL(przydzial_myszy*0.9 ,0)) "Zjadal", ADD_MONTHS(SYSDATE, -144) "Podwyzka", NVL(przydzial_myszy, 0) "Zjada"
FROM kocury
WHERE w_stadku_od <= ADD_MONTHS(SYSDATE, -144) AND 
    EXTRACT(MONTH FROM w_stadku_od) BETWEEN 3 AND 9;
    
--Zadanie 7
SELECT imie, NVL(przydzial_myszy,0)*3 "MYSZE KWARTALNE", NVL(myszy_extra,0)*3 "KWARTALNE DODATKI"
FROM Kocury
WHERE przydzial_myszy > NVL(myszy_extra,0)*2 AND przydzial_myszy >= 55
ORDER BY przydzial_myszy DESC;

--Zadanie 8
SELECT imie, CASE
                WHEN NVL(przydzial_myszy, 0)*12 < 660 THEN 'Ponizej 660'
                WHEN NVL(przydzial_myszy, 0)*12 = 660 THEN 'Limit'
                ELSE TO_CHAR(NVL(przydzial_myszy, 0)*12) 
                END "Zjada rocznie"
FROM kocury;

--Zadanie 9
-- 26.10
SELECT pseudo, w_stadku_od "W STADKU", 
    CASE
        WHEN EXTRACT(DAY FROM w_stadku_od) <= 15 THEN NEXT_DAY(LAST_DAY(TO_DATE('2021-10-26'))-7,3)
        ELSE NEXT_DAY(LAST_DAY(TO_DATE('2021-11-26'))-7,3)
        END "WYPLATA"
FROM kocury;

-- 28.10
SELECT pseudo, w_stadku_od "W STADKU", NEXT_DAY(LAST_DAY(TO_DATE('2021-10-28')+7)-7,3) "WYPLATA"
FROM kocury;

--Zadanie 10
--pseudo
SELECT CASE COUNT(pseudo)
            WHEN 1 THEN pseudo||' - Unikalny'
            ELSE pseudo||' - nieunikalny'
            END "Unikalnosc atr. PSEUDO"
FROM kocury
GROUP BY pseudo;

--szef
SELECT CASE COUNT(szef)
            WHEN 1 THEN szef||' - Unikalny'
            ELSE szef||' - nieunikalny'
            END "Unikalnosc atr. SZEF"
FROM kocury
WHERE szef IS NOT NULL
GROUP BY szef;

--Zadanie 11
SELECT pseudo "Pseudonim", COUNT(imie_wroga) "Liczba wrogow"
FROM wrogowie_kocurow
GROUP BY pseudo
HAVING COUNT(imie_wroga) > 1;

--Zadanie 12
SELECT 'Liczba kotow= '||COUNT(funkcja)||' lowi jako '||funkcja||' i zjada max. '||AVG(NVL(przydzial_myszy,0)+NVL(myszy_extra,0))||' myszy miesiecznie' " "
FROM kocury
WHERE funkcja <> 'SZEFUNIO' AND plec = 'D'
GROUP BY funkcja
HAVING AVG(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)) > 50;

--Zadanie 13
SELECT nr_bandy "Nr bandy", plec "Plec", MIN(przydzial_myszy) "Minimalny przydzial"
FROM kocury
GROUP BY nr_bandy, plec;

--Zadanie 14
SELECT level "Pozycja", pseudo "Pseudonim", funkcja "Funkcja", nr_bandy "Nr_bandy"
FROM kocury
WHERE plec = 'M'
CONNECT BY PRIOR pseudo=szef
START WITH funkcja='BANDZIOR'
ORDER BY nr_bandy, level;

--Zadanie 15
SELECT RPAD('===>', 4*(level-1), '===>')||level||RPAD('   ', 4*level, '    ')||imie " ", pseudo "Pseudo szefa", funkcja "Funkcja"
FROM kocury
WHERE myszy_extra IS NOT NULL
CONNECT BY PRIOR pseudo=szef
START WITH szef IS NULL;

--Zadanie 16
SELECT LPAD('   ', 4*(level-1), '   ')||pseudo "Droga sluzbowa"
FROM kocury
CONNECT BY PRIOR szef=pseudo
START WITH myszy_extra IS NULL AND plec='M' AND w_stadku_od < ADD_MONTHS(SYSDATE, -144);

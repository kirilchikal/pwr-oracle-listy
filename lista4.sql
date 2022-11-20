SET SERVEROUTPUT ON
SET VERIFY ON


delete Incydenty;
delete Konto;
delete Elita;
delete Plebs;
delete KocuryR;
drop table Incydenty;
drop table Konto;
drop table Elita;
drop table Plebs;
drop table KocuryR;
drop TYPE body INCYDENTY_TYP;
drop TYPE INCYDENTY_TYP;
drop TYPE BODY KONTO_TYP;
drop TYPE KONTO_TYP;
drop TYPE ELITA_TYP;
drop TYPE PLEBS_TYP;
drop type body KOCURY_TYP;
drop type KOCURY_TYP;


--ZAD 47
CREATE OR REPLACE TYPE KOCURY_TYP AS OBJECT
(
imie VARCHAR2(15),
plec VARCHAR2(1),
pseudo VARCHAR2(15),
funkcja VARCHAR2(10),
szef REF KOCURY_TYP,
w_stadku_od DATE,
przydzial_myszy NUMBER(3),
myszy_extra NUMBER(3),
nr_bandy NUMBER(3),
MEMBER FUNCTION Dane RETURN VARCHAR2,
MEMBER FUNCTION Dochod RETURN NUMBER,
MEMBER FUNCTION WStadkuOd RETURN DATE
);
/

CREATE OR REPLACE TYPE BODY KOCURY_TYP AS
    MEMBER FUNCTION Dane RETURN VARCHAR2 IS
    BEGIN
        RETURN (CASE plec WHEN 'M' THEN 'Kot ' ELSE 'Kotka ' END)|| imie;
    END;
    MEMBER FUNCTION Dochod RETURN NUMBER IS
    BEGIN
        RETURN NVL(przydzial_myszy,0)+NVL(myszy_extra,0);
    END;
    MEMBER FUNCTION WStadkuOd RETURN DATE IS
    BEGIN
        RETURN TO_CHAR(w_stadku_od, 'YYYY-MM-DD');
    END;
END;
/

CREATE OR REPLACE TYPE PLEBS_TYP AS OBJECT
(id_plebsu NUMBER,
osoba REF KOCURY_TYP
);
/

CREATE OR REPLACE TYPE ELITA_TYP AS OBJECT
(id_elity NUMBER,
osoba REF KOCURY_TYP,
sluga REF PLEBS_TYP
);
/

CREATE OR REPLACE TYPE KONTO_TYP AS OBJECT
(
id_akcji NUMBER,
wlasciciel REF ELITA_TYP,
data_wprowadzenia DATE,
data_usuniecia DATE,
MEMBER PROCEDURE dodaj_mysz,
MEMBER PROCEDURE usun_mysz);
/

CREATE OR REPLACE TYPE BODY KONTO_TYP AS
    MEMBER PROCEDURE dodaj_mysz IS
    BEGIN
        data_wprowadzenia:=current_date;
    END;
    MEMBER PROCEDURE usun_mysz IS
    BEGIN
        data_usuniecia:=current_date;
    END;
END;
/

CREATE OR REPLACE TYPE INCYDENTY_TYP AS OBJECT
(
id_incydentu NUMBER,
ofiara REF KOCURY_TYP,
imie_wroga VARCHAR2(15),
data_incydentu DATE,
opis_incydentu VARCHAR2(50),
MEMBER FUNCTION Dane RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY INCYDENTY_TYP AS
    MEMBER FUNCTION Dane RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Incydent z '||imie_wroga||' w dniu '||data_incydentu;
    END;
END;
/


CREATE TABLE KocuryR OF KOCURY_TYP
(CONSTRAINT kr_pk PRIMARY KEY (pseudo),
CONSTRAINT kr_fk_funkcja FOREIGN KEY (funkcja)
                      REFERENCES Funkcje(funkcja),
CONSTRAINT kr_fk_banda FOREIGN KEY (nr_bandy)
                      REFERENCES Bandy(nr_bandy)
);

CREATE TABLE Plebs OF PLEBS_TYP
(CONSTRAINT plebs_pk PRIMARY KEY(id_plebsu),
osoba NOT NULL
);

CREATE TABLE Elita OF ELITA_TYP
(osoba NOT NULL,
sluga SCOPE IS Plebs,
CONSTRAINT el_pk PRIMARY KEY(id_elity)
);

CREATE TABLE Konto OF KONTO_TYP
(
CONSTRAINT konto_pk PRIMARY KEY(id_akcji),
wlasciciel SCOPE IS Elita,
CONSTRAINT konto_dw_nn CHECK(data_wprowadzenia IS NOT NULL),
CONSTRAINT konto_data CHECK(data_wprowadzenia >= data_usuniecia)
);

CREATE TABLE Incydenty OF INCYDENTY_TYP
(
CONSTRAINT inc_pk PRIMARY KEY (id_incydentu),
ofiara SCOPE IS KocuryR,
imie_wroga NOT NULL,
CONSTRAINT inc_fk FOREIGN KEY (imie_wroga) REFERENCES Wrogowie(imie_wroga),
data_incydentu NOT NULL
);
-------------------


INSERT INTO KocuryR VALUES('MRUCZEK','M','TYGRYS','SZEFUNIO',NULL,'2002-01-01',103,33,1);

INSERT ALL
    INTO KocuryR VALUES('BOLEK','M','LYSY','BANDZIOR',(SELECT REF(K) FROM KocuryR K WHERE pseudo='TYGRYS'),'2006-08-15',72,21,2)
    INTO KocuryR VALUES('MICKA','D','LOLA','MILUSIA',(SELECT REF(K) FROM KocuryR K WHERE pseudo='TYGRYS'),'2009-10-14',25,47,1)
    INTO KocuryR VALUES('KOREK','M','ZOMBI','BANDZIOR',(SELECT REF(K) FROM KocuryR K WHERE pseudo='TYGRYS'),'2004-03-16',75,13,3)
    INTO KocuryR VALUES('RUDA','D','MALA','MILUSIA',(SELECT REF(K) FROM KocuryR K WHERE pseudo='TYGRYS'),'2006-09-17',22,42,1)
    INTO KocuryR VALUES('PUCEK','M','RAFA','LOWCZY',(SELECT REF(K) FROM KocuryR K WHERE pseudo='TYGRYS'),'2006-10-15',65,NULL,4)
    INTO KocuryR VALUES('CHYTRY','M','BOLEK','DZIELCZY',(SELECT REF(K) FROM KocuryR K WHERE pseudo='TYGRYS'),'2002-05-05',50,NULL,1)
SELECT * FROM DUAL;
INSERT ALL
    INTO KocuryR VALUES('JACEK','M','PLACEK','LOWCZY',(SELECT REF(K) FROM KocuryR K WHERE pseudo='LYSY'),'2008-12-01',67,NULL,2)
    INTO KocuryR VALUES('BARI','M','RURA','LAPACZ',(SELECT REF(K) FROM KocuryR K WHERE pseudo='LYSY'),'2009-09-01',56,NULL,2)
    INTO KocuryR VALUES('SONIA','D','PUSZYSTA','MILUSIA',(SELECT REF(K) FROM KocuryR K WHERE pseudo='ZOMBI'),'2010-11-18',20,35,3)
    INTO KocuryR VALUES('ZUZIA','D','SZYBKA','LOWCZY',(SELECT REF(K) FROM KocuryR K WHERE pseudo='LYSY'),'2006-07-21',65,NULL,2)
    INTO KocuryR VALUES('PUNIA','D','KURKA','LOWCZY',(SELECT REF(K) FROM KocuryR K WHERE pseudo='ZOMBI'),'2008-01-01',61,NULL,3)
    INTO KocuryR VALUES('BELA','D','LASKA','MILUSIA',(SELECT REF(K) FROM KocuryR K WHERE pseudo='LYSY'),'2008-02-01',24,28,2)
    INTO KocuryR VALUES('LATKA','D','UCHO','KOT',(SELECT REF(K) FROM KocuryR K WHERE pseudo='RAFA'),'2011-01-01',40,NULL,4)
    INTO KocuryR VALUES('DUDEK','M','MALY','KOT',(SELECT REF(K) FROM KocuryR K WHERE pseudo='RAFA'),'2011-05-15',40,NULL,4)
    INTO KocuryR VALUES('KSAWERY','M','MAN','LAPACZ',(SELECT REF(K) FROM KocuryR K WHERE pseudo='RAFA'),'2008-07-12',51,NULL,4)
    INTO KocuryR VALUES('MELA','D','DAMA','LAPACZ',(SELECT REF(K) FROM KocuryR K WHERE pseudo='RAFA'),'2008-11-01',51,NULL,4)
SELECT * FROM DUAL;
INSERT INTO KocuryR VALUES('LUCEK','M','ZERO','KOT',(SELECT REF(K) FROM KocuryR K WHERE pseudo='KURKA'),'2010-03-01',43,NULL,3);

INSERT ALL
    INTO Plebs VALUES(1,(SELECT REF(K) FROM KocuryR K WHERE pseudo='PLACEK'))
    INTO Plebs VALUES(2,(SELECT REF(K) FROM KocuryR K WHERE pseudo='RURA'))
    INTO Plebs VALUES(3,(SELECT REF(K) FROM KocuryR K WHERE pseudo='LOLA'))
    INTO Plebs VALUES(4,(SELECT REF(K) FROM KocuryR K WHERE pseudo='ZERO'))
    INTO Plebs VALUES(5,(SELECT REF(K) FROM KocuryR K WHERE pseudo='PUSZYSTA'))
    INTO Plebs VALUES(6,(SELECT REF(K) FROM KocuryR K WHERE pseudo='UCHO'))
    INTO Plebs VALUES(7,(SELECT REF(K) FROM KocuryR K WHERE pseudo='MALY'))
    INTO Plebs VALUES(8,(SELECT REF(K) FROM KocuryR K WHERE pseudo='LASKA'))
    INTO Plebs VALUES(9,(SELECT REF(K) FROM KocuryR K WHERE pseudo='MAN'))
SELECT * FROM DUAL;

INSERT ALL
    INTO Elita VALUES(1,(SELECT REF(K) FROM KocuryR K WHERE pseudo='TYGRYS'),(SELECT REF(P) FROM Plebs P WHERE id_plebsu=1))
    INTO Elita VALUES(2,(SELECT REF(K) FROM KocuryR K WHERE pseudo='BOLEK'),NULL)
    INTO Elita VALUES(3,(SELECT REF(K) FROM KocuryR K WHERE pseudo='ZOMBI'),(SELECT REF(P) FROM Plebs P WHERE id_plebsu=3))
    INTO Elita VALUES(4,(SELECT REF(K) FROM KocuryR K WHERE pseudo='LYSY'),(SELECT REF(P) FROM Plebs P WHERE id_plebsu=4))
    INTO Elita VALUES(5,(SELECT REF(K) FROM KocuryR K WHERE pseudo='SZYBKA'),(SELECT REF(P) FROM Plebs P WHERE id_plebsu=1))
    INTO Elita VALUES(6,(SELECT REF(K) FROM KocuryR K WHERE pseudo='MALA'),NULL)
    INTO Elita VALUES(7,(SELECT REF(K) FROM KocuryR K WHERE pseudo='RAFA'),(SELECT REF(P) FROM Plebs P WHERE id_plebsu=7))
    INTO Elita VALUES(8,(SELECT REF(K) FROM KocuryR K WHERE pseudo='KURKA'),(SELECT REF(P) FROM Plebs P WHERE id_plebsu=5))
    INTO Elita VALUES(9,(SELECT REF(K) FROM KocuryR K WHERE pseudo='DAMA'),NULL)
SELECT * FROM DUAL;

INSERT ALL
    INTO Incydenty VALUES(1,(SELECT REF(K) FROM KocuryR K WHERE pseudo='TYGRYS'),'KAZIO','2004-10-13','USILOWAL NABIC NA WIDLY')
    INTO Incydenty VALUES(2,(SELECT REF(K) FROM KocuryR K WHERE pseudo='BOLEK'),'KAZIO','2005-03-29','POSZCZUL BURKIEM')
    INTO Incydenty VALUES(3,(SELECT REF(K) FROM KocuryR K WHERE pseudo='MALA'),'CHYTRUSEK','2007-03-07','ZALECAL SIE')
    INTO Incydenty VALUES(4,(SELECT REF(K) FROM KocuryR K WHERE pseudo='TYGRYS'),'DZIKI BILL','2007-06-12','USILOWAL POZBAWIC ZYCIA')
    INTO Incydenty VALUES(5,(SELECT REF(K) FROM KocuryR K WHERE pseudo='BOLEK'),'DZIKI BILL','2007-11-10','ODGRYZL UCHO')
    INTO Incydenty VALUES(6,(SELECT REF(K) FROM KocuryR K WHERE pseudo='LASKA'),'DZIKI BILL','2008-12-12','POGRYZL ZE LEDWO SIE WYLIZALA')
    INTO Incydenty VALUES(7,(SELECT REF(K) FROM KocuryR K WHERE pseudo='LASKA'),'KAZIO','2009-01-07','ZLAPAL ZA OGON I ZROBIL WIATRAK')
    INTO Incydenty VALUES(8,(SELECT REF(K) FROM KocuryR K WHERE pseudo='DAMA'),'KAZIO','2009-02-07','CHCIAL OBEDRZEC ZE SKORY')
    INTO Incydenty VALUES(9,(SELECT REF(K) FROM KocuryR K WHERE pseudo='MAN'),'REKSIO','2009-04-14','WYJATKOWO NIEGRZECZNIE OBSZCZEKAL')
    INTO Incydenty VALUES(10,(SELECT REF(K) FROM KocuryR K WHERE pseudo='LYSY'),'BETHOVEN','2009-05-11','NIE PODZIELIL SIE SWOJA KASZA')
    INTO Incydenty VALUES(11,(SELECT REF(K) FROM KocuryR K WHERE pseudo='RURA'),'DZIKI BILL','2009-09-03','ODGRYZL OGON')
    INTO Incydenty VALUES(12,(SELECT REF(K) FROM KocuryR K WHERE pseudo='PLACEK'),'BAZYLI','2010-07-12','DZIOBIAC UNIEMOZLIWIL PODEBRANIE KURCZAKA')
    INTO Incydenty VALUES(13,(SELECT REF(K) FROM KocuryR K WHERE pseudo='PUSZYSTA'),'SMUKLA','2010-11-19','OBRZUCILA SZYSZKAMI')
    INTO Incydenty VALUES(14,(SELECT REF(K) FROM KocuryR K WHERE pseudo='KURKA'),'BUREK','2010-12-14','POGONIL')
    INTO Incydenty VALUES(15,(SELECT REF(K) FROM KocuryR K WHERE pseudo='MALY'),'CHYTRUSEK','2011-07-13','PODEBRAL PODEBRANE JAJKA')
    INTO Incydenty VALUES(16,(SELECT REF(K) FROM KocuryR K WHERE pseudo='UCHO'),'SWAWOLNY DYZIO','2011-07-14','OBRZUCIL KAMIENIAMI')
SELECT * FROM DUAL;

INSERT ALL
    INTO Konto VALUES(1,(SELECT REF(E) FROM Elita E WHERE id_elity=1),SYSDATE,NULL)
    INTO Konto VALUES(2,(SELECT REF(E) FROM Elita E WHERE id_elity=2),SYSDATE,NULL)
    INTO Konto VALUES(3,(SELECT REF(E) FROM Elita E WHERE id_elity=3),SYSDATE,NULL)
    INTO Konto VALUES(4,(SELECT REF(E) FROM Elita E WHERE id_elity=8),SYSDATE,NULL)
    INTO Konto VALUES(5,(SELECT REF(E) FROM Elita E WHERE id_elity=8),SYSDATE,NULL)
    INTO Konto VALUES(6,(SELECT REF(E) FROM Elita E WHERE id_elity=1),SYSDATE,NULL)
    INTO Konto VALUES(7,(SELECT REF(E) FROM Elita E WHERE id_elity=7),SYSDATE,NULL)
    INTO Konto VALUES(8,(SELECT REF(E) FROM Elita E WHERE id_elity=1),SYSDATE,NULL)
    INTO Konto VALUES(9,(SELECT REF(E) FROM Elita E WHERE id_elity=1),SYSDATE,NULL)
    INTO Konto VALUES(10,(SELECT REF(E) FROM Elita E WHERE id_elity=4),SYSDATE,NULL)
SELECT * FROM DUAL;
COMMIT;

------------------
--REFERENCJA
------------------
SELECT DEREF(osoba).pseudo "Elita", DEREF(sluga).osoba.Dane() "Sluga"
FROM Elita
WHERE sluga is not null;

--Koty z myszami na koncie
SELECT E.osoba.Dane() "Dane wlasciciela", K.data_wprowadzenia "Data wprowadzenia"
FROM Elita E LEFT JOIN Konto K ON K.wlasciciel=REF(E)
WHERE K.data_wprowadzenia > K.data_usuniecia OR K.data_usuniecia IS NULL;


------------------
--PODZAPYTANIE
------------------
--Dane slug
SELECT P.osoba.imie "Imie", P.osoba.funkcja, NVL(P.osoba.przydzial_myszy,0)+NVL(P.osoba.myszy_extra,0) "Dochod"
FROM Plebs P
WHERE P.osoba.pseudo IN (SELECT E.sluga.osoba.pseudo
                         FROM Elita E);

------------------
--GRUPOWANIE
------------------
SELECT K.wlasciciel.osoba.pseudo "Wlasciciel", COUNT(*) "Ile ma myszy"
FROM Konto K
WHERE K.data_wprowadzenia > K.data_usuniecia OR K.data_usuniecia IS NULL
GROUP BY K.wlasciciel.osoba.pseudo
ORDER BY 2 DESC;

-------------------

--ZAD 18
SELECT K.imie "Imie", K.WStadkuOd() "Poluje od"
FROM Kocuryr K JOIN Kocuryr K1 ON K1.imie='JACEK'
WHERE K.w_stadku_od < K1.w_stadku_od
ORDER BY 2 DESC;

--ZAD  23
SELECT K.imie "Imie", K.Dochod()*12 "Dawka roczna", 'powyzej 864'
FROM KocuryR K
WHERE K.myszy_extra IS NOT NULL AND K.Dochod()*12 > 864
UNION ALL
SELECT K.imie "Imie", K.Dochod()*12 "Dawka roczna", '864'
FROM KocuryR K
WHERE K.myszy_extra IS NOT NULL AND K.Dochod()*12 = 864
UNION ALL
SELECT K.imie "Imie", K.Dochod()*12 "Dawka roczna", 'ponizej 864'
FROM KocuryR K
WHERE K.myszy_extra IS NOT NULL AND K.Dochod()*12 < 864
ORDER BY 2 DESC;

--ZAD 37
DECLARE
    i NUMBER:=1;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Nr  Pseudonim  Zjada');
    DBMS_OUTPUT.PUT_LINE(LPAD('-',20,'-'));
    FOR cr IN (SELECT K.pseudo pseudo,K.Dochod() myszy
                FROM KocuryR K
                ORDER BY 2 DESC)
    LOOP 
        EXIT WHEN i>5;
        DBMS_OUTPUT.PUT_LINE(i||'   '||RPAD(cr.pseudo,9)||'   '||cr.myszy);
        i:=i+1;
    END LOOP;
END;
/

--ZAD 38
DECLARE
    maxl NUMBER:='&n';
    i NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Wynik dla liczby przelozonych = '||maxl);
    DBMS_OUTPUT.PUT(RPAD('Imie', 15));
    FOR i IN 1..maxl LOOP
        DBMS_OUTPUT.PUT(RPAD('|  Sfef '||i, 18));
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT(RPAD('-',13,'-'));
    FOR i IN 1..maxl LOOP
        DBMS_OUTPUT.PUT(' --- '||RPAD('-',13,'-'));
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    
    FOR kot IN (SELECT imie, pseudo, szef FROM KocuryR WHERE funkcja IN ('KOT','MILUSIA')) 
    LOOP
        DBMS_OUTPUT.PUT(RPAD(kot.imie, 15));
        FOR i IN 1..maxl 
        LOOP
            IF kot.szef IS NULL THEN DBMS_OUTPUT.PUT(RPAD('|', 18));   
            ELSE SELECT imie, pseudo, szef INTO kot FROM KocuryR WHERE DEREF(kot.szef).pseudo=pseudo;
                DBMS_OUTPUT.PUT(RPAD('|  '||kot.imie, 18)); 
            END IF;
        END LOOP;
        DBMS_OUTPUT.NEW_LINE;
    END LOOP;
END;
/




--------------
----ZADANIE 48
--------------
SET SERVEROUTPUT ON
SET VERIFY ON


DELETE Konta_T;
DELETE Elita_T;
DELETE Plebs_T;
DROP TABLE Konta_T;
DROP TABLE Elita_T;
DROP TABLE Plebs_T;

DROP TYPE BODY KONTO1_TYP;
DROP TYPE KONTO1_TYP;
DROP TYPE ELITA1_TYP;
DROP TYPE PLEBS1_TYP;
DROP TYPE BODY KOCURY_NOWY_TYP;
DROP TYPE KOCURY_NOWY_TYP;



CREATE TABLE Plebs_T
(pseudo VARCHAR2(15) CONSTRAINT plebs_prk PRIMARY KEY
        CONSTRAINT plebs_ko_fok REFERENCES Kocury(pseudo));

CREATE TABLE Elita_T
(pseudo VARCHAR2(15) CONSTRAINT elita_t_pk PRIMARY KEY
        CONSTRAINT elita_ko_fok REFERENCES Kocury(pseudo),
sluga VARCHAR2(15) CONSTRAINT elita_sl_fok REFERENCES Plebs_T(pseudo));

CREATE TABLE Konta_T
(id_akcji NUMBER CONSTRAINT konta_prk PRIMARY KEY, 
wlasciciel VARCHAR2(15) CONSTRAINT konta_el_fok REFERENCES Elita_T(pseudo),
data_wprowadzenia DATE CONSTRAINT konta_dw_nn CHECK(data_wprowadzenia IS NOT NULL),
data_usuniecia DATE,
CONSTRAINT konta_data CHECK(data_wprowadzenia >= data_usuniecia)
);


INSERT ALL
    INTO Plebs_T VALUES('PLACEK')
    INTO Plebs_T VALUES('RURA')
    INTO Plebs_T VALUES('LOLA')
    INTO Plebs_T VALUES('ZERO')
    INTO Plebs_T VALUES('PUSZYSTA')
    INTO Plebs_T VALUES('UCHO')
    INTO Plebs_T VALUES('MALY')
    INTO Plebs_T VALUES('LASKA')
    INTO Plebs_T VALUES('MAN')
SELECT * FROM DUAL;

INSERT ALL
    INTO Elita_T VALUES('TYGRYS','PLACEK')
    INTO Elita_T VALUES('BOLEK',NULL)
    INTO Elita_T VALUES('ZOMBI','LOLA')
    INTO Elita_T VALUES('LYSY','ZERO')
    INTO Elita_T VALUES('SZYBKA','PLACEK')
    INTO Elita_T VALUES('MALA',NULL)
    INTO Elita_T VALUES('RAFA','MALY')
    INTO Elita_T VALUES('KURKA','PUSZYSTA')
    INTO Elita_T VALUES('DAMA',NULL)
SELECT * FROM DUAL;

INSERT ALL
    INTO Konta_T VALUES(1,'TYGRYS',SYSDATE,NULL)
    INTO Konta_T VALUES(2,'BOLEK',SYSDATE,NULL)
    INTO Konta_T VALUES(3,'ZOMBI',SYSDATE,NULL)
    INTO Konta_T VALUES(4,'KURKA',SYSDATE,NULL)
    INTO Konta_T VALUES(5,'KURKA',SYSDATE,NULL)
    INTO Konta_T VALUES(6,'TYGRYS',SYSDATE,NULL)
    INTO Konta_T VALUES(7,'RAFA',SYSDATE,NULL)
    INTO Konta_T VALUES(8,'TYGRYS',SYSDATE,NULL)
    INTO Konta_T VALUES(9,'TYGRYS',SYSDATE,NULL)
    INTO Konta_T VALUES(10,'LYSY',SYSDATE,NULL)
SELECT * FROM DUAL;

COMMIT;


------------TYPY OBJEKTOWE-----------------
CREATE OR REPLACE TYPE KOCURY_NOWY_TYP AS OBJECT
(imie VARCHAR2(15),
plec VARCHAR2(1),
pseudo VARCHAR2(15),
funkcja VARCHAR2(10),
szef VARCHAR2(15),
w_stadku_od DATE,
przydzial_myszy NUMBER(3),
myszy_extra NUMBER(3),
nr_bandy NUMBER(3),
MEMBER FUNCTION Dane RETURN VARCHAR2,
MEMBER FUNCTION Dochod RETURN NUMBER,
MEMBER FUNCTION WStadkuOd RETURN DATE);
/

CREATE OR REPLACE TYPE BODY KOCURY_NOWY_TYP AS
    MEMBER FUNCTION Dane RETURN VARCHAR2 IS
    BEGIN
        RETURN (CASE plec WHEN 'M' THEN 'Kot ' ELSE 'Kotka ' END)|| imie;
    END;
    MEMBER FUNCTION Dochod RETURN NUMBER IS
    BEGIN
        RETURN NVL(przydzial_myszy,0)+NVL(myszy_extra,0);
    END;
    MEMBER FUNCTION WStadkuOd RETURN DATE IS
    BEGIN
        RETURN TO_CHAR(w_stadku_od, 'YYYY-MM-DD');
    END;
END;
/

CREATE OR REPLACE TYPE PLEBS1_TYP AS OBJECT
(id_plebsu VARCHAR2(15),
pseudo REF KOCURY_NOWY_TYP);
/

CREATE OR REPLACE TYPE ELITA1_TYP AS OBJECT
(id_elity VARCHAR2(15),
pseudo REF KOCURY_NOWY_TYP,
sluga REF PLEBS1_TYP); 
/

CREATE OR REPLACE TYPE KONTO1_TYP AS OBJECT
(id_akcji NUMBER,
wlasciciel REF ELITA1_TYP,
data_wprowadzenia DATE,
data_usuniecia DATE,
MEMBER PROCEDURE dodaj_mysz,
MEMBER PROCEDURE usun_mysz);
/

CREATE OR REPLACE TYPE BODY KONTO1_TYP AS
    MEMBER PROCEDURE dodaj_mysz IS
    BEGIN
        data_wprowadzenia:=current_date;
    END;
    MEMBER PROCEDURE usun_mysz IS
    BEGIN
        data_usuniecia:=current_date;
    END;
END;
/

-------PERSPEKTYWY OBJEKTOWE----------
CREATE OR REPLACE VIEW Kocury_zoid OF KOCURY_NOWY_TYP
WITH OBJECT IDENTIFIER (pseudo) AS
SELECT imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy, myszy_extra,nr_bandy
FROM Kocury;

CREATE OR REPLACE VIEW Plebs_zoid OF PLEBS1_TYP
WITH OBJECT IDENTIFIER (id_plebsu) AS
SELECT pseudo id_plebsu,
    MAKE_REF(Kocury_zoid,pseudo) pseudo
FROM Plebs_T;
--SELECT E.id_plebsu,E.pseudo.imie from Plebs_zoid E;

CREATE OR REPLACE VIEW Elita_zoid OF ELITA1_TYP
WITH OBJECT IDENTIFIER (id_elity) AS
SELECT pseudo id_elity,
    MAKE_REF(Kocury_zoid,pseudo) pseudo,
    MAKE_REF(Plebs_zoid,sluga) sluga
FROM Elita_T;

CREATE OR REPLACE VIEW Konta_zoid AS
SELECT id_akcji,
    MAKE_REF(Elita_zoid,wlasciciel) wlasciciel,
    data_wprowadzenia,data_usuniecia
FROM Konta_T;

----------------------
DROP VIEW Konta_zoid;
DROP VIEW Elita_zoid;
DROP VIEW Plebs_zoid;
DROP VIEW Kocury_zoid;
------------------------


------------------
--REFERENCJA
------------------
SELECT P.id_plebsu "Plebs", P.pseudo.Dochod() "Dochod myszowy" FROM Plebs_zoid P;
SELECT E.pseudo.pseudo "Elita", E.sluga.pseudo.Dane() "Sluga" FROM Elita_zoid E;
--Koty z myszami na koncie
SELECT El.pseudo.Dane() "Dane wlasciciela", COUNT(K.data_wprowadzenia) "Liczba myszy"
FROM Elita_zoid El JOIN Konta_zoid K ON K.wlasciciel=REF(El)
WHERE K.data_wprowadzenia > K.data_usuniecia OR K.data_usuniecia IS NULL
group by El.pseudo;

------------------
--PODZAPYTANIE
------------------
--Dane slug
SELECT P.pseudo.imie "Sluga", P.pseudo.funkcja "Funkcja", P.pseudo.Dochod() "Dochod"
FROM Plebs_zoid P
WHERE P.pseudo IN (SELECT E.sluga.pseudo
                         FROM Elita_zoid E);

------------------
--GRUPOWANIE
------------------
--Dane elity z myszami na koncie
SELECT El.pseudo.Dane() "Dane wlasciciela", COUNT(K.data_wprowadzenia) "Liczba myszy"
FROM Elita_zoid El JOIN Konta_zoid K ON K.wlasciciel=REF(El)
WHERE K.data_wprowadzenia > K.data_usuniecia OR K.data_usuniecia IS NULL
GROUP BY El.pseudo
ORDER BY 2 DESC;


--ZAD 18
SELECT K.Dane() "Imie", K.WStadkuOd() "Poluje od"
FROM Kocury_zoid K JOIN Kocury_zoid K1 ON K1.imie='JACEK'
WHERE K.w_stadku_od < K1.w_stadku_od
ORDER BY 2 DESC;

--ZAD  23
SELECT K.imie "Imie", K.Dochod()*12 "Dawka roczna", 'powyzej 864'
FROM Kocury_zoid K
WHERE K.myszy_extra IS NOT NULL AND K.Dochod()*12 > 864
UNION ALL
SELECT K.imie "Imie", K.Dochod()*12 "Dawka roczna", '864'
FROM Kocury_zoid K
WHERE K.myszy_extra IS NOT NULL AND K.Dochod()*12 = 864
UNION ALL
SELECT K.imie "Imie", K.Dochod()*12 "Dawka roczna", 'ponizej 864'
FROM Kocury_zoid K
WHERE K.myszy_extra IS NOT NULL AND K.Dochod()*12 < 864
ORDER BY 2 DESC;

--ZAD 37
DECLARE
    i NUMBER:=1;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Nr  Pseudonim  Zjada');
    DBMS_OUTPUT.PUT_LINE(LPAD('-',20,'-'));
    FOR cr IN (SELECT K.pseudo pseudo,K.Dochod() myszy
                FROM Kocury_zoid K
                ORDER BY 2 DESC)
    LOOP 
        EXIT WHEN i>5;
        DBMS_OUTPUT.PUT_LINE(i||'   '||RPAD(cr.pseudo,9)||'   '||cr.myszy);
        i:=i+1;
    END LOOP;
END;
/

--ZAD 38
DECLARE
    maxl NUMBER:='&n';
    i NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Wynik dla liczby przelozonych = '||maxl);
    DBMS_OUTPUT.PUT(RPAD('Imie', 15));
    FOR i IN 1..maxl LOOP
        DBMS_OUTPUT.PUT(RPAD('|  Sfef '||i, 18));
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT(RPAD('-',13,'-'));
    FOR i IN 1..maxl LOOP
        DBMS_OUTPUT.PUT(' --- '||RPAD('-',13,'-'));
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    
    FOR kot IN (SELECT imie, pseudo, szef FROM Kocury_zoid WHERE funkcja IN ('KOT','MILUSIA')) 
    LOOP
        DBMS_OUTPUT.PUT(RPAD(kot.imie, 15));
        FOR i IN 1..maxl 
        LOOP
            IF kot.szef IS NULL THEN DBMS_OUTPUT.PUT(RPAD('|', 18));   
            ELSE SELECT imie, pseudo, szef INTO kot FROM Kocury_zoid WHERE kot.szef=pseudo;
                DBMS_OUTPUT.PUT(RPAD('|  '||kot.imie, 18)); 
            END IF;
        END LOOP;
        DBMS_OUTPUT.NEW_LINE;
    END LOOP;
END;
/






--------------
----ZADANIE 49
--------------
ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';

CREATE TABLE Myszy 
(nr_myszy NUMBER CONSTRAINT myszy_pk PRIMARY KEY,
lowca VARCHAR2(15) CONSTRAINT lowca_fk REFERENCES Kocury(pseudo),
zjadacz VARCHAR2(15) CONSTRAINT zjadacz_fk REFERENCES Kocury(pseudo),
waga_myszy NUMBER(3),
data_zlowienia DATE,
data_wydania DATE
);


DECLARE
    data_startu DATE:=TO_DATE('2004-01-01');
    data_koncu DATE:=TO_DATE('2022-01-25');
    liczba_miesiecy INTEGER := MONTHS_BETWEEN(data_koncu, data_startu);
    
-- kolekcja do wstawiania danych w relacje Myszy
    TYPE tm IS TABLE OF Myszy%ROWTYPE INDEX BY BINARY_INTEGER;
    myszki tm;

--zwraca ostatnia srode misiaca
    CURSOR osm IS SELECT  NEXT_DAY(LAST_DAY(ADD_MONTHS(sysdate, -rowNumber + 1)) - 7, 3) "date"
                   FROM (SELECT rownum rowNumber
                         FROM dual
                         CONNECT BY level <= liczba_miesiecy+1);
    TYPE td IS TABLE OF Kocury.w_stadku_od%TYPE INDEX BY BINARY_INTEGER;
    srody td;   --dla kursora osm            
                
    pierw_dzien DATE;   --pierwszy dzien miesiaca
    ost_dzien DATE;     --ostatni dzien miesiaca(ostatnia sroda)
    sr_spoz NUMBER;     --srednie miesieczne spozywienie
    mies_spoz NUMBER := 0;   --miesieczne spozywienie
    ind NUMBER := 1; start_ind NUMBER;
    i BINARY_INTEGER; j BINARY_INTEGER; k BINARY_INTEGER;

--kolekcje do pobierania danych przez masowe zapytanie
    TYPE tp IS TABLE OF Kocury.pseudo%TYPE;
    TYPE tmy IS TABLE OF Kocury.przydzial_myszy%TYPE;
    TYPE twso IS TABLE OF Kocury.w_stadku_od%TYPE;
    tab_ps tp:=tp();
    tab_my tmy:=tmy();
    tab_wso twso:=twso();
    
BEGIN
    DELETE FROM Myszy;
    
    OPEN osm;
    FETCH osm BULK COLLECT INTO srody;  --masowe zapytanie, zwraca kolekcje z datami
    CLOSE osm;
    
    FOR i IN 1..(srody.COUNT-1)
    LOOP
        start_ind := ind;    --numer 1 zlapanej myszy w i-tym miesiacu 
        IF i=0 THEN ost_dzien:=data_koncu; ELSE ost_dzien:=srody(i); END IF;
        pierw_dzien:=TRUNC(ost_dzien, 'MONTH');
        
        --pobieranie danych kotow, ktore sa w stadku w i-tym miesiacu
        SELECT pseudo, przydzial_myszy+NVL(myszy_extra,0), w_stadku_od
        BULK COLLECT INTO tab_ps, tab_my, tab_wso FROM Kocury
        WHERE w_stadku_od < srody(i)
        START WITH szef IS NULL CONNECT BY PRIOR pseudo=szef;
        
        --miesieczne i srednie spozycie myszy przez kotow
        FOR j IN 1..tab_my.COUNT
        LOOP mies_spoz:= mies_spoz+tab_my(j); END LOOP;
        sr_spoz := CEIL(mies_spoz / tab_my.COUNT);
        
        FOR j IN 1..tab_ps.COUNT      --dla kazdego kota dodaj myszy
        LOOP
        --jesli pojawil sie w stadku po piewszym dniu miesiaca - zmien pierwszy dzien na w_stadku_od
            IF tab_wso(j) > pierw_dzien THEN pierw_dzien:=tab_wso(j); END IF;   
            FOR k IN 1..sr_spoz
            LOOP
                myszki(ind).nr_myszy := ind;
                myszki(ind).lowca := tab_ps(j);
                myszki(ind).waga_myszy := CEIL(DBMS_RANDOM.VALUE(16, 50));
                myszki(ind).data_zlowienia := pierw_dzien + DBMS_RANDOM.VALUE(0, ost_dzien - pierw_dzien);
                ind := ind + 1;
            END LOOP;
            mies_spoz := mies_spoz - sr_spoz;
            IF mies_spoz < sr_spoz THEN sr_spoz:= mies_spoz; END IF;
        END LOOP;
        
        --wyplata myszy w kolejnoœci zgodnej z pozycj¹ kota w hierarchii stada
        IF NOT (i = 1 AND data_koncu < srody(i)) THEN 
            k:=1;
            LOOP
                IF tab_my(k) > 0 THEN 
                    myszki(start_ind).zjadacz := tab_ps(k);
                    myszki(start_ind).data_wydania := srody(i);
                    tab_my(k) := tab_my(k)-1;
                    start_ind := start_ind+1;
                END IF;
                IF k = tab_ps.COUNT THEN k:=1; ELSE k:=k+1; END IF;
                EXIT WHEN start_ind = ind;
            END LOOP;
        END IF;    
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('myszek='||myszki.COUNT);
    --przeslanie kolekcji myszki
    FORALL i IN 1..myszki.COUNT 
    INSERT INTO Myszy VALUES(
        myszki(i).nr_myszy,
        myszki(i).lowca,
        myszki(i).zjadacz,
        myszki(i).waga_myszy,
        myszki(i).data_zlowienia,
        myszki(i).data_wydania
    );
END;
/


SELECT * FROM Myszy WHERE nr_myszy < 1000;
SELECT COUNT(*) FROM Myszy WHERE TO_DATE(data_wydania) = TO_DATE('05-04-27');
SELECT SUM(przydzial_myszy+NVL(myszy_extra,0)) FROM Kocury WHERE w_stadku_od < TO_DATE('05-04-27');
SELECT * FROM Myszy WHERE data_wydania is null;



--2 procedury

CREATE OR REPLACE PROCEDURE dodaj_myszy(pseudo VARCHAR, dzien DATE, ile NUMBER)
IS
    nr NUMBER; sr NUMBER; zlowione NUMBER;i BINARY_INTEGER;
    TYPE tm IS TABLE OF Myszy%ROWTYPE INDEX BY BINARY_INTEGER;
    myszki tm;
    niepoprawna_data EXCEPTION;
    za_duzo_myszy EXCEPTION;
BEGIN
    --IF dzien > SYSDATE THEN RAISE niepoprawna_data; END IF;
    SELECT AVG(przydzial_myszy+NVL(myszy_extra,0)) INTO sr FROM Kocury;
    SELECT COUNT(*) INTO zlowione FROM Myszy WHERE lowca=pseudo AND data_zlowienia > TRUNC(dzien, 'MONTH');
    IF ile > (sr-zlowione) THEN RAISE za_duzo_myszy; END IF;
    SELECT MAX(nr_myszy) INTO nr FROM Myszy;
    FOR i IN 1..ile
    LOOP
        nr:=nr+1;
        myszki(i).nr_myszy := nr;
        myszki(i).lowca := pseudo;
        myszki(i).waga_myszy := CEIL(DBMS_RANDOM.VALUE(16, 50));
        myszki(i).data_zlowienia := dzien;
    END LOOP;
    FORALL i IN 1..myszki.COUNT 
    INSERT INTO Myszy VALUES(
        myszki(i).nr_myszy,
        myszki(i).lowca,
        myszki(i).zjadacz,
        myszki(i).waga_myszy,
        myszki(i).data_zlowienia,
        myszki(i).data_wydania
    );
    EXCEPTION
        WHEN niepoprawna_data THEN DBMS_OUTPUT.PUT_LINE('Wprowadzono niepoprawna date');
        WHEN za_duzo_myszy THEN DBMS_OUTPUT.PUT_LINE('Za duzo myszy');
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Pojawil sie wyjatek: '||SQLERRM);
END;
/



CREATE OR REPLACE PROCEDURE wyplata(sroda DATE)   
IS
    TYPE tp IS TABLE OF Kocury.pseudo%TYPE;
    TYPE tmy IS TABLE OF Kocury.przydzial_myszy%TYPE;
    tab_ps tp:=tp();
    tab_my tmy:=tmy();
    TYPE tm IS TABLE OF Myszy%ROWTYPE INDEX BY BINARY_INTEGER;
    myszki tm;
    i NUMBER:=1; k NUMBER:=1;
    niepoprawna_data EXCEPTION;
BEGIN
    --IF sroda != NEXT_DAY(LAST_DAY(sroda) - 7, 3) THEN RAISE niepoprawna_data; END IF;
    SELECT * BULK COLLECT INTO myszki FROM Myszy WHERE data_wydania is null;
    DBMS_OUTPUT.PUT_LINE('Do wydania: '||myszki.count);
    SELECT pseudo, przydzial_myszy+NVL(myszy_extra,0) 
    BULK COLLECT INTO tab_ps, tab_my FROM Kocury
    START WITH szef IS NULL CONNECT BY PRIOR pseudo=szef;
    LOOP
        IF tab_my(k)>0 THEN
            myszki(i).zjadacz := tab_ps(k);
            myszki(i).data_wydania := sroda;
            tab_my(k) := tab_my(k)-1;
            i:= i+1;
        END IF;
        IF k = tab_ps.COUNT THEN k:=1; ELSE k:=k+1; END IF;
        EXIT WHEN i > myszki.COUNT;
    END LOOP;
    FORALL i IN 1..myszki.COUNT 
    UPDATE Myszy SET zjadacz=myszki(i).zjadacz,
                     data_wydania=myszki(i).data_wydania
                 WHERE nr_myszy=myszki(i).nr_myszy;
    EXCEPTION
        WHEN niepoprawna_data THEN DBMS_OUTPUT.PUT_LINE('Data wydania musi byc ostatnia sroda miesiaca');
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Pojawil sie wyjatek: '||SQLERRM);
END;
/

EXECUTE dodaj_myszy('TYGRYS',TO_DATE('22-02-07'),5);
SELECT COUNT(*) FROM Myszy WHERE TO_DATE(data_zlowienia) = TO_DATE('22-02-07');

SELECT SUM(przydzial_myszy+NVL(myszy_extra,0)) FROM Kocury WHERE w_stadku_od < TO_DATE('22-01-26');

EXECUTE wyplata('22-01-26');
SELECT count(*) FROM Myszy WHERE data_wydania is null;
rollback;

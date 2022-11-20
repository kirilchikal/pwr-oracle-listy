SET SERVEROUTPUT ON
SET VERIFY ON
--ZAD 34
DECLARE
    fun Kocury.funkcja%TYPE;
    p1 Kocury.funkcja%TYPE := '&1';
BEGIN
    SELECT funkcja INTO fun 
    FROM Kocury 
    WHERE funkcja = p1;
    DBMS_OUTPUT.PUT_LINE(fun);
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN DBMS_OUTPUT.PUT_LINE('Brak kotow pelniacych podana funkcje');
    WHEN TOO_MANY_ROWS
    THEN DBMS_OUTPUT.PUT_LINE('Znaleziono wiecej niz jeden raz');
END;
/


--Zad 35
DECLARE
    cpm NUMBER;
    im Kocury.imie%TYPE;
    m NUMBER;
BEGIN
    SELECT (NVL(przydzial_myszy,0)+NVL(myszy_extra,0))*12, imie, EXTRACT(month FROM w_stadku_od) INTO cpm, im, m
    FROM Kocury
    WHERE pseudo = '&1';
    IF cpm > 700 THEN DBMS_OUTPUT.PUT_LINE('calkowity roczny przydzial myszy >700');
    ELSIF INSTR(im, 'A') > 0 THEN DBMS_OUTPUT.PUT_LINE('imiê zawiera litere A');
    ELSIF m = 5 THEN DBMS_OUTPUT.PUT_LINE('maj jest miesiacem przystapienia do stada'); 
    ELSE  DBMS_OUTPUT.PUT_LINE('nie odpowiada kryteriom');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Brak kotow o padanym pseudo');
    WHEN OTHERS THEN NULL;
END;
/


--ZAD 36
DECLARE
    CURSOR koty IS SELECT imie, przydzial_myszy, max_myszy
                FROM Kocury NATURAL JOIN Funkcje
                ORDER BY przydzial_myszy;
    cpm NUMBER;
    zm NUMBER := 0;
    nowyp NUMBER;
    podwyzka NUMBER;
BEGIN
    SELECT SUM(przydzial_myszy) INTO cpm
    FROM Kocury;
    <<zewn>> LOOP
        FOR re IN koty
        LOOP
            EXIT zewn WHEN cpm > 1050;
            podwyzka:=ROUND(re.przydzial_myszy*0.1);
            nowyp:=re.przydzial_myszy+podwyzka;
            IF nowyp>re.max_myszy THEN nowyp:=re.max_myszy; podwyzka:=nowyp-re.przydzial_myszy; END IF;
            
            UPDATE Kocury
            SET przydzial_myszy = nowyp
            WHERE imie = re.imie;
            
            IF re.przydzial_myszy!=re.max_myszy THEN zm:=zm+1; END IF;
            cpm:=cpm+podwyzka;
        END LOOP;
    END LOOP zewn;
    DBMS_OUTPUT.PUT_LINE('Calk. przydzial w stadku '||cpm||'   Zmian - '||zm);
    DBMS_OUTPUT.PUT_LINE(RPAD('Imie',15)||'Myszki po podwyzcie');
    DBMS_OUTPUT.PUT_LINE(LPAD('-',34,'-'));
    FOR re IN koty
    LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD(re.imie,15)||LPAD(re.przydzial_myszy,18));
    END LOOP;
    ROLLBACK;
END;
/


--ZAD 37
DECLARE
    i NUMBER:=1;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Nr  Pseudonim  Zjada');
    DBMS_OUTPUT.PUT_LINE(LPAD('-',20,'-'));
    FOR cr IN (SELECT pseudo, przydzial_myszy+NVL(myszy_extra, 0) myszy
                FROM Kocury
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
    DBMS_OUTPUT.PUT_LINE('Wynik dlaliczby przelozonych = '||maxl);
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
    
    FOR kot IN (SELECT imie, pseudo, szef FROM Kocury WHERE funkcja IN ('KOT','MILUSIA')) 
    LOOP
        DBMS_OUTPUT.PUT(RPAD(kot.imie, 15));
        FOR i IN 1..maxl 
        LOOP
            IF kot.szef IS NULL THEN DBMS_OUTPUT.PUT(RPAD('|', 18));   
            ELSE SELECT imie, pseudo, szef INTO kot FROM Kocury WHERE kot.szef=pseudo;
                DBMS_OUTPUT.PUT(RPAD('|  '||kot.imie, 18)); 
            END IF;
        END LOOP;
        DBMS_OUTPUT.NEW_LINE;
    END LOOP;
END;
/


--ZAD 39
DECLARE
    nr_mniejszy_od_zera EXCEPTION;
    juz_istnieje EXCEPTION;
    nr Bandy.nr_bandy%TYPE:='&nr';
    nazw Bandy.nazwa%TYPE:='&naz';
    tr Bandy.teren%TYPE:='&tr';
    n NUMBER;
    powtor VARCHAR(30):= '';
BEGIN
    IF nr <=0 THEN RAISE nr_mniejszy_od_zera; END IF;
    --numer
    SELECT COUNT(*) INTO n FROM Bandy WHERE nr_bandy=nr;
    IF n>0 THEN powtor:=TO_CHAR(nr); END IF;
    --nazwa
    SELECT COUNT(*) INTO n FROM Bandy WHERE nazwa=nazw;
    IF n>0 THEN 
        IF powtor='' THEN powtor:=nazw;
        ELSE powtor:=powtor||', '||nazw;
        END IF;
    END IF;
    --teren
    SELECT COUNT(*) INTO n FROM Bandy WHERE teren=tr;
    IF n>0 THEN 
        IF powtor='' THEN powtor:=tr;
        ELSE powtor:=powtor||', '||tr;
        END IF;
    END IF;
    
    IF LENGTH(powtor)>0 THEN RAISE juz_istnieje; END IF;
    INSERT INTO Bandy (nr_bandy, nazwa, teren)
    VALUES (nr,nazw,tr);
    ROLLBACK;
EXCEPTION
    WHEN nr_mniejszy_od_zera THEN DBMS_OUTPUT.PUT_LINE('Numer bandy jest <= 0');
    WHEN juz_istnieje THEN DBMS_OUTPUT.PUT_LINE(powtor||': juz istnieje');
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/



--ZAD 41
CREATE OR REPLACE TRIGGER numer_wiekszy_o_jeden
BEFORE INSERT ON Bandy FOR EACH ROW
DECLARE
    max_nr NUMBER;
BEGIN
    SELECT MAX(nr_bandy) INTO max_nr FROM Bandy;
    IF :NEW.nr_bandy!=(max_nr+1)
        THEN RAISE_APPLICATION_ERROR(-20001, 'Niepoprawny numer nowej bandy');
    END IF;
END;
/
CALL nowa_banda(6, 'COS', 'DGZIES');
CALL nowa_banda(7, 'a', 'b');



--ZAD 42
--1 sposob
CREATE OR REPLACE PACKAGE wirus AS
    pm_10_tygrys NUMBER;
    kara NUMBER:=0;
    nagroda NUMBER:=0;
END wirus;
/

CREATE OR REPLACE TRIGGER pm_tygrys
BEFORE UPDATE OF przydzial_myszy ON Kocury
BEGIN
    SELECT ROUND(przydzial_myszy*0.1) INTO wirus.pm_10_tygrys FROM Kocury WHERE pseudo='TYGRYS';
END;
/

CREATE OR REPLACE TRIGGER zmiana_pm
BEFORE UPDATE OF przydzial_myszy ON Kocury
FOR EACH ROW WHEN (OLD.funkcja IN ('MILUSIA')) 
DECLARE
    roznica NUMBER;
BEGIN
    IF :NEW.przydzial_myszy > :OLD.przydzial_myszy THEN -- 1warunek
            roznica:=:NEW.przydzial_myszy-:OLD.przydzial_myszy;
            IF roznica<wirus.pm_10_tygrys THEN
                :NEW.przydzial_myszy := :OLD.przydzial_myszy+wirus.pm_10_tygrys;
                :NEW.myszy_extra := :OLD.myszy_extra+5;
                wirus.kara:=wirus.kara+1;
            ELSE wirus.nagroda:=wirus.nagroda+1;
           END IF;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER zmiana_tygrys
AFTER UPDATE OF przydzial_myszy ON Kocury
DECLARE
    ile NUMBER;
BEGIN
    IF wirus.kara>0 THEN
        ile:=wirus.kara;
        wirus.kara:=0;
        UPDATE Kocury SET przydzial_myszy=przydzial_myszy-wirus.pm_10_tygrys*ile WHERE pseudo='TYGRYS';
        DBMS_OUTPUT.PUT_LINE('Kara pm Tygrys: '||ile||' razy = '||wirus.pm_10_tygrys*ile);
    END IF;
    IF wirus.nagroda>0 THEN
        ile:=wirus.nagroda;
        wirus.nagroda:=0;
        UPDATE Kocury SET myszy_extra=myszy_extra+5*ile WHERE pseudo='TYGRYS';
        DBMS_OUTPUT.PUT_LINE('Nagroda me Tygrys: '||ile||' razy = '||5*ile);
    END IF;
END;
/
DROP PACKAGE wirus;
DROP TRIGGER zmiana_pm;
DROP TRIGGER pm_tygrys;
DROP TRIGGER zmiana_tygrys;

--2 sposob
CREATE OR REPLACE TRIGGER przelicz_przydzial
FOR UPDATE OF przydzial_myszy ON Kocury 
COMPOUND TRIGGER
    pm_10_tygrys NUMBER;
    roznica NUMBER;
    kara NUMBER:=0;
    nagroda NUMBER:=0;
    
    BEFORE STATEMENT IS BEGIN
        SELECT ROUND(przydzial_myszy*0.1) INTO pm_10_tygrys FROM Kocury WHERE pseudo='TYGRYS';
        DBMS_OUTPUT.PUT_LINE('10% u tygrysa = '||pm_10_tygrys);
    END BEFORE STATEMENT;
    
    BEFORE EACH ROW IS BEGIN
        IF :NEW.przydzial_myszy > :OLD.przydzial_myszy AND :OLD.funkcja='MILUSIA' THEN -- 1warunek
            roznica:=:NEW.przydzial_myszy-:OLD.przydzial_myszy;
            IF roznica<pm_10_tygrys THEN
                :NEW.przydzial_myszy := :OLD.przydzial_myszy+pm_10_tygrys;
                :NEW.myszy_extra := :OLD.myszy_extra+5;
                kara:=kara+1;
            ELSE nagroda:=nagroda+1;
           END IF;
        END IF;
    END BEFORE EACH ROW;
    
    AFTER STATEMENT IS BEGIN
        IF kara>0 THEN
            UPDATE Kocury SET przydzial_myszy=przydzial_myszy-pm_10_tygrys*kara WHERE pseudo='TYGRYS';
            DBMS_OUTPUT.PUT_LINE('KARA IS: '|| kara||'    tygrys minus '||pm_10_tygrys*kara);
        END IF;
        IF nagroda>0 THEN
            UPDATE Kocury SET myszy_extra=myszy_extra+5*nagroda WHERE pseudo='TYGRYS';
            DBMS_OUTPUT.PUT_LINE('nagroda IS: '||nagroda||'    tygrys plus '||5*nagroda);
        END IF;
    END AFTER STATEMENT;
END przelicz_przydzial;
/

DROP TRIGGER przelicz_przydzial;
--SPRAWDZANIE
select pseudo, przydzial_myszy, myszy_extra from Kocury where pseudo='TYGRYS'
union all
SELECT pseudo, przydzial_myszy, myszy_extra FROM Kocury WHERE funkcja='MILUSIA';
UPDATE kocury SET przydzial_myszy = (przydzial_myszy + 15) WHERE imie='SONIA';
UPDATE kocury SET przydzial_myszy = (przydzial_myszy + 5) WHERE funkcja='MILUSIA';
ROLLBACK;



--ZAD 43
DECLARE
    CURSOR fun IS (SELECT funkcja FROM Funkcje);
    ile NUMBER;
    suma NUMBER;
    x NUMBER;
BEGIN
    --naglowek
    DBMS_OUTPUT.PUT(RPAD('NAZWA BANDY',17));
    DBMS_OUTPUT.PUT(' '||RPAD('PLEC',6));
    DBMS_OUTPUT.PUT(' '||LPAD('ILE',4));
    FOR f IN fun LOOP
        DBMS_OUTPUT.PUT(' '||LPAD(f.funkcja,9));
    END LOOP;
    DBMS_OUTPUT.PUT(' '||LPAD('SUMA',7));
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT(RPAD('-',17,'-'));
    DBMS_OUTPUT.PUT(' '||RPAD('-',6,'-'));
    DBMS_OUTPUT.PUT(' '||LPAD('-',4,'-'));
    FOR f IN fun LOOP
        DBMS_OUTPUT.PUT(' '||LPAD('-',9,'-'));
    END LOOP;
    DBMS_OUTPUT.PUT(' '||LPAD('-',7,'-'));
    DBMS_OUTPUT.NEW_LINE;
    
    FOR banda IN (SELECT nazwa, nr_bandy FROM Bandy) LOOP
        FOR p IN (SELECT DISTINCT plec FROM Kocury ORDER BY plec) LOOP
            DBMS_OUTPUT.PUT(CASE p.plec WHEN 'D' THEN RPAD(banda.nazwa,18) ELSE RPAD(' ',18) END);
            DBMS_OUTPUT.PUT(CASE p.plec WHEN 'D' THEN RPAD('Kotka',7) ELSE RPAD('Kocor',7) END);
            SELECT COUNT(imie) INTO ile FROM Kocury WHERE Kocury.nr_bandy=banda.nr_bandy AND Kocury.plec=p.plec;
            DBMS_OUTPUT.PUT(LPAD(ile,4));
            suma:=0;
            FOR f IN fun LOOP
              SELECT SUM(DECODE(funkcja, f.funkcja,przydzial_myszy+NVL(myszy_extra,0),0)) INTO x FROM Kocury WHERE Kocury.nr_bandy=banda.nr_bandy AND Kocury.plec=p.plec;
              suma:=suma+x;
              DBMS_OUTPUT.PUT(LPAD(x,10));
            END LOOP;
            DBMS_OUTPUT.PUT(LPAD(suma,7));
            DBMS_OUTPUT.NEW_LINE;
        END LOOP;
    END LOOP;
    
    DBMS_OUTPUT.PUT(RPAD('-',17,'-'));
    DBMS_OUTPUT.PUT(' '||RPAD('-',6,'-'));
    DBMS_OUTPUT.PUT(' '||LPAD('-',4,'-'));
    FOR f IN fun LOOP
        DBMS_OUTPUT.PUT(' '||LPAD('-',9,'-'));
    END LOOP;
    DBMS_OUTPUT.PUT(' '||LPAD('-',7,'-'));
    DBMS_OUTPUT.NEW_LINE;
    
    --podsumowanie
    suma:=0;
    DBMS_OUTPUT.PUT(RPAD('ZJADA RAZEM',29));
    FOR f IN fun LOOP
        SELECT SUM(DECODE(funkcja, f.funkcja,przydzial_myszy+NVL(myszy_extra,0),0)) INTO x FROM Kocury;
        DBMS_OUTPUT.PUT(LPAD(x,10));
        suma:=suma+x;
    END LOOP;
    DBMS_OUTPUT.PUT(LPAD(suma,7));
    DBMS_OUTPUT.NEW_LINE;
END;
/
SELECT DISTINCT plec FROM Kocury;



--ZAD 40, ZAD 44
CREATE OR REPLACE PACKAGE pakiet_fun_proc AS
    PROCEDURE nowa_banda(nr NUMBER, nazw Bandy.nazwa%TYPE, tr Bandy.teren%TYPE);
    FUNCTION podatek(ps Kocury.pseudo%TYPE, dodatek NUMBER:=0)RETURN NUMBER;
END pakiet_fun_proc;
/
CREATE OR REPLACE PACKAGE BODY pakiet_fun_proc AS
    --zad 40
    PROCEDURE nowa_banda(nr NUMBER, nazw Bandy.nazwa%TYPE, tr Bandy.teren%TYPE)
    AS
        nr_mniejszy_od_zera EXCEPTION;
        juz_istnieje EXCEPTION;
        n NUMBER;
        powtor VARCHAR(30):= '';
    BEGIN
        IF nr <=0 THEN RAISE nr_mniejszy_od_zera; END IF;
        --numer
        SELECT COUNT(*) INTO n FROM Bandy WHERE nr_bandy=nr;
        IF n>0 THEN powtor:=TO_CHAR(nr); END IF;
        --nazwa
        SELECT COUNT(*) INTO n FROM Bandy WHERE nazwa=nazw;
        IF n>0 THEN 
            IF powtor='' THEN powtor:=nazw;
            ELSE powtor:=powtor||', '||nazw;
            END IF;
        END IF;
        --teren
        SELECT COUNT(*) INTO n FROM Bandy WHERE teren=tr;
        IF n>0 THEN 
            IF powtor='' THEN powtor:=tr;
            ELSE powtor:=powtor||', '||tr;
            END IF;
        END IF;
        
        IF LENGTH(powtor)>0 THEN RAISE juz_istnieje; END IF;
        INSERT INTO Bandy (nr_bandy, nazwa, teren)
        VALUES (nr,nazw,tr);
        ROLLBACK;
    EXCEPTION
        WHEN nr_mniejszy_od_zera THEN DBMS_OUTPUT.PUT_LINE('Numer bandy jest <= 0');
        WHEN juz_istnieje THEN DBMS_OUTPUT.PUT_LINE(powtor||': juz istnieje');
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
    END nowa_banda;
    
    --zad 44
    FUNCTION podatek(ps Kocury.pseudo%TYPE, dodatek NUMBER:=0) RETURN NUMBER IS
        obowiazek NUMBER;
        bez_podwl NUMBER:=0;
        bez_wrogow NUMBER:=0;
        res NUMBER;
    BEGIN 
        SELECT CEIL(0.05*(przydzial_myszy+NVL(myszy_extra,0))) INTO obowiazek FROM Kocury WHERE pseudo=ps;
        SELECT COUNT(*) INTO bez_podwl FROM Kocury WHERE szef=ps;
        SELECT COUNT(*) INTO bez_wrogow FROM Wrogowie_Kocurow WHERE pseudo=ps;
        
        IF bez_podwl>0 THEN bez_podwl:=0; ELSE bez_podwl:=2; END IF;
        IF bez_wrogow>0 THEN bez_wrogow:=0; ELSE bez_wrogow:=1; END IF;
        res:=obowiazek+bez_podwl+bez_wrogow+dodatek;
        RETURN res;
    END podatek;
END pakiet_fun_proc;
/ 

CALL pakiet_fun_proc.nowa_banda(2, 'CZARNI RYCERZE', 'POLE');
CALL pakiet_fun_proc.nowa_banda(1, 'COS', 'SAD');
CALL pakiet_fun_proc.nowa_banda(-2, 'COS', 'GDZIES');
SELECT pakiet_fun_proc.podatek('ZOMBI') FROM DUAL;



--ZAD 45
CREATE TABLE Dodatki_extra (
    nr_dodatku NUMBER(5) GENERATED BY DEFAULT AS IDENTITY,
    pseudo VARCHAR(15),
    extra NUMBER(3) NOT NULL
);
--WYZWALACZ
CREATE OR REPLACE TRIGGER sprawdz_extra
BEFORE UPDATE OF przydzial_myszy ON Kocury
FOR EACH ROW WHEN (OLD.funkcja IN ('MILUSIA'))
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    IF LOGIN_USER != 'TYGRYS' THEN
        IF :NEW.przydzial_myszy > :OLD.przydzial_myszy THEN
            DBMS_OUTPUT.PUT_LINE('ZMIANA PRZEZ: '||LOGIN_USER);
            EXECUTE IMMEDIATE '
                BEGIN 
                    FOR kot IN (SELECT pseudo FROM Kocury WHERE funkcja IN (''MILUSIA'')) LOOP
                        INSERT INTO Dodatki_extra (pseudo, extra) VALUES (kot.pseudo,-10);
                    END LOOP;
                END;';
            COMMIT;
        END IF;
    END IF;
END sprawdz_extra;
/
DROP TRIGGER sprawdz_extra;
UPDATE Kocury SET przydzial_myszy=przydzial_myszy + 10 WHERE funkcja='MILUSIA';
ROLLBACK;
SELECT * FROM Dodatki_extra;



--ZAD 46
CREATE TABLE Wykroczenia (
    kto VARCHAR(15),
    kiedy DATE,
    komu VARCHAR(15),
    operacja VARCHAR(15)
);

CREATE OR REPLACE TRIGGER spoza_przedzialu
BEFORE INSERT OR UPDATE ON Kocury
FOR EACH ROW 
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    min_P NUMBER(3);
    max_P NUMBER(3);
    operacja VARCHAR(15):='UPDATING';
BEGIN
    SELECT min_myszy, max_myszy INTO min_P, max_P FROM Funkcje WHERE Funkcje.funkcja=:NEW.funkcja;
    IF INSERTING THEN operacja:='INSERTING'; END IF;
    
    IF :NEW.przydzial_myszy < min_p OR :NEW.przydzial_myszy > max_p THEN
        INSERT INTO Wykroczenia VALUES (SYS.LOGIN_USER,CURRENT_DATE,:NEW.pseudo,operacja);
        COMMIT;
        :NEW.przydzial_myszy :=: OLD.przydzial_myszy;
    END IF;
END spoza_przedzialu;
/
DROP TRIGGER spoza_przedzialu;
--UPDATE Kocury SET przydzial_myszy=40 WHERE pseudo='DAMA';
--INSERT INTO KOCURY VALUES('KOT','M','BOB','HONOROWA','ZOMBI','21-03-18',26,null,2);
SELECT * FROM KOCURY WHERE pseudo='BOB' OR pseudo='DAMA';
ROLLBACK;
SELECT * FROM Wykroczenia;

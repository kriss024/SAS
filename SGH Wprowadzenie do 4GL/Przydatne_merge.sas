DATA dads;
 INPUT famid name $ inc;
DATALINES;
2 Art  22000
1 Bill 30000
3 Paul 25000
4 Karl 95000
;
RUN;

DATA faminc;
 INPUT famid faminc96 faminc97 faminc98;
DATALINES;
3 75000 76000 77000
1 40000 40500 41000
2 45000 45400 45800
5 55000 65000 70000
6 22000 24000 28000
;
RUN;

PROC SORT DATA=dads;
 BY famid;
RUN;

PROC SORT DATA=faminc;
 BY famid;
RUN;

/*---------------------------------------*/

/* ��czenie zbior�w jeden pod drugim */

DATA combined1;
	SET dads faminc;
RUN;

DATA combined1;
	SET dads(IN=fromdadx) faminc(IN=fromfamx);
  	fromdad = fromdadx;
  	fromfam = fromfamx;
RUN;

/* ��czenie zbior�w jeden pod drugim i sortowanie by */

DATA combined2;
	SET dads faminc;
	BY famid;
RUN;


/* ��czenie dw�ch zbir�w po kluczu, zbiory musz� by� prostowane */

DATA merge12;
  MERGE dads faminc;
  BY famid;
RUN;

/* ��czenie dw�ch zbior�w obok siebie */

DATA merge12a;
  MERGE dads faminc;
RUN;

DATA merge12b;
  SET dads;
  SET faminc;
RUN;

/* ��czenie dw�ch zbir�w po kluczu oraz dodanie informacji sk�d pochodzi obserwacja */


DATA merge121;
  MERGE dads(IN=fromdadx) faminc(IN=fromfamx);
  BY famid;
  fromdad = fromdadx;
  fromfam = fromfamx;
RUN;

/* Tylko cz�� wsp�lna */

DATA merge122;
  MERGE dads(IN=fromdadx) faminc(IN=fromfamx);
  BY famid;
  fromdad = fromdadx;
  fromfam = fromfamx;
  if fromdad=1 and fromfam=1; 
RUN;


/* Aktualizowanie danych oraz dodawanie tych kt�rych nie ma */

DATA update2;
   update dads faminc;
   by famid;
RUN;

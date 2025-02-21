libname spdepd3 spde "C:\Kurs\PD3\spde";

libname spdepd3 spde "C:\Kurs\PD3\spde" startobs=3;

proc print data=spdepd3.class;
run;

libname spdepd3 spde "C:\Kurs\PD3\spde" datapath=("C:\Kurs\PD3\f1" "C:\Kurs\PD3\f2");

/* Kopiowanie zbioru danych, select <zbiór> */

proc copy in=sashelp out=spdepd3;
	select prdsale;
run;

proc sort data=sashelp.prdsale;
by country;
run;

proc print data=sashelp.prdsale;
by country;
run;

proc sort data=sashelp.prdsale;
by country division;
run;

proc print data=sashelp.prdsale;
by country division;
run;

/* ÆWICZENIE 1*/

libname spdepd3 base "C:\Kurs\PD3";

libname spdepd4 spde "C:\Kurs\PD3\spde4" startobs=1 endobs=200;

data spdepd4.history(index=(FLIGHT YEAR) asyncindex=yes);
	set spdepd3.history;
	YEAR=year(date);
run;
/*
data spdepd4.history(index=(flight_year_idx=(FLIGHT YEAR)) asyncindex=yes);
	set spdepd3.history;
	YEAR=year(date);
run;
*/
proc print data=spdepd4.history;
by FLIGHT;
run;

/* Wyczytywanie plików tekstowych */
filename dane "C:\Kurs\PD3";
filename osoby "C:\Kurs\PD3\osoby.txt";

filename _all_ list; /* Wyœwietlanie refrencji do plików */

data osoby;
infile dane(osoby.txt) MISSOVER dlm='09'x /*tabulator */ firstobs=2 obs=4;
input ID  WZROST  WAGA  PLEC $ WIEK  IMIE $;
run;

***************;
* Dane rozdzielone separatorami ;
DATA osoby;
  INFILE dane(osoby2.txt) MISSOVER DLM=';';
  INPUT id wzrost waga plec $ wiek imie $;
RUN;


***************;
* Plik tekstowy z ustalon¹ szerokoœci¹ kolumn ;
DATA osoby;
  INFILE dane(osoby3.txt) MISSOVER;
  INPUT id 1 wzrost 2-4 waga 5-6 plec $ 7 wiek 8-9 imie $ 10-16;
RUN;

data osoby4;
infile dane(osoby4.txt) MISSOVER dlm='09'x;
input ID $3. /* 3 znaki tekstu */  IMIE $7.  PENSAJ comma9.2 +2  DATA yymmdd8.;
format DATA ddmmyy10.;
run;

*************;
* polecenie CARDS / DATALINES;

data osoby5;
infile datalines;
input ID $3. IMIE $7.  PENSAJ comma9.2 +2  DATA yymmdd8.;
datalines;
1  Jan    10,234.20  97/01/03
2  Tomasz  9,111.00  97/02/01
3  Kamil  12,543.33  97/01/02
4  Anna   23,000.00  97/02/01
5  Hanna     987.50  97/01/30
6  Zofia  11,211.00  97/02/01
run;


DATA osoby;
  INFILE CARDS DLM=';';
  INPUT id imie $ pensja :comma9.2 data yymmdd8.;
CARDS4;
1;Jan;10,234.20;97/01/03
2;Tomasz;9,111.00;97/02/01
3;Kamil;12,543.33;97/01/02
4;Anna;23,000.00;97/02/01
5;Hanna;987.50;97/01/30
6;Zofia;11,211.00;97/02/01
;;;;
RUN;

DATA osoby3;
  input @1  subj 4. 
        @6  f_name $11. 
		@18 l_name $6.
		+3 height 2. 
        +5 wt_date mmddyy8. 
        +1 calorie comma5.;
  DATALINES;
1024 Alice       Smith  1 65 125 12/1/95  2,036
1167 Maryann     White  1 68 140 12/01/95 1,800
1168 Thomas      Jones  2    190 12/2/95  2,302
1201 Benedictine Arnold 2 68 190 11/30/95 2,432
1302 Felicia     Ho     1 63 115 1/1/96   1,972
  ;
RUN;



/* ÆWICZENIE 1*/

data pracownicy;
infile dane(pracownicy.txt); /* Domyœlny separator spacja */
input ID 
	  NAZWISKO :$15. /* :$15. d³ugoœæ kolumny tekstowej = 15 */
      IMIE $ :10.
      KOD $ :2. /* :2. d³ugoœæ kolumny tekstowej = 2 */
      DATA_UR :ddmmyy8. +9
	  ID
      x
      DATA_ZATR :ddmmyy8.
      PLEC $ :1.
      SPRZEDAZ 
      ODDZIAL
      ZAROBKI;
format DATA_UR DATA_ZATR ddmmyy10.;
drop x;
run;

/* Zapisywanie do pliku */

data _null_;
	set osoby;
	file 'C:\Kurs\PD3\wynik.txt' dlm=';';
	put id imie $ data ddmmyy9.;
run;

/* Dopisywanie do pliku */

data _null_;
	file "&path\cwiczenie.txt" dsd mod;
	set ostroleka;	
	put imie plec pesel miasto;
run;

data _null_;
	file "&path\cwiczenie.txt" dsd mod;
	set warszawa;	
	put imie plec pesel miasto;
run;

data _null_;
	file "&path\cwiczenie.txt" dsd mod;
	set siedlce;	
	put imie plec pesel miasto;
run;

%macro polacz(plik, zbior);
data _null_;
	file "&plik" dsd mod;
	set &zbior;	
	put imie plec pesel miasto;
run;
%mend;

%polacz(&path\cwiczenie.txt,warszawa)
%polacz(&path\cwiczenie.txt,siedlce)
%polacz(&path\cwiczenie.txt,ostroleka)


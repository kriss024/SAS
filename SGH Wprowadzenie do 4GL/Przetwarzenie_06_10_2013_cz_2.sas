
/* MAKROJÊZYK dzia³a tak jak preprocessor w C++ */

%put Hello, World!;

%put _automatic_;

data test20;
	x = "&sysdate";
	y = "&sysuserid";
run;

/* Definiowanie makrozmiennych */

%let pracownik= Jan Nowak ;
%let pracownik = ' Jan Nowak ';
%let tytul = "Nowy raport";
%let start=;
%let suma=7+5;
%let razem=9;
%let razem=&razem+&suma;
%let x=varlist;
%let &x = pracownik wiek wzrost;

%put _global_;
%put &pracownik;
%put &tytul;
%put &start;
%put &suma;
%put &razem;

libname moja "c:\temp";

/* makro nale¿y skompilowaæ raz uruchamij¹c */
%MACRO rysuj(kurs);

proc gplot data=moja.kupno;
	plot &kurs*data;
run;
quit;

%MEND;

%rysuj(aud);
%rysuj(usd);
%rysuj(chf_k);
%rysuj(eur);

/* ÆWICZENIE.

Napisz makroprogram SPREAD(kurs), który na podstawie zbiorów
KUPNO i SPRZEDAZ wyliczy spread waluty KURS.
Wskazówka: Skorzystaj z opcji RENAME= */

%MACRO SPREAD(kurs);

data spread1;
	merge moja.kupno(rename=(&kurs=&kurs._k)) moja.sprzedaz;
	by data;

	spread = &kurs - &kurs._k;
	keep data spread;
run;

%MEND;

%spread(aud);


proc sort data=sashelp.prdsale out=prdsale;
	by product;
run;

proc print data=prdsale;
	by product;
	sum actual;
	var product region actual;
run;


proc means data=moja.sprzedaz min max mean std kurt median;
	var chf usd;
run;

proc freq data=sashelp.class;
	tables age*sex;
run;

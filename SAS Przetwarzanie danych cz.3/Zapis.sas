DATA _NULL_;
	SET osoby;
	FILE 'wynik.txt';
	PUT id imie $ 4-24 data ddmmyy8.;
RUN;

DATA _NULL_;
	SET osoby;
	PUT id imie $ 4-24 data ddmmyy8.;
RUN;

/*Przekierowanie logu do pliku*/
proc printto LOG='c:\kurs\pd3\class.log' NEW;
run;

proc sort data=sashelp.class out=class_sorted;
	by sex;
run;

PROC PRINT DATA=sashelp.class;
	VAR name age;
RUN;

/*Powrót do ustawieñ domyœlnych*/
PROC PRINTTO PRINT=PRINT LOG=LOG;
RUN;
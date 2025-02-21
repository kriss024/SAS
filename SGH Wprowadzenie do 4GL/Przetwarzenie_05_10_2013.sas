/* uruchmianie F3 lub F8 */
/*
SAS 9.3 Language Reference by Name
http://support.sas.com/documentation/cdl/en/allprodslang/64083/HTML/default/viewer.htm#syntaxByType-statement.htm
*/

data test1; /* zbiór wynikowy */
	set sashelp.class; /* ¿ród³o danych */
run;

libname moja "c:\temp"; /* tworzenie biblioteki */

data moja.test2;
	x = .;
	y = 2;
	z = 3;
	napis = "Hello, world!";
	y = x + z;
run;

/* kropka w polu tabeli to znaczy brak danych */

data test1;
	set sashelp.class; 
	x = Height/Weight;
	row_id = _N_;
	error = _Error_;
run; /* miejsce wstawienia wiersza do tabeli test1 */

/* dodatkowe ukryte kolumny z wektora PDV _N_ i _Error_ */

data test1;
	set sashelp.class; 
	where age > 14 and age < 16;
	x = Height/Weight;
	drop sex Height Weight;
run;

data test1;
	set sashelp.class; 
	where age > 14 and age < 16;
	x = Height/Weight;
	keep sex Height Weight;
run;


/* Æwiczenie 1*/

data moja.BMI;
	set sashelp.class; 
	Weight_kg = Weight*0.55;
	Height_m = Height * 2.54/100;
	BMI = Weight_kg/(Height_m**2);
	keep Name BMI;
run;

/* Æwiczenie 2*/

data moja.Test3;
	set Moja.Kupno;
	EUR_USD = EUR / USD;
	EUR_CHF =  EUR / CHF;
    DT =  WEEKDAY(Data); 
run;

/* if <warunek> then instrukcja; */ 

data moja.Test4;
	x = 1;
	y = 2;
	if x + y > 5 then z = 10;
	if x * y < 7 then z = 100;
run;

/* Æwiczenie 2*/

data moja.Test3;
	set Moja.Kupno;
	EUR_USD = EUR / USD;
	EUR_CHF =  EUR / CHF;
	length DT $ 15;
    if WEEKDAY(Data)=1 then DT = 'Sunday';
	if WEEKDAY(Data)=2 then DT = 'Monday';
	if WEEKDAY(Data)=3 then DT = 'Tuesday';
	if WEEKDAY(Data)=4 then DT = 'Wednesday';
	if WEEKDAY(Data)=5 then DT = 'Thursday';
	if WEEKDAY(Data)=6 then DT = 'Friday';
	if WEEKDAY(Data)=7 then DT = 'Saturday';
run;

data Test5;
	set Moja.Kupno;
	pop_chf = lag(CHF);
	pop_pop_chf = lag2(CHF);
run;

/* Æwiczenie 6*/

data Moja.Test6;
	set Moja.Kupno;
	SREDNIA3 = (CHF+lag(CHF)+lag2(CHF))/3;
	SREDNIA3 = round(SREDNIA3,.0001);
run;

data Moja.Test7;
	retain max 0; /* zapamietywanie zmiannych, nie zmienia siê przy kolejnych petlach data stepa */
	set Moja.Kupno;
	if chf > max then max=chf;
run;

/* Przetwarzenia w grupach

FIRST.zmianna - jest równe 1 gdy jest to pocz¹tek grupy, 0 w przeciwnym wapadku
LAST.zmianna - jest równe 1 gdy jest to koniec grupy, 0 w przeciwnym wapadku

Przetwarzenia w grupach w³¹czamy klauzul¹ BY zmienna; po instrukcji SET 

SAS wymaga aby zbór danych na którym robimy BY by³a posortowany.

*/

proc sort data=sashelp.class out=class;
	by Age;
run;


data Moja.Test8;
	set Work.class; 
	by Age;
	if first.age then x = "pocz¹tek grupy";
	if last.age then x = "koniec grupy";
run;

data Moja.Test9;
	set Work.class; 
	by Age;
	if last.age then 
	do;
		x = 1;
		output;
		
	end;
run;

data Moja.KUPNO_M;
	set Moja.Kupno;
	M = MONTH(Data);
	keep Data CHF M;
run;

data Moja.Test10;
	set Moja.KUPNO_M;
	by M;
    retain Srednia_CHF 0;
	retain index 0;

	if first.M then 
	do;
		Srednia_CHF = 0;
		index = 0;
		
	end;

	Srednia_CHF = Srednia_CHF + CHF;
	index = index + 1;

	if last.M then 
	do;
		Srednia_CHF = round(Srednia_CHF/index,.0001);
		output;
		
	end;
	keep Data Srednia_CHF Max_CHF;
run;

data a b c;
	set sashelp.class;
	if age<=14 then output a;
	else if age = 15 then output b;
	else output c;
run;

data Moja.q1 Moja.q2 Moja.q3 Moja.q4;
	set Moja.Kupno;
	qtr = QTR(Data);
	if qtr=1 then output Moja.q1;
	else if qtr=2 then output Moja.q2;
	else if qtr=3 then output Moja.q3;
	else output Moja.q4;
run;

data test11A;
	set Moja.Kupno;
	where data >= '05OCT2012'd;
run;

data test11B;
	set Moja.Kupno;
	where data >= '01JUN2012'd and data <= '31JUL2012'd; /* daty po angielsku i z d na koñcu */
run;

data test11C;
	set Moja.Kupno(firstobs=10 obs=100);
run;

/* wybierjanie jednej obserwacji, musi byæ stop */

data test11D;
	ik=12;
	set Moja.Kupno point=ik;
	output;
	stop;
run;

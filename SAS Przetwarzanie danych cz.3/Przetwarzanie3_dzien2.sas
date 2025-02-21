libname pd3 "C:\Kurs\PD3";

/* Formaty */
proc format cntlin=pd3.niemcy_format;
run;

proc format cntlin=pd3.polska_format;
run;

/* �WICZENIE 1*/

/* Tworzenie format�w*/
proc format;
	value $cwiczenie  
		"DE"='niemcy'
		"PL"='polska';
run;

/* Stosowanie format�w*/
data cwiczenie;
	set pd3.miasta;
	format=put(kraj,$cwiczenie.);
	region=putn(id,format);
run;
/* Wy�wietlanie sformatownych danych */
proc print data=cwiczenie;
	title2 "�wiczenie 1";
	title "Przetwarzanie tekst�w";
	
run;

/* �WICZENIE 2*/

data staff;
	set pd3.staff;
	id=input(idnum,4.);
	employee=propcase(catx(' ',fname, lname));
	address=cats(propcase(city),',',state);

	keep employee address id;
run;

/* Zliczanie wystapie� w tek�cie */

data _null_;
	tekst = "AB AB ABCABABABCA AB BA";
	put tekst;
	if tekst=reverse(tekst) then put "Jest palindromem";
	else put "Nie jest palidromem";
	c=count(tekst,"AB");
	put "Wyst�pie� AB: " c;
	c=countc(tekst,"AB");
	put "Wyst�pie� A i B: " c;
	c=indexw(tekst,"AB");
	put "Pierwsze wyst�pienie s�owa AB zaczyna si� na pozycji: " c;
run;

/*
AB AB ABCABABABCA AB BA
Nie jest palidromem
Wyst�pie� AB: 7
Wyst�pie� A i B: 17
Pierwsze wyst�pienie s�owa AB zaczyna si� na pozycji: 1
*/

/* Definiowanie w�asnych format�w */

proc format;
	picture kg low-hight="000 000.00 kg";
run;


DATA wagi;
	INPUT waga_in $ @@;
	waga = INPUT(COMPRESS(waga_in,'KG'),8.);

	IF INDEX(waga_in,'K') NE 0 THEN
		waga = 2.22 * waga;
	waga = ROUND(waga);
	format waga kg.;
	DROP waga_in
;
	DATALINES;
60KG 155 82KG 54KG 98
;

/* �WICZENIE 2*/
proc format;
value $zgoda 'T' = 1
		     't' = 1
          	other = 0;
run;
data zgody2;
set pd3.zgody(rename=(zgoda=zgoda1));
zgoda1 = put(zgoda1, $zgoda.);
zgoda = input(zgoda1,1.);
keep pesel zgoda;
run;

/* lub
data tak_nie;
	set pd3.zgody;
	zgoda=UPCASE(zgoda);
	zgoda=COMPRESS(zgoda,"TN",'k'); /* COMPRESS - usuwa spacje w tekscie      
	zgoda=TRANSLATE(zgoda,'01','NT');
	if missing(zgoda) then zgoda="0"; /* missing - sprawdza czy obserwacja jest brakiem danych
	tak_nie = INPUT(zgoda,1.);
	keep pesel tak_nie;
run;

*/

/* Nadawanie format�w w zapytaniu SQL */

proc sql;
create table cars as
select type, avg(invoice) as Avg_Invoice format=dollar8.
from sashelp.cars
group by type
having calculated avg_invoice > 20000
order by 2 desc
;quit;

/* Aktualizacja pola w tabeli */

data car_types;
set cars;
avg_invoice = .;
run;

proc sql;
update car_types A
set avg_invoice = 
  (select avg_invoice 
  from cars B 
  where B.type = A.type)
where exists (
  select 1 
  from cars B
  where B.type = A.type);
quit;
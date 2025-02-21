options symbolgen;
options mprint;

data test;
input id age grp ;
datalines;
1 10 1
2 20 1
3 30 1
4 40 1
5 50 1
1 10 2
2 20 2
3 30 2
4 40 2
5 50 2
;
run;

data test2;
set test nobs=t end=e;
count+1;
N=_N_;  /* numer obserwacji */
TOTAL=t; /* ile jest wszystkich */
EOF=e; /* czy koniec zbioru 1=tak */
if e then call symput("ile",count);
run;

%put &=ile;

proc sql noprint;
select count(*) into :ile2 from test;
quit;

%put &=ile2;

data sample;
   do obsnum=1 to 10 by 2;
      set test point=obsnum;
      if _error_ then abort;
      output;
   end;
   stop; /* opcja point wymaga stop */
run;

/* Prosty przyk³ad z opcj¹ point */

data TestPoint;
obs=2;
set Sample point=obs; /*Tu musi byæ zmienna, nie mo¿e byæ wartoœæ*/
output;
stop;
run;

/* Instrukcja select w  data stepie. */

data wiek12 wiek14 wiekOTHER;
set sashelp.class;
select(Age);
	when (12) output wiek12;
	when (14) output wiek14;
	otherwise do;
		output wiekOTHER;
	end;
end;
run;


/* Czas trwania kodu. */

data _null_;
	format c time.;
	format d yymmdd10.;
	c=time();
	d=today();
	put "CZAS START: "   c  ;
	put "DZIEN START: " d;
run;


data temp;
str = "Mr. Rob/K*Thomas";
/* Extracting Title First Name and Surname */
title = SCAN(str, 1);
first_name = SCAN(str,2);
surname = SCAN(str,-1);
invalid_second_arg_1 = SCAN(str,100);
invalid_second_arg_2 = SCAN(str,0);
run;
 
proc print data = temp;
run;

/*Autonumerowanie wierszy*/
proc sql;
  create table results as
  select monotonic() as sequence,
         *,
         case
          when (monotonic()=1) then 'First'
          else 'Not First'
         end as text
  from sashelp.class;
quit;

/*Usuwanie zbêdnych znaków*/

data _null_ ; 
string='StudySAS Blog! 17752. ' ;
string1=compress(string,'') ; *Compress spaces. This is default; 
string2=compress(string,'','ak');*Compress alphabetic chars(1,2etc); 
string3=compress(string,'','d') ; *Compress numerical values; 
string4=compress(string,'','l');*Compress  lowercase characters; 
string5=compress(string,'','u');*Compress uppercase characters; 
string6=compress(string,'S','k');*Keeps only specifiedcharacters; 
string7=compress(string,'!.','P');*Compress Punctuations only; 
string8=compress(string,'s','i');*upper/lower case specified characters;
string9=compress(string,'','a');*Compress all upper\lower case  characters ; 
string10=compress(string,'','s') ; * Compress or delete spaces; 
string11=compress(string,'','kd') ; *Compress alphabets (Keeps only digits); 
put string1= ;
put string2= ;
put string3= ;
put string4= ;
put string5= ;
put string6= ;
put string7= ;
put string8= ;
put string9= ;
put string10=;
put string11=;
run ;

/*OUTPUT:*/
/**/
/*string1=StudySASBlog!17752.*/
/*string2=StudySAS Blog*/
/*string3=StudySASBlog!.*/
/*string4=SSASB!17752.*/
/*string5=tudylog!17752.*/
/*string6=SSS*/
/*string7=StudySAS Blog 17752*/
/*string8=tudyA Blog! 17752.*/
/*string9=!17752.*/
/*string10=StudySASBlog!17752.*/
/*string11=17752*/

/* Agregacja i statystyki danych */

proc means data = Test noprint nway; /* nway - brak podsumowania w wyniku */
class id /missing;
var age;
output out= TestStats sum=sum_ mean=mean_ n=n_ nmiss=nmiss_;
run; 

proc freq data= Test noprint;
tables id / nocol norow nopercent missing out=TestStats; 
run;

proc univariate data = Test noprint; 
class id;
var age;
output out= TestStats2 sum=sum_ mean=mean_ n=n_ nmiss=nmiss_;
run; 

/* ile wierszy w zbiorze */

%let data_set = sashelp.class;
%let dsid = %sysfunc (open(&data_set));
%let nrows = %sysfunc(attrn(&dsid,nlobs));
%let rc = %sysfunc(close(&dsid));
%put ****&nrows.;

%let data_set = sashelp.class;
%let dsid = %sysfunc (open(&data_set));
%let is_ok = %sysfunc(attrn(&dsid,any));
%let rc = %sysfunc(close(&dsid));
%put ****&is_ok.;

proc sql noprint;
select nobs into :nobs separated by ' ' 
from dictionary.tables
where libname='SASHELP' and memname='CLASS';
quit;
 
%put TNote:  nobs=&nobs;

/* usuwanie zbioru danych */

proc datasets library=work nolist;
delete Test;
run;

proc datasets library=WORK kill nolist; 
run; 
quit;

/* zamiana wartoœci null w zmiennych numerycznych na zera */

data tabela_in;
set tabela_in;
array nvar(*) _numeric_;
do i= 1 to dim(nvar);  
   if nvar(i)= . then nvar(i)= 0;
end;
drop i;
run;

/* zapisywanie raportów do excela */

ods _ALL_ close;
ods rtf style=SASWeb file= &plik_word.;
proc print data=sashelp.class;
run;
ods rtf close;

ods _ALL_ close;
ods excel style=Meadow file= &plik_excel_xlsx.;
proc print data=sashelp.class;
run;
ods excel close;

/* listing wszystkich tabel i widoków z danej biblioteki */

proc sql ;
create table mytables as
select libname, memname, lowcase(cats(libname,'.',memname)) as path
from dictionary.tables
where libname = 'SASHELP' and typemem = 'DATA'
order by memname;
quit;

ods output Members=Members;
proc datasets library=SASHELP memtype=data;
run;
quit;

proc contents data=SASHELP.CARS out=meta(keep=name type) noprint; 
run; 

/* aktualizacja tabeli, dodanie kolumn */

data Big;
length Id 8.;
length Name $8;
length Age 8.;
infile datalines delimiter='09'x;
input Id Name Age;
datalines;
1	Carol	14
2	Jane	12
3	Jeffrey	13
4	Judy	14
6	Thomas	11
5	Mary	15
;
run;

data Small;
length Id 8.;
length Gender $1;
length Age 8.;
infile datalines delimiter='09'x;
input Id Gender Age;
datalines;
1	F	10
2	F	10
7	M	20
3	M	20
5	F	10
5	F	40
;
run;

proc sort data = Big;
by Id;
run;

proc sort data = Small;
by Id;
run;

data Result;
update Big Small;
by Id;
run;

data Result;
set Big Small;
by Id;
run;

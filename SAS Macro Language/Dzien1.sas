options symbolgen;
options mprint;

%put NOTE: Is this a SAS note?;
%put WARNING: Is this a SAS warning?;
%put ERROR: Is this a SAS error?;
%put ERROR- Dalszy ci¹g komunikatu o b³edzie;

%put _automatic_; 	/* wszystkie makro-zmienne */
%put _global_; 		/* makro-zmienne globalne */
%put _user_; 		/* makro-zmienne u¿ytkownika */

%put Today is &sysday; /* data utworzenia sesji SAS */
%put Today is &=sysday;
%put Today is SYSDAY=&sysday;

/*  wyœwietlenie makro-zmiennej - 2 sposoby */
%put dzis jest &sysday;
%put &=sysday;

proc freq data=orion.customer;
table Country /nocum;
footnote "Created &systime &sysday, &sysdate9";
run;

/*czyszczenie stopki*/
footnote;

/*czyszczenie tytu³u*/ 
title;	

%put Ostatnio utworzony zbiór danych &syslast;
%put U¿ytkowanik &sysuserid;
%put Czas rozpoczêcia sesji &systime;
%put Data rozpoczêcia sesji &sysdate9;

data new;
set orion.continent;
run;

%put Ostatnio utworzony zbiór danych &syslast;

proc print data=&syslast;
title "Listing of &syslast";
run;

%let d=&sysdate9; 
%let t=&systime;

proc print data=orion.product_dim;
   where Product_Name contains "Jacket";
   var Product_Name Product_ID Supplier_Name;
   title1 "Product Names Containing 'Jacket'";
   title2 "Report produced &t &d";
run;

proc print  data=orion.employee_payroll;
format Birth_Date Employee_Hire_Date date9.;
where Employee_Hire_Date between "1JAN2007"d and "&SYSDATE"d;
run;

%let name=Ed Norton;

OPTIONS SYMBOLGEN; /* podgl¹d wstawianych wartoœci przez makro */
OPTIONS NOSYMBOLGEN;

%symdel office units; /* usuwanie makro-zmiennych, <nazwa zmiennej> bez &*/

%let type=Internet;
%let age1=30;
%let age2=45;
OPTIONS SYMBOLGEN;
proc print data=orion.customer_dim;
var Customer_Name Customer_Gender Customer_Age;
where (Customer_Group contains "&type") and Customer_Age between &age1 and &age2;
title "&type Customers between &age1 and &age2";
run;
OPTIONS NOSYMBOLGEN;

OPTIONS SYMBOLGEN;
%let var=Last;

proc sort data=orion.staff out=staffhires;
   by Job_Title Emp_Hire_Date;
run;

data &var.Hired;   
   set staffhires;
   by Job_Title;
   if &var..Job_Title; /* jedna kropka jest traktowana jako nazwa makro-zmiennej */
run;

proc print data=&var.Hired;
   id Job_Title;
   var Employee_ID Emp_Hire_Date;
   title "&var Employee Hired within Each Job Title";  
run;

title; 
OPTIONS NOSYMBOLGEN;

%put &var.Hired;

%put x=2+2;
%put x=%eval(2+2); /* oblicza wartoœæ wyra¿enia  dla liczb ca³kowitych */

/* operacje arytmetyczne na ca³kowitych */
/*  %EVAL(); */

/* operacje arytmetyczne na zmiennoprzecinkowych */
/* %SYSEVALF(); */

/* uruchamianie funkcji SASowych */
/* %SYSFUNC(<funkcja()>); */

%put DNS=%sysfunc(propcase(&syslast)); /* wywo³ania funkcji */
%put wartoœæ: %sysfunc(sum(2, 2.5), 4.2);

%let data_zaladowania =  %sysfunc(today(), date9.); 
%let dzis = %sysfunc(today(), 8.); 
%let data_waznosci =  %sysfunc(sum(&dzis., 25), date9.); 
%put data za³adowania: &data_zaladowania;
%put data wa¿nosci: &data_waznosci;

/* %STR() - znaki specjalne traktuje jako tekst */
%let str_print = %str(proc print; run;); 
%put wartoœæ: &str_print;

/* NRSTR(%PUT) - znaki specjalne traktuje jako tekst - jeœli chodzi o procent */
%let nrstr_eval = %nrstr(%eval(2 + 2)); 
%put wartoœæ: &nrstr_eval;

%let statement=title "S&P 500";
%put &statement;

%let statement=%str(title "S&P 500";);
%put &statement;

%let statement=%nrstr(title "S&P 500";);
%put &statement;

%put %substr(ABCD, 2, 2); /* wcina fragment tekstu %SUBSTR (<tekst>, <pocz¹tek>, <ile znaków>); */

/*     ;*';*";*/;quit;run;            /* czyszczenie stosu w Enterprise Guide, w SAS Base opcja (!)Break */

proc contents data=work._all_;
run;

proc catalog cat=work.sasmacr; /* jakie marko-procedury zosta³y utworzone */
contents;
run;

%macro time; /*tworzenie makro-procedury*/
%put The current time is %sysfunc (time(),timeampm.).;
%mend time;
%time  /*uruchomienia makro-procedury, baz ; na koñcu*/

options mstored sasmstore=orion; /* definiowanie biblioteki sta³ej dla makro-programów */
%macro time2 / store source; /* kompilowanie makra do biblioteki sta³ej np. na serwerze opcja „/source” ze Ÿród³em */
%put The current time2 is %sysfunc (time(),timeampm.).;
%mend time2;
%time2

%copy time2 /source; /* wyœwietlanie skompilowanego makra, jeœli jest w³¹czona opcja „/source” */
%copy time2 /source outfile='c:\temp\time2.sas'; /* eksportowanie makra do pliku */

%macro calc(dsn,vars); /* przekazywanie parametrów do marko-procedury */
proc means data=&dsn;
var &vars;
run;
%mend calc;

options mprint;
%calc(orion.Employee_payroll,Salary)
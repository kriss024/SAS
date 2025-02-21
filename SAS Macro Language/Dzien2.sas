%macro wiele_parametrow / parmbuff; /* w³¹czenie mo¿liwoœci przekazywania kilku parametrów do marko-procedury */
	%put &=syspbuff;
%mend wiele_parametrow;

%wiele_parametrow
%wiele_parametrow()
%wiele_parametrow(5,1,2,3,4,5)


data test;
call symputx('a','testowa makro-zmienna'); /* utworzenie makro-zmiennej 'a' i przypisanie do nie tekstu  */
b = a;
run;

%let name=; /* makro-zmienna pusta */
%let name1=;

data class;
set sashelp.class;
call symputx('name1', name ); /* symputx - usuwa spacje po obu stronach tekstu */
call symput('name',symget('name') || name ); 
kolumna_name=symget('name');
run;

%put &=name;
%put &=name1;

%symdel name; /* usuwanie makro-zmiennej */

/* tworzenie 19 makro-zmiennych */
data _null_;
set sashelp.class;
a+1;
call symput('name'||strip(_N_),name); /* strip - usuwanie spacji */
run;

%put _user_;

proc sql noprint; /* wstawianie kilku wyrazów do jednej makro-zmiennej, wyrazy oddzielone spacjami */
	select distinct country
	into :Countries separated by ' '
	from orion.customer;
quit;

%put &=Countries;

%put %scan(&Countries,2);  /* wybieranie 2-go wyrazu z ci¹gu s³ów oddzielonych spacjami */

%macro counts(rows);
   title 'Customer Counts by Gender';
   proc freq data=orion.customer_dim;
      tables
   %if &rows ne  %then &rows *;
      customer_gender;
   run;
%mend counts;

options mprint nomlogic nosymbolgen;

%counts()
%counts(customer_age_group)


proc sql;
	select count(name)
	into :n
	from sashelp.class;

	%let n = &n;   /* strip za pomoc¹ let */

	select name
	into :name1-:name&n
	from sashelp.class;
quit;

%let n=&sqlobs;

%symdel n;
proc sql;
	select name
	into :name1- /* tworzenie nieograniczonej listy makro-zmiennych */
	from sashelp.class;
	%let n=&sqlobs;
quit;

%put &n;

%let a=b;
%let b=c;
%let c=d;

%put &&&a; /*(&&&a =&b=c)*/

%macro listing(custtype);
   %if &custtype= %then %do;
		proc print data=orion.customer noobs;
   		var Customer_ID Customer_Name Customer_Type_ID;
   		title "All Customers"; 
		run;
   %end;
   %else %do;
		proc print data=orion.customer noobs;
      	where Customer_Type_ID=&custtype;
         var Customer_ID Customer_Name;
         title "Customer Type: &custtype";
      run;
	%end;
%mend listing;

%listing(1020)
%listing()

%macro customers(place) / minoperator; /* w³¹czanie mo¿liwoœci korzystania z in */
   %let place=%upcase(&place);
   %if &place in AU CA DE IL TR US ZA %then /* sprawdzanie czy element znajduje siê na liœcie */
   %do;  
      proc print data=orion.customer;
         var customer_name customer_address country;
         where upcase(country)="&place";
         title "Customers from &place";
      run;
   %end;
   %else %put Sorry, no customers from &place..;
%mend customers;

%customers(de)
%customers(aa)


%macro custtype(type) / minoperator;
   %let type=%upcase(&type);
   %if &type in GOLD INTERNET %then 
   %do;
    proc print data=orion.customer_dim;
       var Customer_Group Customer_Name Customer_Gender  
           Customer_Age;
       where upcase(Customer_Group) contains "&type";
       title "&type Customers";
    run;
	%end;
    %else 
		%do;
			%put ERROR: Invalid TYPE: xxx.;
			%put ERROR- Valid TYPE values are INTERNET or GOLD.;
		%end;
%mend custtype;

%custtype(internet)
%custtype(AAAA)


proc sql noprint;
   select country_name into :country1-
      from orion.country;
   %let numrows=&sqlobs; /* &sqlobs - ile by³o rekordów w ostatnim zapytaniu SQL */
quit;

/* makro-pêtle */
%macro putloop;
  %do i=1 %to %eval(&numrows.);
      %put Country&i is &&country&i;
  %end;
%mend putloop;

%putloop; /*uruchomienia makro-procedury*/

%let months = styczen.01 luty.02 marzec.03 kwiecien.04 maj.05;

%macro loop(list);    
/* zliczanie liczby s³ów w ³añcuchu znaków */                                                                                                                                   
%let count = %sysfunc(countw(&list., ' '));
%put *** &count.;

/* pêtla od 1 do liczby s³ów */                                                                                         
%do i = 1 %to %eval(&count.);                                                                                                              
%let word = %scan(&list.,&i., ' ');                                                                                            
%put &word.;                                                                                                                      
%end;                                                                                                                              
%mend; 

%loop(&months.);

%global zmienna1; /* makro-zmienna globalna */

/* tworzenie makro-zmiennej za pomoc¹ call symputx*/
data _null_;
call symputx('  x   ', 123.456);
call symputx('macvar', 123.456, 'g');
run;

%put x=!&x!;

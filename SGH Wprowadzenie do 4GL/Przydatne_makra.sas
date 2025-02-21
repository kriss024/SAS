OPTIONS SYMBOLGEN; /* podgl¹d wstawianych wartoœci przez makro */
OPTIONS NOSYMBOLGEN;

data _null_;
call symputx('today',put(today(),yymmddn8.)); /*20130101*/
call symputx('yymm_v0',put(intnx('month',today(), 0,'e'),yymmN4.));/*1301*/
call symputx('yymm_v1',put(intnx('month',today(), -1,'e'),yymmN4.));
call symputx('yymm_v2',put(intnx('month',today(), -2,'e'),yymmN4.));
call symputx('yymm_v3',put(intnx('month',today(), -3,'e'),yymmN4.));
call symputx('yymm_v4',put(intnx('month',today(), -4,'e'),yymmN4.));
call symputx('yymm_v5',put(intnx('month',today(), -5,'e'),yymmN4.));
call symputx('yymm_v6',put(intnx('month',today(), -6,'e'),yymmN4.));
call symputx('yyyymm_v0',put(intnx('month',today(), 0,'e'),yymmN6.));/*201301*/
call symputx('yyyymm_v1',put(intnx('month',today(), -1,'e'),yymmN6.));
call symputx('yyyymm_v2',put(intnx('month',today(), -2,'e'),yymmN6.));
call symputx('yyyymm_v3',put(intnx('month',today(), -3,'e'),yymmN6.));
call symputx('yyyymm_v4',put(intnx('month',today(), -4,'e'),yymmN6.));
call symputx('yyyymm_v5',put(intnx('month',today(), -5,'e'),yymmN6.));
call symputx('yyyymm_v6',put(intnx('month',today(), -6,'e'),yymmN6.));
call symputx('yymmdd_v0e',put(intnx('month',today(), 0,'e'),yymmdd6.)); /*130131*/
call symputx('yyyy_mm_v1',put(intnx('month',today(), -1,'b'),yymmd.));   /*2013-01*/
call symputx('ddmthyyyy_v0b', put(intnx('month', today(), 0, 'b'), date9.));/*1jan2013*/
call symputx('yyyymmdd_now', put(intnx('day', today(), 0), yymmddn8.));  /*20130101*/
call symputx('yymmdd_now', put(intnx('day', today(), 0), yymmdd6.));  /*130101*/
call symputx('yyyymmdd_v0b',put(intnx('month',today(), 0,'b'),yymmddn8.)); /*20130101*/
call symputx('yyyymmdd_v0e',put(intnx('month',today(), 0,'e'),yymmddn8.)); /*20130131*/
call symputx('yyyymmdd_v1e',put(intnx('month',today(), -1,'e'),yymmddn8.)); /*20130131*/
run;

/*Listing tabel do zbioru danych*/

data final;
stop;
run;

%macro Makro(zm);

proc sql;
create table add as
select libname, memname
from sashelp.vmember
where libname = "&zm."
;quit; 

data final;
set final add;
run;

%mend Makro;

/*Histogram*/

%macro histogram(dataset, zmienna, min, max, by = 1);
proc means data = &dataset. noprint nway;
var &zmienna.;
output out= _stats(drop= _type_) min=min q1=q1 median=median mean=mean q3=q3 max=max ;
run;
proc print data=_stats noobs;
run;
proc univariate data = &dataset. noprint;
where &zmienna. between &min. and &max.;
histogram &zmienna. / midpoints = &min. to &max. by &by.  odstitle=title;
run;
%mend histogram;

%histogram(sashelp.cars, Horsepower, 73, 255);

/* SAS JOIN */

%macro join(main, add, result, key, join);

proc sort data = &main. noequals;
by &key.;
run;

proc sort data = &add. noequals;
by &key.;
run;

%if %upcase(&join.)=INNER %then 
%do;
    data &result.;
    merge
    &main. ( in= s )
    &add. ( in= p );
    by &key.;
    if s and p;
    run;
%end;

%if %upcase(&join.)=LEFT %then 
%do;
    data &result.;
    merge
    &main. ( in= s )
    &add. ( in= p );
    by &key.;
    if s;
    run;
%end;

%mend join;

%join(a1, a2, a3, cust_id, inner);

/*Ostatnia tabela wed³ug daty*/

%macro FIND_LAST_DDS_DATE;
%global dds_date dds_sas_date;
proc sql noprint;
create table acc_tables as
select libname, memname, 
compress(scan(memname, -1,'_')) as postfix_date,
input(compress(scan(memname, -1,'_')), yymmdd6.) as sas_date format=yymmdd10.
from dictionary.tables
where libname = 'DDS'
and memtype = 'DATA'
and lowcase(memname) like '%accounts%'
order by input(compress(scan(memname, -1,'_')), 8.)
;quit;

data _null_; 
set acc_tables end=last; 
if last then do;
call symputx('dds_date',postfix_date); 
call symputx('dds_sas_date',sas_date); 
end;
run; 

%put ***&dds_date.**&dds_sas_date.***;
%mend FIND_LAST_DDS_DATE;

%FIND_LAST_DDS_DATE;

/* sprawdzanie czy s¹ nulle lub braki danych */

%macro sprawdzCzySaNulle(pole,tabela);
proc sql;
   title "Sprawdzanie czy zmienna *&pole* zawiera wartoœci NULL";
   select count(&pole) "Liczba wype³nionych rekordów", 
          count(1) "Liczba wszystkich rekordów", 
          count(1)-count(&pole) "Liczba NULL",
		  count(distinct &pole) "Liczba unikalnych wartoœæ"
   from &tabela;
quit;
%mend;

%sprawdzCzySaNulle(adres,Biblio.Tabela1);
/* ustawianie daty pocz¹tkowej i koñcowej */

data _null_;
	call symputx('yyyymmdd_v3b',put(intnx('month',today(), -3,'b'),yymmddn8.)); 	/*20130101*/
	call symputx('yyyymmdd_v1e',put(intnx('month',today(), -1,'e'),yymmddn8.)); 	/*20130113*/
run;

%put &yyyymmdd_v3b.;
%put &yyyymmdd_v1e.;

proc sql ;
  create table dds_tables as
  select libname, memname, compress(scan(memname, -1,'_')) as data, scan(memname, 1,'_') as tabela
  from dictionary.tables
  where libname = 'DDS' and memtype = 'DATA'
  order by memname;
quit;


proc sql;
create table table1 as
select *, input(data, yymmdd10. ) as data2 format yymmddn8.
from dds_tables
where memname like 'CUSTOMER_______' 
and input(data, 8. ) ne .	
;quit;

proc sql;
create table table2 as
select * from table1
where data2 between input("&yyyymmdd_v3b.", yymmdd10. ) and input("&yyyymmdd_v1e.", yymmdd10. )
order by data2 desc
;quit;


proc sql noprint;
	select memname
	into :nazwy_tabel separated by ' '
	from table2;
    %let ile_tabel=&sqlobs;
quit;

%put ***&ile_tabel.***&nazwy_tabel.;


%macro putloop;
  %do i=1 %to &ile_tabel;
  		%let tabela = %scan(&nazwy_tabel., &i., ' ');
  		%put &tabela.;
  %end;
%mend putloop;

%putloop;
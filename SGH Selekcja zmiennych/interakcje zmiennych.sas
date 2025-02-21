%let source = sashelp.heart;
%let output = nowy_zbior;
%let variables = AgeAtStart Height Weight Diastolic MRW;
%let cut_missing = 0.05;

data a1;
set &source.;
keep AgeAtStart Height Weight Diastolic MRW;
run;

proc contents data=a1 out=meta(keep=name) noprint; 
run; 

proc sql;
create table meta2 as
select a.name as licznik, b.name as mianownik 
from meta a
inner join meta b on a.name ^= b.name
;quit;

data meta3;
set meta2;
retain nr 0;
nr = nr + 1;
new_var = cats('A',put(nr, best.));
lab = catx(' ',licznik,' / ',mianownik);
formula = cats(new_var,' = ',lab,';');
run;

proc sql noprint;
select max(nr) into :rekordy
from meta3;
;quit;

%put *** &rekordy.;

data a2;
set &source.;
run;

%macro ADD_NEW_VARIABLE;
%do i=1 %to %eval(&rekordy.);

data _null_;
obs=&i.;
set meta3 point=obs;
call symputx('new_var',new_var);
call symputx('formula',formula);
call symputx('lab',lab);
output;
stop;
run;

%put *** &formula.;

data a2;
set a2;
&formula.;
label &new_var. = "&lab.";
run;

%end;
%mend ADD_NEW_VARIABLE;

%ADD_NEW_VARIABLE;

proc means data=a2 n nmiss noprint;
var _numeric_;
output out=stats nmiss=;
run;

data _null_;
set stats;
call symputx('licznosc',_freq_);
run;

%put *** &licznosc.;

data stats;
set stats;
drop _type_ _freq_;
run;

proc transpose data=stats out=columns(rename=(col1=Missing));
run;

data numeric;
set columns;
N = &licznosc.;
P_Missing = Missing / N;
if P_Missing > &cut_missing. then delete;
format P_Missing nlpct12.2;
rename _name_ = name;
run;

data char;
set &source.;
keep _character_;
stop;
run;

proc contents data=char out=character(keep=name) noprint; 
run; 

proc sql;
create table all_columns as
select distinct name from 
(select name from character
union all
select name from numeric)
order by name
;quit;

proc sql noprint;
select distinct name
into :variables_list separated by ' '
from all_columns;
quit;

%put *** &variables_list.;

data &output.;
set a2;
keep &variables_list.;
run;

proc report data=meta3; run;
%MACRO DATASET_METADATA(data, report);
%let missing_level = 50;
%let class_level = 20;

proc contents data= &data. out=out_metadata(keep=varnum name type rename  = (type = type2)) noprint;
run;

data out_metadata;
set out_metadata;
length TYPE $10;
select (type2);
   when (1) type = 'numeric';
   when (2) type = 'character';
   otherwise;
end;
keep name type varnum;
run;

proc freq data = &data. nlevels;
ods exclude onewayfreqs;
ods output nlevels = out_n_levels (keep = tablevar nlevels 
rename  = (tablevar = NAME nlevels = N_LEVELS));
run;

proc format;
value nm . = 'MISSING' other = 'OK';
value $ch  '' = 'MISSING' other = 'OK';
run;

ods listing close;
ods output onewayfreqs=out_missing(keep=table frequency percent f_:);

proc freq data = &data.;
tables _all_ / missing;
format _numeric_ nm. _character_ $ch.;
run;

ods output close;
ods listing;

data out_missing;
length name $32;
length status $7;
set out_missing;
array names(*) f_:;
do i = 1 to dim(names);
   if not missing(names(i)) then do;
   name_ = vname(names(i)); 
   name = strip(substr(name_, 3, length(name_)-2));
   status = names(i);
   end;
end;
keep name status frequency percent;
run;

proc sort data = out_missing;
by name status;
run;

proc transpose data=out_missing out=trans_missing(keep=name missing ok);
by name;
id status;
var percent;
run;

proc sort data = out_metadata;
by name;
run;

proc sort data = out_n_levels;
by name;
run;

proc sort data = trans_missing;
by name;
run;

data report_;
merge out_metadata(in=a) out_n_levels trans_missing;
by name;
if a;
if missing(missing) then missing = 0;
run;

proc sort data = report_;
by varnum;
run;

data &report.;
set report_;
length LEVEL $8;
length ROLE $8;
if type = 'character' then level = 'nominal';
if type = 'numeric' then level = 'interval';
if type = 'numeric' and n_levels <= %eval(&class_level.) then level = 'nominal';
if n_levels = 1 then level = 'unary';
role = 'input';
if missing > %eval(&missing_level.) then role = 'reject';
if n_levels = 1 then role = 'reject';
drop varnum;
run;

%MEND DATASET_METADATA;

data test;
set sashelp.heart;
Test = 1;
run;

%DATASET_METADATA(test, wyniki);

proc report data=wyniki; run;
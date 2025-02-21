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

%DATASET_METADATA(sashelp.heart, zmienne);

%let source = sashelp.heart;
%let target = Status;
%let event = "Dead";
%let non_event = "Alive";
%let maxbranch_min = 2;
%let maxbranch_max = 20;
%let criterion_list = gini entropy fastchaid;

data zmienne2;
set zmienne;
level2 = substr(level, 1, 3);
where name ^= "&target." and role = "input";
call symputx('nrows', _N_);
%put ****&nrows.;
run;

%let tabela_zmienne = zmienne2;

%MACRO WEIGHT_OF_EVIDENCE_TREE(source, target, event, non_event, dependent, level, maxbranch, criterion);
%global IV Gini;
%let IV = 0;
%let Gini = 0;

/* Information Value (IV) & Weight of Evidence (WOE) */
data _null_;
set &source.;
call symputx('leafsize', max(floor(_N_ * 0.05), 100));
run;

%put leafsize = &leafsize.;

proc hpsplit data= &source. maxdepth = 1 maxbranch = &maxbranch. leafsize = &leafsize. event = &event. bonferroni;
id &target.;
target &target.;
input &dependent. / level = &level.;
criterion &criterion.;
prune none;
/*code file='c:\work\hpsplhme-code.sas';*/
/*rules file='c:\work\hpsplhme-code.txt';*/
score out = grouping_(keep = &target. _Node_);
run;

data grouping_;
set grouping_;
if missing(_Node_) then _Node_ = 0;
rename _Node_= GRP_&dependent.;
label _Node_ = "GRP_&dependent.";
run;


/* Weight of Evidence (WOE) */

proc sql;
create table tab_ as
select *,
1 as Records,
case when &target. = &non_event. then 1 else 0 end as Non_event,
case when &target. = &event. then 1 else 0 end as Event
from grouping_
;quit;

proc means data = tab_ nway noprint;
class GRP_&dependent.;
var Records Non_event Event;
output out= grp_(drop=_type_ _freq_) sum()=;
run;

proc means data = tab_ nway noprint;
var Records Non_event Event;
output out = tot_(drop=_type_ _freq_) sum()=;
run;

data _null_;
set tot_;
call symputx('sum_records', Records);
call symputx('sum_nonevent', Non_event);
call symputx('sum_event', Event);
run;

proc sql;
create table woe_ as
select 
GRP_&dependent., 
Records,
coalesce(Records/&sum_records., 0) as Records_Distribution format=nlpct12.2,
Non_event,
coalesce(Non_event/&sum_nonevent., 0) as Non_event_Distribution format=nlpct12.2,
Event,
coalesce(Event/&sum_event., 0) as Event_Distribution format=nlpct12.2,
coalesce(Event/Records, 0) as Event_Rate format=nlpct12.2
from grp_
order by GRP_&dependent.
;quit;

data woe_;
set woe_;
WOE = log(Non_event_Distribution / Event_Distribution);
IV = (Non_event_Distribution - Event_Distribution) * WOE;
WOE = coalesce(WOE, 0);
IV = coalesce(IV, 0);
run;

proc means data = woe_ nway noprint;
var IV;
output out = iv_(keep = iv) sum()=;
run;

data _null_;
set iv_;
call symputx('IV', IV);
run;

%put Information Value = &IV.;

data grouping_;
set grouping_;
length WOE_&dependent. 8.;
run;
proc sql;
update grouping_ A
set WOE_&dependent. =
  (select WOE 
  from woe_ B 
  where A.GRP_&dependent. = B.GRP_&dependent.)
where exists (
  select 1 
  from woe_ B
  where A.GRP_&dependent. = B.GRP_&dependent.);
quit;

ods select none;
ods output WilcoxonScores=wx_;
proc npar1way wilcoxon data=grouping_;
where not missing(&target.);
class &target.;
var  WOE_&dependent.; 
run;
ods select all;

data _null_;
    set wx_ end=eof;
    retain U n1 n2;
    if _n_= 1 then do;
		U = abs(ExpectedSum - SumOfScores);
		n1 = N;
	end;
  	else do;
    	n2 = N;
  	end;
    if eof then do;
	   d  = U / (n1 * n2);
       Gini = d * 2; AUC = d + 0.5;
	   keep AUC Gini;
	   call symputx('Gini', Gini);
     output; 
   end;
run;

%put Gini = &Gini.;

/* END - Information Value (IV) & Weight of Evidence (WOE) */
%MEND WEIGHT_OF_EVIDENCE_TREE;

%MACRO WEIGHT_OF_EVIDENCE_BINNING(source, target, event, non_event, dependent, maxbranch);
%global IV Gini;
%let IV = 0;
%let Gini = 0;

/* Information Value (IV) & Weight of Evidence (WOE) */

data a1_;
set &source.;
call symputx('maxclass', min(ceil(sqrt(_N_)), &maxbranch.));
keep &target. &dependent.;
run;

%put maxclass = &maxclass.;

proc rank data=a1_ groups=&maxclass. ties=dense out=a2_ ;
var &dependent.;
ranks GRP_&dependent.;
run;

data a3_;
set a2_;
if missing(GRP_&dependent.) then GRP_&dependent. = -1;
run;

/* Weight of Evidence (WOE) */

proc sql;
create table a4_ as
select *,
1 as Records,
case when &target. = &non_event. then 1 else 0 end as Non_event,
case when &target. = &event. then 1 else 0 end as Event
from a3_
;quit;

proc means data = a4_ nway noprint;
class GRP_&dependent.;
var Records Non_event Event;
output out= grp_(drop=_type_ _freq_) sum()=;
run;

proc means data = a4_ nway noprint;
var Records Non_event Event;
output out = tot_(drop=_type_ _freq_) sum()=;
run;

data _null_;
set tot_;
call symputx('sum_records', Records);
call symputx('sum_nonevent', Non_event);
call symputx('sum_event', Event);
run;

proc sql;
create table woe_ as
select 
GRP_&dependent., 
Records,
coalesce(Records/&sum_records., 0) as Records_Distribution format=nlpct12.2,
Non_event,
coalesce(Non_event/&sum_nonevent., 0) as Non_event_Distribution format=nlpct12.2,
Event,
coalesce(Event/&sum_event., 0) as Event_Distribution format=nlpct12.2,
coalesce(Event/Records, 0) as Event_Rate format=nlpct12.2
from grp_
order by GRP_&dependent.
;quit;

data woe_;
set woe_;
WOE = log(Non_event_Distribution / Event_Distribution);
IV = (Non_event_Distribution - Event_Distribution) * WOE;
WOE = coalesce(WOE, 0);
IV = coalesce(IV, 0);
run;

proc means data = woe_ nway noprint;
var IV;
output out = iv_(keep = iv) sum()=;
run;

data _null_;
set iv_;
call symputx('IV', IV);
run;

%put Information Value = &IV.;

/*End Print - Weight of Evidence (WOE)*/

data a4_;
set a3_;
length WOE_&dependent. 8.;
run;

proc sql;
update a4_ A
set WOE_&dependent. =
  (select WOE 
  from woe_ B 
  where A.GRP_&dependent. = B.GRP_&dependent.)
where exists (
  select 1 
  from woe_ B
  where A.GRP_&dependent. = B.GRP_&dependent.);
quit;

ods select none;
ods output WilcoxonScores=wx_;
proc npar1way wilcoxon data=a4_;
where not missing(&target.);
class &target.;
var  WOE_&dependent.; 
run;
ods select all;

data _null_;
    set wx_ end=eof;
    retain U n1 n2;
    if _n_= 1 then do;
		U = abs(ExpectedSum - SumOfScores);
		n1 = N;
	end;
  	else do;
    	n2 = N;
  	end;
    if eof then do;
	   d  = U / (n1 * n2);
       Gini = d * 2; AUC = d + 0.5;
	   keep AUC Gini;
	   call symputx('Gini', Gini);
     output; 
   end;
run;

%put Gini = &Gini.;

%MEND WEIGHT_OF_EVIDENCE_BINNING;

%MACRO LOOP_VARIABLES(ds_result);

data &ds_result.;
length name $32;
length level $3;
length criterion $12;
length maxbranch 8.;
length IV 8.;
length Gini 8.;
stop;
run;

  %do z=1 %to %eval(&nrows.);
	data z1_;
	obs=&z.;
	set &tabela_zmienne. point=obs; 
	output;
	call symputx('dependent', name);
	call symputx('level', level2);
	stop;
	run;

/***********************/

	%let i=1;

	%do %while (%scan(&criterion_list., &i.) ne );
   		%let next_name = %scan(&criterion_list., &i.);

	  %do j = %eval(&maxbranch_min.) %to %eval(&maxbranch_max.);
	  %let maxbranch = &j.;
	  %let criterion = &next_name.;

	  %WEIGHT_OF_EVIDENCE_TREE(&source., &target., &event., &non_event., &dependent., &level., &maxbranch., &criterion.);

	  	data r1_;
		name = "&dependent.";
		level = "&level.";
		criterion = "&criterion.";
		maxbranch = &maxbranch.;
		IV = &IV.;
		Gini = &Gini.;
		run;

		proc append base = &ds_result. data = r1_ force;
		run;
     
 	  %end;

   		%let i = %eval(&i. + 1);
	%end;

/***********************/

	%if %upcase(&level.)=INT %then %do;

	  %do j = %eval(&maxbranch_min.) %to %eval(&maxbranch_max.);
	  %let maxbranch = &j.;

	  %WEIGHT_OF_EVIDENCE_BINNING(&source., &target., &event., &non_event., &dependent., &maxbranch.);

	  	data r1_;
		name = "&dependent.";
		level = "&level.";
		criterion = "quartiles";
		maxbranch = &maxbranch.;
		IV = &IV.;
		Gini = &Gini.;
		run;

		proc append base = &ds_result. data = r1_ force;
		run;
     
 	  %end;
	%end;

/***********************/

  %end;

proc sort data = &ds_result.;
by name descending Gini maxbranch descending criterion;
run;
proc sort nodupkey data = &ds_result.;
by name;
run;
proc sort data = &ds_result.;
by descending Gini;
run;

%MEND LOOP_VARIABLES;

%LOOP_VARIABLES(ranking_zmiennych);

proc report data=ranking_zmiennych; run;
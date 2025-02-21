options symbolgen;

data dane;
length id  8.;
length target  8.;
set sashelp.heart;
id = _N_;
if Status='Dead' then target = 1; else target = 0;
run;

%macro m_hpbin(dataset, id, input, numbin, target, output);
%global new_variable;

data _null_;
if 0 then set &dataset. nobs=n;
call symputx('max_hist', min(ceil(sqrt(n)), &numbin.));
stop;
run;

proc hpbin data=&dataset. output=&output. numbin=&max_hist. bucket;
id &id. &input. &target.;
input &input.;
ods output Mapping=map_;
run;

data _null_;
set map_;
call symputx('new_variable', binnedvariable);
run;

%mend m_hpbin;  

%m_hpbin(dane, id, AgeAtStart, 5, target, dane_kategorie);
%put **** &new_variable.;

%macro m_hptree(dataset, id, input, numbin, criterion, level, target, output);
%global new_variable;

data _null_;
if 0 then set &dataset. nobs=n;
call symputx('min_n_obs', floor(n * 0.05));
stop;
run;

proc hpsplit data = &dataset. maxdepth = 1 maxbranch = &numbin. leafsize = &min_n_obs. bonferroni;
id &id. &input.;
target &target.;
input &input. / level = &level.;
criterion &criterion.;
prune none;
score out = &output.(keep=&id. &input. &target. _node_);
run;

data &output.;
set &output.;
if missing(_Node_) then _Node_ = 0;
rename _Node_= BIN_&input.;
label _Node_ = BIN_&input.;
call symputx('new_variable', "BIN_&input.");
run;

%mend m_hptree;  

%m_hptree(dane, id, AgeAtStart, 5, gini, int, target, dane_kategorie);
%put **** &new_variable.;

%m_hptree(dane, id, Smoking_Status, 3, gini, nom, target, dane_kategorie);
%put **** &new_variable.;

/* Information Value (IV) & Weight of Evidence (WOE) & Chart */
%macro m_woe(dataset, input, target, event, non_event);
%global info_value;

proc sql noprint;
create table woe1_ as
select &input.,
case when &target. = &non_event. then 1 else 0 end as Non_event,
case when &target. = &event. then 1 else 0 end as Event
from &dataset.
;quit;

proc means data=woe1_ nway noprint;
class &input.;
var Non_event Event;
output out=woe2_(rename=(_freq_=Records) drop=_type_) sum()=;
run;

proc means data = woe2_ nway noprint;
var Records Non_event Event;
output out = tot_(drop=_type_ _freq_) sum()=;
run;

data _null_;
set tot_;
call symputx('sum_records', Records);
call symputx('sum_nonevent', Non_event);
call symputx('sum_event', Event);
run;

proc sql noprint;
create table woe3_ as
select 
&input., 
Records,
coalesce(Records/&sum_records., 0) as Records_Distribution format=nlpct12.2,
Non_event,
coalesce(Non_event/&sum_nonevent., 0) as Non_event_Distribution format=nlpct12.2,
Event,
coalesce(Event/&sum_event., 0) as Event_Distribution format=nlpct12.2,
coalesce(Event/Records, 0) as Event_Rate format=nlpct12.2
from woe2_
order by &input.
;quit;

data woe3_;
set woe3_;
WOE = log(Non_event_Distribution / Event_Distribution);
IV = (Non_event_Distribution - Event_Distribution) * WOE;
WOE = coalesce(WOE, 0);
IV = coalesce(IV, 0);
run;

proc means data = woe3_ nway noprint;
var IV;
output out = iv_(keep = iv) sum()=;
run;

data _null_;
set iv_;
call symputx('info_value', IV);
run;

/*Print - Weight of Evidence (WOE)*/

proc print data = woe3_ noobs;
title 'Weight of Evidence (WOE) & Information Value (IV)';
run;
title;

proc sgplot data=woe3_;
vbar &input. / response=Records datalabel nooutline fillattrs=(color="salmon");
vline &input. / response=Event_Rate datalabel y2axis lineattrs=(color="blue" thickness=3) nostatlabel; 
label Records = "# Records";
label Event_Rate="Event Rate";
label &input.="&input.";  
keylegend / location = outside
position = top
noborder
title = "Event_Rate & Records Distribution: &input.";
format Event_Rate percent7.3;
run;

proc sgplot data=woe3_;
vbar &input. / response=WOE datalabel nostatlabel;
vline &input. / response=Event_Rate datalabel y2axis lineattrs=(color="salmon" thickness=3) nostatlabel; 
label WOE="Weight of Evidence";
label Event_Rate="Event Rate";
label &input.="&input.";  
keylegend / location = outside
position = top
noborder
title = "Information Value: &info_value.";
format Event_Rate percent7.3;
run;

/*End Print - Weight of Evidence (WOE)*/

%mend m_woe;

%m_woe(dane_kategorie, &new_variable., target, 1, 0);
%put **** &info_value.;

%m_woe(dane, Smoking_Status, target, 1, 0);
%put **** &info_value.;

/* Information Value (IV) & Weight of Evidence (WOE) & Gini */
%macro m_woe_gini(dataset, input, target, event, non_event, output);
%global info_value;
%global gini;

proc sql noprint;
create table woe1_ as
select &input.,
case when &target. = &non_event. then 1 else 0 end as Non_event,
case when &target. = &event. then 1 else 0 end as Event
from &dataset.
;quit;

proc means data=woe1_ nway noprint;
class &input.;
var Non_event Event;
output out=woe2_(rename=(_freq_=Records) drop=_type_) sum()=;
run;

proc means data = woe2_ nway noprint;
var Records Non_event Event;
output out = tot_(drop=_type_ _freq_) sum()=;
run;

data _null_;
set tot_;
call symputx('sum_records', Records);
call symputx('sum_nonevent', Non_event);
call symputx('sum_event', Event);
run;

proc sql noprint;
create table woe3_ as
select 
&input., 
Records,
coalesce(Records/&sum_records., 0) as Records_Distribution format=nlpct12.2,
Non_event,
coalesce(Non_event/&sum_nonevent., 0) as Non_event_Distribution format=nlpct12.2,
Event,
coalesce(Event/&sum_event., 0) as Event_Distribution format=nlpct12.2,
coalesce(Event/Records, 0) as Event_Rate format=nlpct12.2
from woe2_
order by &input.
;quit;

data woe3_;
set woe3_;
WOE = log(Non_event_Distribution / Event_Distribution);
IV = (Non_event_Distribution - Event_Distribution) * WOE;
WOE = coalesce(WOE, 0);
IV = coalesce(IV, 0);
run;

proc means data = woe3_ nway noprint;
var IV;
output out = iv_(keep = iv) sum()=;
run;

data _null_;
set iv_;
call symputx('info_value', IV);
run;

data woe4_;
set woe3_;
rename WOE = WOE_&input.;
keep &input. WOE;
run;

data &output.;
set woe4_ (obs=1);
declare hash ht (dataset:'woe4_');
ht.definekey ("&input.");
ht.definedata(all: 'YES');
ht.definedone ();
do until (eof);
	set &dataset. end = eof;
	if ht.find() = 0 then output;
end;
stop;
run;

ods select none;
ods output WilcoxonScores=wx_;
proc npar1way wilcoxon data=&output.;
where not missing(&target.);
class &target.;
var WOE_&input.; 
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
	   call symputx('gini', Gini);
     output; 
   end;
run;

%mend m_woe_gini;

%m_woe_gini(dane_kategorie, &new_variable., target, 1, 0, dane_kategorie_woe);
%put **** &info_value.;
%put **** &gini.;

%m_woe_gini(dane, Smoking_Status, target, 1, 0, dane_kategorie_woe);
%put **** &info_value.;
%put **** &gini.;

proc freq data=dane_kategorie_woe noprint;
tables target * &new_variable. / measures;
output out=gini(keep=_smdcr_) smdcr;
run;

proc sql;
select &new_variable., WOE_&new_variable., count(1) as Count,
	min(AgeAtStart) as Minimum, max(AgeAtStart) as Maximum
from dane_kategorie_woe
group by 1, 2
;quit;
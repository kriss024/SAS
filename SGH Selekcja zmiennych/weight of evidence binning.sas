%let source = sashelp.heart;
%let target = Status;
%let event = "Dead";
%let non_event = "Alive";
%let dependent = AgeAtStart;
%let level = int;
%let maxbranch = 20;

/* Information Value (IV) & Weight of Evidence (WOE) */

proc rank data=&source.(keep=&target. &dependent.) groups=&maxbranch. ties=dense out=grouping_;
var &dependent.;
ranks GRP_&dependent.;
run;

data grouping_;
set grouping_;
if missing(GRP_&dependent.) then GRP_&dependent. = -1;
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

/*Print - Weight of Evidence (WOE)*/

proc print data = woe_ noobs;
title 'Weight of Evidence (WOE) & Information Value (IV)';
run;
title;

proc sgplot data=woe_;
vbar GRP_&dependent. / response=Records datalabel nooutline fillattrs=(color="salmon");
vline GRP_&dependent. / response=Event_Rate datalabel y2axis lineattrs=(color="blue" thickness=3) nostatlabel; 
label Records = "# Records";
label Event_Rate="Event Rate";
label GRP_&dependent.="GRP_&dependent.";  
keylegend / location = outside
position = top
noborder
title = "Event_Rate & Acct Distribution: GRP_&dependent.";
format Event_Rate percent7.3;
run;

proc sgplot data=woe_;
vbar GRP_&dependent. / response=WOE datalabel nostatlabel;
vline GRP_&dependent. / response=Event_Rate datalabel y2axis lineattrs=(color="salmon" thickness=3) nostatlabel; 
label WOE="Weight of Evidence";
label Event_Rate="Event Rate";
label GRP_&dependent.="GRP_&dependent.";  
keylegend / location = outside
position = top
noborder
title = "Information Value: &IV.";
format Event_Rate percent7.3;
run;

/*End Print - Weight of Evidence (WOE)*/

data woe2_;
set woe_;
WOE_&dependent. = WOE;
keep GRP_&dependent. WOE_&dependent.;
run;

data grouping2_;
set woe2_ (obs=1);
declare hash ht (dataset:'woe2_');
ht.definekey ("GRP_&dependent.");
ht.definedata(all: 'YES');
ht.definedone ();
do until (eof);
	set grouping_ end = eof;
	if ht.find() = 0 then output;
end;
stop;
run;

ods select none;
ods output WilcoxonScores=wx_;
proc npar1way wilcoxon data=grouping2_;
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

proc freq data=grouping2_ noprint;
tables &target.*GRP_&dependent. / measures;
output out=gini(keep=_SMDCR_ ) smdcr;
run;

/* END - Information Value (IV) & Weight of Evidence (WOE) */

proc sql;
select GRP_&dependent., WOE_&dependent., count(1) as Count,
	min(&dependent.) as Minimum, max(&dependent.) as Maximum
from a4_
group by 1, 2
;quit;

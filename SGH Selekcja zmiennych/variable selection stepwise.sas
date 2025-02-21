%let source = sashelp.heart;
%let target = Status;
%let event = "Dead";
%let max_iter = 200;
%let ds_result = wyniki;

data a1_;
set &source.;
keep Status AgeAtStart--Smoking Cholesterol Sex Chol_Status--Smoking_Status;
run;

proc contents data=a1_ out=meta(keep=name type) noprint; 
run; 

proc sql noprint; 
select name
into :all_variables separated by ' '
from meta
where name ^= "&target.";
quit;

proc sql noprint; 
select name
into :class_variables separated by ' '
from meta
where name ^= "&target." and type = 2;
quit;

%put *** &all_variables.;
%put *** &class_variables.;

proc sort data = a1_;
by &target.;
run;

%macro STEPWISE_SELECTION;
 
data ParamAll_;
length name $32;
stop;
run;

%do iter = 1 %to %eval(&max_iter.);

proc surveyselect data=a1_ method=srs rate=0.5 seed=%eval(1000+&iter.) out=a2_ noprint;
strata &target.;
run;

proc logistic data = a2_;
class &class_variables. (param=ref);
model &target. (event = &event.)= &all_variables. / link=logit selection=stepwise;
ods output ParameterEstimates = ParamEstStep(keep=variable);
run;

proc logistic data = a2_;
class &class_variables. (param=ref);
model &target. (event = &event.)= &all_variables. / link=logit selection=forward;
ods output ParameterEstimates = ParamEstFor(keep=variable);
run;

proc logistic data = a2_;
class &class_variables. (param=ref);
model &target. (event = &event.)= &all_variables. / link=logit selection=backward;
ods output ParameterEstimates = ParamEstBack(keep=variable);
run;

proc sql;
create table Parameter_ as
select variable as name from (
select distinct variable from ParamEstStep where variable ^ = 'Intercept'
intersect
select distinct variable from ParamEstFor where variable ^ = 'Intercept'
intersect
select distinct variable from ParamEstBack where variable ^ = 'Intercept')
;quit;

proc append base=ParamAll_ data=Parameter_ force; run; 
                                                                                                                     
%end;                                                                                                                              
%mend STEPWISE_SELECTION; 

%STEPWISE_SELECTION;

proc sql;
create table &ds_result. as
select name, count(*) as Count 
from ParamAll_
group by name
order by 2 desc
;quit;

proc report data=&ds_result.; run;

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

proc corr data=&source. pearson spearman;
var AgeAtStart Systolic;
run;

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

ods graphics on;
proc logistic data = &source.; 
model Status (event = "Dead") = AgeAtStart Systolic / outroc=rocdata;
effectplot;
ods output ParameterEstimates = param_model;
run;
ods graphics off;

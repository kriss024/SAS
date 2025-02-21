data a1;
set &EM_IMPORT_DATA;
keep %EM_INTERVAL_INPUT %EM_TARGET;
run;

data a2;
set &EM_IMPORT_DATA;
keep %EM_INTERVAL_INPUT;
run;

data z1;
set a2;
stop;
run;

proc transpose data=z1 out=variables;
var _all_;
run;

/***********************************************/

%MACRO DATA_QUALITY(ds_in, var);
%global n missing pct_missing cv;

proc univariate noprint data=&ds_in. alpha=0.05;
var &var.;
output out=InfoQuality n=n nmiss=missing mean=mean std=std cv=cv;
run;

data _null_;
set InfoQuality;
call symputx('n',(n+missing));
call symputx('missing',missing);
call symputx('pct_missing',missing/(n+missing));
call symputx('cv',cv/100);
run;

%MEND DATA_QUALITY;

%MACRO VARIABLE_QUALITY_STATS( dsn, P_TARGET, P_VAR);
%global auc gini ks divergence iv;

ods select none;
ods output wilcoxonscores = _wx;
ods output kolsmir2stats = _ks;
proc npar1way wilcoxon edf data = &dsn.;
  class &P_TARGET.;
  var &P_VAR.;
run;
ods select all;

*** CALCULATE ROC AND GINI ***;

proc sort data = _wx;
by class;
run;

data _null_;
  set _wx end = eof;
  by class;
 
  array a{2, 3} _temporary_;
  if _n_ = 1 then do;
    a[1, 1] = n;
    a[1, 2] = sumofscores;
    a[1, 3] = expectedsum;
  end;
  else do;
    a[2, 1] = n;
  end;
  if eof then do;
    auc  = (a[1, 2] - a[1, 3]) / (a[1, 1] * a[2, 1])  + 0.5;
    if auc <= 0.5 then auc = 1 - auc;
    gini = 2 * (auc - 0.5);
	call symputx('auc', auc);
	call symputx('gini', gini);
  end;
run;

*** CALCULATE KS ***;

data _null_;
  set _ks;
  if _n_ = 1 then do;
    ks = nvalue2;
    call symputx('ks', ks);
  end;
run;

proc summary data = &dsn. nway noprint;
  class &P_TARGET.;
  output out = _diver (drop = _type_ _freq_)
  mean(&P_VAR.) = mean var(&P_VAR.) = variance;
run;
 
*** CALCULATE DIVERGENCE ***;

data _null_;
  set _diver end = eof;
  array a{2, 2} _temporary_;
  if _n_ = 1 then do;
    a[1, 1] = mean;
    a[1, 2] = variance;
  end;
  else do;
    a[2, 1] = mean;
    a[2, 2] = variance;
  end;
  if eof then do;
    divergence = (a[1, 1] - a[2, 1]) ** 2 / ((a[1, 2] + a[2, 2]) / 2);
	call symputx('divergence', divergence);
  end; 
run;

*** INFORMATION VALUE ***;

%let nbin = 6;

proc hpbin data=&dsn. numbin=&nbin. bucket;
input &P_VAR.;
ods output Mapping=Mapping;
run;

proc hpbin data=&dsn. WOE BINS_META=Mapping;
target &P_TARGET./level=nominal order=desc;
ods output InfoValue=InfoValue;
run;

data _null_;
  set InfoValue;
  if _n_ = 1 then do;
    call symputx('iv', IV);
  end;
run;

%MEND VARIABLE_QUALITY_STATS;

/***********************************************/

%macro DATA_SCORE(dsn, vars, P_TARGET, dsn_out);
%let data_set = &vars.;
%let dsid = %sysfunc (open(&data_set));
%let nrows = %sysfunc(attrn(&dsid,nlobs));
%let rc = %sysfunc(close(&dsid));
%put ****&nrows.;

%if %sysfunc(exist(&dsn_out.)) %then %do;
proc delete data = &dsn_out.;
run;
%end;

%do i=1 %to &nrows;

data x1_;
obs=%eval(&i.);
set &vars. point=obs;
output;
stop;
run;

data _null_;
set x1_;
call symputx('name', _name_);
run;

data d1_;
set &dsn.;
keep &name. &P_TARGET.;
run;

%DATA_QUALITY(d1_, &name.)

data s1_;
N = &n.;
Missing = &missing.;
Pct_missing = &Pct_missing.;
CV = &cv.;
run;

data d2_;
set d1_;
if missing(&name.) then &name. = 0;
run;

%VARIABLE_QUALITY_STATS(d2_, &P_TARGET., &name.);

data s2_;
AUC = &auc.;
Gini = &gini.;
KS = &ks.;
Divergence = &divergence.;
IV = &iv.;
run;

data x2_;
merge x1_ s1_ s2_;
array nvar(*) _numeric_;
do temp_= 1 to dim(nvar);  
   if nvar(temp_) = . then nvar(temp_) = 0;
end;
drop temp_;
format pct_missing percent8.2; 
format cv percent8.2; 
run;

%if %sysfunc(exist(&dsn_out.)) %then %do;
proc append base=&dsn_out. data=x2_ force;
run;
%end; %else %do;
data &dsn_out.;
set x2_;
run;
%end;

%end;

proc sort data=&dsn_out.;
by descending IV;
run;

%mend DATA_SCORE;

/***********************************************/

%DATA_SCORE(a1, variables, %EM_TARGET, ScoreVars)

data ScoreVars;
set ScoreVars;
if Pct_missing > 0.2 then delete;
if IV < 0.2 then delete;
run;

/***********************************************/

data c1;
set a2;
array nvar(*) _numeric_;
do temp_= 1 to dim(nvar);  
   if nvar(temp_) = . then nvar(temp_) = 0;
end;
drop temp_;
run;

ods output clusterquality=summary
           rsquare=clusters;
proc varclus data=c1 hierarchy;
   var _all_;
run;
ods select all;

data _null_;
set summary;
call symput('nvar_c',compress(NumberOfClusters));
run;

data Selvars(rename=(c=Cluster));
retain c;
set clusters (where = (NumberOfClusters=&nvar_c.));
if length(Cluster) > 1 then c = Cluster;
rename Variable=_NAME_;
keep c Variable;
run;

proc sort data = ScoreVars;
by _NAME_;
run;

proc sort data = Selvars;
by _NAME_;
run;

data ScoreVars2;
merge ScoreVars (in=a)
Selvars (in=b);
by _NAME_;
if a nad b;
run;

proc rank data=ScoreVars2  groups = 10 out = ScoreVars3;
var Gini KS Divergence IV;
ranks Gini_ranks KS_ranks Divergence_ranks IV_ranks;
run;

data ScoreVars4;
set ScoreVars3;
StatRank_ = mean(Gini_ranks, KS_ranks, Divergence_ranks, IV_ranks);
run; 

proc sort data=ScoreVars4 out=ScoreFinal;
by descending StatRank_ descending IV;
run;

proc sort nodupkey data = ScoreFinal;
by Cluster;
run;

proc sort data=ScoreFinal;
by descending StatRank_ descending IV;
run;

data ScoreFinal;
set ScoreFinal;
drop Gini_ranks KS_ranks Divergence_ranks IV_ranks StatRank_;
run;

proc print data=ScoreFinal;
title1 'ZMIENNE DO MODELOWANIA';
run;

proc sql noprint; 
select _NAME_
into :LISTA_INPUT separated by ' '
from ScoreFinal;
quit;

data &EM_EXPORT_TRAIN;
set &EM_IMPORT_DATA;
keep %LISTA_INPUT %EM_TARGET;
run;
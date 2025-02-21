data dane;
set sashelp.Cars;
where Type in ('Sports','SUV');
keep Type _numeric_;
run; 

data _null_;
if 0 then set dane nobs=n;
call symputx('nrows',n);
stop;
run;
%put nobs=&nrows.;

%let sqrtn = %sysfunc(sqrt(&nrows.));
%let hist = %sysfunc(ceil(&sqrtn.));
%put hist = &hist.;

/* Bucket Binning and Weight-of-Evidence Computation */
ods output Mapping=mapTable;
ods listing;
proc hpbin data=dane output=out numbin=&hist. bucket;
input _numeric_;
run;
ods listing close;

proc hpbin data=dane numbin=&hist. bucket;
input _numeric_;
ods output Mapping=Mapping;
run;

proc hpbin data=dane WOE BINS_META=Mapping;
target Type/level=nominal order=desc;
ods output InfoValue=InfoValue;
run;

proc hpsplit data=dane maxdepth=5 maxbranch=2;
target Type;
input _numeric_ / level=int;
output importance=import;
criterion gini;
run;

proc print data=import(where=(itype='Import'));
run;

data ex12;
length id 8;
do id=1 to 1000000;
x1 = ranuni(101);
x2 = 10*ranuni(201);
output;
end;
run;
    
ods output BinInfo=bininfo;
ods output Mapping=mapTable;
ods listing close;
proc hpbin data=ex12 output=out numbin=10 quantile;
id id;
input x1-x2;
run;
ods listing;

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

%MACRO VARIABLE_QUALITY( dsn, P_TARGET, P_VAR);
%global auc gini ks divergence;

ods select none;
ods output wilcoxonscores = _wx;
ods output kolsmir2stats = _ks;
proc npar1way wilcoxon edf data = &dsn.;
  class &P_TARGET.;
  var &P_VAR.;
run;
ods select all;

proc sort data = _wx;
by class;
run;

*** CALCULATE ROC AND GINI ***;
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

%MEND VARIABLE_QUALITY;

%VARIABLE_QUALITY(dane, Type, Weight);

%put auc = &auc.;
%put gini = &gini.;
%put ks = &ks.;
%put divergence = &divergence.;

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

proc univariate data=dane noprint;
class Type;
var Weight;
histogram /normal (color=blue w=1);
run;

proc corr data=dane;
var  _numeric_;
with Weight;
run;

ods graphics on;
proc logistic data=dane; 
model Type (event='SUV') = Weight MSRP / outroc=rocdata;
effectplot;
ods output ParameterEstimates = param_model;
run;
ods graphics off;

goptions reset=all border;
symbol1 v=dot i=join;
proc gplot data=ROCData;
 plot _sensit_*_1mspec_;
run;quit; 

data param_model;
set param_model;
exp_est = exp(estimate);
run;
proc print data = param_model;
var variable estimate exp_est;
run;
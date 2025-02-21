libname tmp "C:\Users\Krzysztof\Desktop\SGH Variable Selection Gini";

data Churn;
set tmp.churn;
run;

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

%VARIABLE_QUALITY(Churn, Churn, total_day_minutes);

%put auc = &auc.;
%put gini = &gini.;
%put ks = &ks.;
%put divergence = &divergence.;
options symbolgen;

data dane;
set sashelp.cars;
keep Type Origin;
run;

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

proc freq data=dane;
tables Type*Origin/nocol norow nopercent chisq;
run;

%MACRO V_CRAMER( dsn, P_TARGET, P_VAR);
%global pchi vcram logworth;
proc freq data = &dsn. noprint;
 tables &P_TARGET.*&P_VAR. /nocol norow nopercent chisq;
 output out=_vcram(keep=_pchi_ _cramv_ p_pchi) chisq cramv;
run;

data _null_;
  set _vcram;
  call symputx('pchi', _pchi_);
  call symputx('vcram', _cramv_);
  call symputx('logworth', -log10(p_pchi));
run;
%MEND V_CRAMER;

%V_CRAMER(dane, Origin, Type);

%put pchi = &pchi.;
%put vcram = &vcram.;
%put logworth = &logworth.;

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

%MACRO ENTROPY(dsn, P_TARGET, P_VAR);
%global entropy;
%global gini;
proc freq data = &dsn. noprint;
 tables &P_TARGET.*&P_VAR. /nocol norow nopercent measures;
 output out=_entropy(keep=_ucr_ _smdcr_) ucr smdcr;
run;

data _null_;
  set _entropy;
  call symputx('entropy', _ucr_);
  call symputx('gini', _smdcr_);
run;
%MEND ENTROPY;

%ENTROPY(dane, Origin, Type);

%put entropy = &entropy.;
%put gini = &gini.;

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

ods listing close;
ods select none;
proc freq data=dane;
tables Type*Origin / chisq;
ods output ChiSq=ChiSq;
run;
ods output close;
ods listing;

proc sql;
create table stat
as select *
from ChiSq
where statistic in ('Chi-kwadrat', 'V Cramera');
quit;
%let offset = 0;

data A(keep=u t);
	call streaminit(1234);       /* set random number seed */
	do i = 1 to 1000;
		if i >500 then
			u = rand("Normal")+ &offset.;
		else  u = rand("Normal");

		if i >500 then
			t = 0;
		else  t = 1;
		output;
	end;
run;

proc sort data = A;
by u;
run;


%macro Histogram(class, var_int, ds);
	%if &class. eq '' %then
		%do;
			proc univariate data=&ds. noprint;
				histogram &var_int. / vscale=count normal(color = blue noprint);
				inset min max mean std / format=6.3;
			run;
		%end;
	%else
		%do;
			proc univariate data=&ds. noprint;
				class &class.;
				histogram &var_int. / vscale=count normal(color = blue noprint);
				inset min max mean std / format=6.3;
			run;
		%end;
%mend Histogram;

%Histogram( , u, A);
%Histogram(t, u, A);

proc sgplot data = A;
histogram u / group= t transparency = 0.5 scale=count;
density u / type=kernel group = t;
run;

ods graphics on;
proc ttest data = A;
class t;
var u;
run;
ods graphics off;

ods graphics on;
proc anova data = A;
class t;
model u = t;
means t /hovtest welch;
run;
ods graphics off;

/* Divergence */

proc means data=A nway noprint;
class t;
var u;
output out=div mean=mean var=variance;
run;

data _null_;
set div end = eof;
array a{2, 2} _temporary_;
if _N_ = 1 then do;
	a[1, 1] = mean;
	a[1, 2] = variance;
end;
if _N_ = 2 then do;
    a[2, 1] = mean;
    a[2, 2] = variance;
end;
if eof then do;
    divergence = ((a[1, 1] - a[2, 1]) ** 2) / (0.5 * (a[1, 2] + a[2, 2]));
	call symputx('divergence', divergence);
end; 
run;

%put Divergence = &divergence.;
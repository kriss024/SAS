/* Count number of variables assigned in a macro variable */

%macro nvars (ivars);
%let n=%sysfunc(countw(&ivars));
%put number of variables &n;
%mend;
%nvars (X1 X2 X3 X4);

%macro nvars (ivars);
%let n=1; 
%do %until ( %scan(&ivars,&n)= );
	%let n=%EVAL(&n + 1);
	%put &n;
%end;
%let n=%eval(&n-1);
%put number of variables &n;
%mend;

%nvars ( X1 X2 X3 X4);

/* Get all the variable names from a data set */

proc sql noprint;
select name into : vars separated by " "
from dictionary.columns
where LIBNAME = upcase("sashelp")
and MEMNAME = upcase("cars")
and type = 'num';
quit;

%put numeric variables = &vars.;

/*Reordering variables*/

proc sql noprint;
select name into : reorder separated by " "
from dictionary.columns
where LIBNAME = upcase("sashelp")
and MEMNAME = upcase("cars")
order by name;
quit;

%put &reorder.;

/*Call a Macro*/

%macro mymacro(k);
data want;
%do i = 1 %to &k;
y = %eval(&i.* 10);
%end;
run;
%mend;

data _null_;
call execute ('%mymacro(60)');
run;

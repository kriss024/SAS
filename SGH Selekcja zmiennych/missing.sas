proc format;
value $missfmt ' '='Missing' other='Not Missing';
value  missfmt  . ='Missing' other='Not Missing';
run;

ods listing close;
ods output OneWayFreqs=OneWay; 
proc freq data=sashelp.heart; 
format _char_ $missfmt.;
tables _char_ / missing missprint nocum nopercent;
format _numeric_ missfmt.;
tables _numeric_ / missing missprint nocum nopercent;
run;
ods listing;

data OneWay2;
set OneWay;
Column = scan(Table, 2);
Missing = cats(of F_:);
keep Frequency Column Missing;
run;
data dane;
pi=constant("pi");
do i = 1 to 100;
   y = 2*pi*i/100;
   b = i/100;
   sin = sin(y)+b;
   cos = cos(y)+b;
   output;
end;
run;

goptions reset=all;
proc gplot data=dane;                                                                                                                 
   plot (sin cos)*y / overlay;                                                                             
run; 

proc corr data=dane pearson spearman;
var sin;
with cos;
run;
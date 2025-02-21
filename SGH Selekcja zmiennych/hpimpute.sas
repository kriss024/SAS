data ex1;
input a  b  c  d  freq id;
datalines;
       2    3   1  1   2   1
       2    2   2  2   3   2
       .    0   3  .   0   3
       2    3   .  .   .   4
       2    .   .  .   -5  5
       .    6   .  .   3   6
       .    4   .  .   4   7
       2    5   .  .   3   8
       .    6   9  9   1   9
       2    3   10 10  3   10
run;

proc hpimpute data=ex1 out=out1(keep=id IM:);
id id;
input a b c d;
impute a / value=0;
impute b / method=pmedian;
impute c / method=random;
impute d / method=mean;
run;
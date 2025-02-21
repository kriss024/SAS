options msglevel=i;

proc sort data=pd3.threads out=sorted threads;
	by Id1;
run;

proc sort data=pd3.threads out=sorted threads noequals;
	by Id1;
run;
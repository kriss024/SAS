LIBNAME TEMP BASE "C:\Temp";

data WIDOK / view=WIDOK;
	set TEMP.HP_1;
run;

%MACRO MakorHP;
%do i=1 %to 10;
	data HPDane_&i;
	set WIDOK;
	where Nr_warstwy=&i;
	run;
%end;
%MEND lata;
%MakorHP;
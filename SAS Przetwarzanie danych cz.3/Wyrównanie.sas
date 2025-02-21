data konwersja;
	z1=123;
	z2='A'||z1||'B';
	z3='A'||PUT(z1,4.)||'B';
	put z2=;
	put z3=;
run;

data wynik1;
	z1=123;
	z3='A'||PUT(z1,6.)||'B';
	put z3=;
run;

data wynik2;
	z1=123;
	z3='A'||PUT(z1,6. -L)||'B';
	put z3=;
run;

data wynik3;
	z1=123;
	z3='A'||PUT(z1,6. -C)||'B';
	put z3=;
run;
data _null_;
	a='Ala ma kota';
	b=substr(a,1,2);
	c=scan(a,2);
	d=a||repeat('123',3);
	e=reverse(a);
	f=translate(a,'!?','I');
	g=missing(a);
	Put a= b= c= d= e= f= g=;
run;

data _NULL_;
	z1='W Ko³obrzegu jest brzeg morski';
	wyraz1=count(z1,'Brzeg');
	wyraz2=count(z1,'Brzeg','I');
	put wyraz1=  wyraz2=;
run;

data _NULL_;
	z1='W Ko³obrzegu jest brzeg morski';
	wyraz1=countc(z1,'B','I');
	wyraz2=countc(z1,'B','IV');
	wyraz3=countc(z1,'Brzeg','I');
	wyraz4=countc(z1,'Brzeg','IV');
	put wyraz1=  wyraz2=;
	put wyraz3=  wyraz4=;
run;

data _NULL_;
	data_ur='470823';
	pesel='47082306752';

	if count(pesel,data_ur)>0 then
		put 'Poprawny PESEL';
	else put 'B³êdny PESEL';
run;

data _NULL_;
	z1='AABBAABBAA';
	wyraz=count(z1,'AABBAA');
	put wyraz=;
run;

data _null_;
	z1='234723429442';
	wynik=indexc(z1,'4');
	put wynik=;
run;

data _null_;
	z1='234723429442';
	wynik=verify(z1,'423');
	put wynik=;
run;

data _null_;
	z1='Ala ma kota i s³onia';
	wynik=findc(z1,'a','vi');
	put wynik=;
run;

data _null_;
	z1='234723429442';
	wynik=findc(z1,'234','v');
	put wynik=;
run;
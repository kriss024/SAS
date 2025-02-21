*************;
* FUNKCJE CATS, CATX, CATT;
data osoby_CATS;
	Imie='  Joanna ';
	Drugie_imie='Weronika ';
	Nazwisko=' Nawalany';
	osoba1=CAT(imie,drugie_imie,nazwisko);
	osoba2=CATS(imie,drugie_imie,nazwisko);
	osoba3=trim(left(imie))||trim(left(drugie_imie))||
		trim(left(nazwisko));
run;

data osoby_CATX;
	Imie='  Joanna ';
	Drugie_imie='Weronika ';
	Nazwisko=' Nawalany';
	osoba1=CAT(imie,drugie_imie,nazwisko);
	osoba2=CATX(',',imie,drugie_imie,nazwisko);
	osoba3=trim(left(imie))||','||trim(left(drugie_imie))||','||
		trim(left(nazwisko));
run;

data osoby_CATT;
	Imie='  Joanna ';
	Drugie_imie='Weonika ';
	Nazwisko=' Nawalany';
	osoba1=CAT(imie,drugie_imie,nazwisko);
	osoba2=CATT(imie,drugie_imie,nazwisko);
	osoba3=trim(imie)||trim(drugie_imie)||trim(nazwisko);
run;

data cat;
	set pd3.lista;
	wynik1=cat(of imie1-imie2);
	wynik2=catx(' ',prefiks,of imie1-imie2);
	wynik3=catx(',',prefiks,of imie--nazwisko);
run;
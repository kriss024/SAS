libname moja "c:\temp";

data test11;
	do i = 1 to 10;
		x = 1;
		output;
	end;
run;

/* ÆWICZENIE. Wygenerowaæ tabelê kwadratów liczb od 1 do 100 */

data test11a;
	do x = 1 to 100;
		x2 = x * x;
		output;
	end;	
run;
/* ÆWiCZENIE: Wyznaczyæ 100 pierwszych liczb Fibonacciego.

	F(0) = F(1) = 1
	F(n) = F(n-1) + F(n-2)

*/

data test11B;
	retain f1 1;
	retain f2 1;

	do i = 0 to 100;
		if i = 0 or i = 1 then F = 1;
		else do;
			F = f1 + f2;
			f2 = f1;
			f1 = F;
		end;
		output;
	end;
	keep F;
run;

data test11B2;
	set test11B;

	if F = . then F = lag(F) + lag2(F);

	drop f1 f2;
run;


/* Tabela funkcji sinus */
data test12;
	do x = -3.14 to 3.14 by 0.01;
		sin = sin(x);
		output;
	end;
run;

/* Æwiczenie. Wygenerowaæ 1000 liczb z rozk³adu normalnego o œredniej 70.
	Wskazówka: OdnaleŸæ odpowiedni¹ funkcjê z grupy RANxxx */

data test13;
	do i = 1 to 1000;
		x = 70 + rannor(0);
		output;
	end;
	drop i;
run;

/* Æwiczenie. Uzupe³niæ brakuj¹ce daty w zbiorze KUPNO tzn.:

- utworzyæ nowy zbiór KUPNO_U na podstawie zbioru KUPNO
- sprawdzaæ odstêp dat - je¿eli wiêkszy ni¿ 1, to wygenerowaæ nowe wiersze
  w liczbie równej brakuj¹cym dniom
- kurs CHF w tak generowanych wierszach to kurs z poprzedniej obserwacji w zbiorze KUPNO

*/

data Moja.Kupno_U;
    set Moja.Kupno;
    Data_akt = Data;
    Data_pop = Lag(Data);
    CHF_lag = Lag(CHF);

    Diff = Data_akt - Data_pop;
    if Diff>1 then
    do;
        do i = 1 to Diff;
           Data_pop = Data_pop+1;
        Data_nowa = Data_pop;
        CHF_nowy = CHF_lag;

        output;
    end;
    end; else do;
        Data_nowa = Data_akt;
        CHF_nowy = CHF;
        output;
    end;
    format Data_nowa DATE9.;
    drop Data_akt Data_pop Diff i;
run;


data test14;
	set moja.kupno;

	data2 = data;
	data3 = data;
	data4 = data;
	data5 = data;

	format data2 yymmdd10.;
	format data3 yymmdd8.;
	format data4 yymmdd6.;
	format data5 yymmdd4.;

	keep data data2 data3 data4 data5;
run;



/* £¹czenie zbiorów */

data moja.razem1;
	set moja.z1;
	set moja.z2;
run;

data moja.razem2;
	set moja.z1 moja.z2;
run;

data moja.razem3;
	set moja.z1 moja.z2;
	by a;
run;

data moja.razem4;
	merge moja.z1 moja.z2;
	by a;
run;
/* Æwiczenie. Wybranym sposobem po³¹cz zbiory kupno i sprzedaz.
   Utwórz nowy zbiór o nazwie S1 zawieraj¹cy dwie zmienne:
   data i spread, gdzie spread jest róznic¹ kursów sprzeda¿y i kupna
	CHF */


data moja.s1;
	merge moja.sprzedaz moja.kupno;
	by data;

	spread = 100*(chf - chf_k)/chf_k;
	keep data spread;
run;

data X;
	x = 1;
	y = 9;
	output;
	x = 2;
	y = 8;
	output;
	x = 3;
	y = 7;
	output;
run;

DATA test2;
	SET X;
	WHERE x >= 2;
	z = x * lag(y);
RUN;

data moja.staff;
   infile datalines dlm='#';
   input Name & $16. IdNumber $ Salary
         Site $ HireDate date7.;
   format hiredate date7.;
   datalines;
Capalleti, Jimmy#  2355# 21163# BR1# 30JAN09
Chen, Len#         5889# 20976# BR1# 18JUN06
Davis, Brad#       3878# 19571# BR2# 20MAR84
Leung, Brenda#     4409# 34321# BR2# 18SEP94
Martinez, Maria#   3985# 49056# US2# 10JAN93
Orfali, Philip#    0740# 50092# US2# 16FEB03
Patel, Mary#       2398# 35182# BR3# 02FEB90
Smith, Robert#     5162# 40100# BR5# 15APR66
Sorrell, Joseph#   4421# 38760# US1# 19JUN11
Zook, Carla#       7385# 22988# BR3# 18DEC10
;
run;



proc format library=moja;
	picture uscurrency low-high='000,000' (mult=1.61 prefix='$'); /* mno¿enie przez 1.61 */
run;

data moja.staff2;
	set moja.staff;
	format salary uscurrency.;
run;


/* Przyk³ad - Creating a format from a data set */

data scale;
   input begin $ 1-2 end $ 5-8 amount $ 10-12;
   datalines;
0   3    0%
4   6    3%
7   8    6%
9   10   8%
11  16   10%
;
run;

data ctrl;
   length label $ 11;

   set scale(rename=(begin=start amount=label)) end=last;

   retain fmtname 'PercentageFormat' type 'n'; /* musi byæ start label last fmtname */

   output;

   if last then do;
      hlo='O';
      label='***ERROR***';
      output;
   end;
run;

proc format library=work cntlin=ctrl;
run;

data points;
   input EmployeeId $ total;
   datalines;
2355 8
5889 2
3878 5
4409 17
3985 1
;
run;

data points2;
	set points;
	format total PercentageFormat.;
run;












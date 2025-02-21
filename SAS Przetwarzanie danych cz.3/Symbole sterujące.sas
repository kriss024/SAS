/*Nie ka¿dy wiersz ma ten sam format danych*/
/*U¿yjê @ aby wstrzymaæ wczytywanie danych i ustaliæ format*/
data sprzedaz;
	infile datalines;
	input id $ lokalizacja $ @;
	if lokalizacja="USA" then
		input data :mmddyy10. sprzedaz;
	else if lokalizacja="EUR" then
		input data :date9. sprzedaz :commax8.;

	format data ddmmyy10.;
	datalines;
101 USA 01-20-2014 3295.50
3034 EUR 30JAN2014 1876,30
101 USA 01-30-2014 2938.00
128 USA 02-5-2014 2908.74
1345 EUR 6FEB2014 3145,60
109 USA 03-17-2014 2789.10
;

/*Dane w wielu wierszach*/
data linie;
	infile datalines;
	input a b c @@;
	datalines;
1 2
3
4 
5
6
;

/*Przesuniêcie wskaŸnika na konkretn¹ pozycjê*/
data pozycja;
	infile datalines;
	input a $ @1 b $ c $;
	datalines;
Ala ma kota
;

/*Gdy separator jest czêœci¹ danych*/
data separatory;
	infile datalines dsd;
	input a $ b $ c $ &;
	datalines;
a,b,,c
;



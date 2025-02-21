/*Konwersja*/
proc format;
	value typefmt  1='$groupx'
		2='$groupy';
	value $groupx 'positive'='agree'
		'negative'='disagree'
		'neutral'='notsure ';
	value $groupy 'positive'='accept'
		'negative'='reject'
		'neutral'='possible';
run;

data answers;
	length wynik $ 8;
	input type response $;
	respfmt = put(type, typefmt.);
	wynik = putc(response, respfmt);
	datalines;
  1 positive
  1 negative
  1 neutral
  2 positive
  2 negative
  2 neutral
 ;
run;

proc format;
	value writfmt 
		1='date9.' 
		2='mmddyy10.';
run;

data dates;
	input number key;
	datefmt=put(key,writfmt.);
	wynik=putn(number,datefmt);
	datalines;
  15756 1 
  14552 2 
  ;
run;
FILENAME dane "&path";

****************;
* Plik z danymi oddzielonymi tabulacjami ;
DATA osoby;
  INFILE dane(osoby.txt) MISSOVER FIRSTOBS=2 OBS=4 dlm='09'x ;
  INPUT id wzrost waga plec $ wiek imie $;
RUN;


***************;
* Dane rozdzielone separatorami ;
DATA osoby;
  INFILE dane(osoby2.txt) MISSOVER DLM=';';
  INPUT id wzrost waga plec $ wiek imie $;
RUN;


***************;
* Plik tekstowy z ustalon¹ szerokoœci¹ kolumn ;
DATA osoby;
  INFILE dane(osoby3.txt) MISSOVER;
  INPUT id 1 wzrost 2-4 waga 5-6 plec $ 7 wiek 8-9 imie $ 10-16;
RUN;


DATA osoby;
  INFILE dane(osoby4.txt) MISSOVER;
  INPUT id $3. imie $7. pensja comma9.2 +2 data yymmdd8.;
RUN;


DATA osoby;
  INFILE dane(osoby4.txt) MISSOVER;
  INPUT id imie $ 4-10 pensja comma9.2 +2 data yymmdd8.;
RUN;

*************;
* polecenie CARDS / DATALINES;
DATA osoby;
  INFILE CARDS;
  INPUT id imie $ pensja :comma9.2 +2 data yymmdd8.;
CARDS;
1  Jan    10,234.20 97/01/03
2  Tomasz 9,111.00  97/02/01
3  Kamil  12,543.33 97/01/02
4  Anna   23,000.00 97/02/01
5  Hanna  987.50    97/01/30
6  Zofia  11,211.00 97/02/01
;
RUN;


DATA osoby;
  INFILE CARDS DLM=';';
  INPUT id imie $ pensja :comma9.2 data yymmdd8.;
CARDS4;
1;Jan;10,234.20;97/01/03
2;Tomasz;9,111.00;97/02/01
3;Kamil;12,543.33;97/01/02
4;Anna;23,000.00;97/02/01
5;Hanna;987.50;97/01/30
6;Zofia;11,211.00;97/02/01
;;;;
RUN;


DATA osoby;
  INFILE CARDS DLM=';';
  INPUT id imie $ pensja :comma9.2 data yymmdd8.;
CARDS4;
1;Jan;10,234.20;97/01/03
2;Tomasz;9,111.00;97/02/01
3;Kamil;12,543.33;97/01/02
4;Anna;23,000.00;97/02/01
5;Hanna;987.50;97/01/30
6;Zofia;11,211.00;97/02/01
;;;;
RUN;



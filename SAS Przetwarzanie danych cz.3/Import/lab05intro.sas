/* ****************************************************************************** */
/* SAS0708 - LAB   05  ********************************************************** */
/* ****************************************************************************** */
/* CZYTANIE I PISANIE DO PLIKOW TEKSTOWYCH   ************************************ */
/* ****************************************************************************** */

/* Podstawowe uzycie (zakladamy, ze w odpowiednim katalogu jest plik: plik.txt): */
data a;
 infile 'c:\katalog\plik.txt'; *INFILE to statement;
 input kto $ plec $ ile; *INPUT w tym kontekscie to statement, a nie funkcja;
run;
*Uwaga ogolna: zasadniczo INPUT dziala podobnie do instrukcji SET - kazde wykonanie 
 instrukcji INPUT czyta, o ile to mozliwe, pierwsza nieczytana linijke z pliku 
 wejsciowego. Innymi slowy, kolejne INPUTy domyslnie przechodza do nowych linijek.
 Kazdy INPUT domyslnie czyta cala linijke, az do znalezienia znaku konca linii EOL;

/* Czasem wygodnie jest zadeklarowac tzw. file references */
filename plik 'c:\katalog\plik.txt'; *FILENAME jest to statement;
data a; 
 infile plik;
 input kto $ plec $ ile;
run;

/* Wczesniej wielokrotnie cwiczyliscmy czytanie pliku tekstowego, z tym, ze w szczegolnej
sytuacji. Czytany byl plik "wewnetrzny", zadawany w kodzie programu */
data a;
 input kto $ plec $ ile;
 cards;
Ala F 300
Tola F 450
Bolek M 100
Lolek M 222
run;


/* Sa cztery glowne typy czytania plikow tekstowych

   Patrz: OnlineDoc - BaseSAS\SASLanguageConcepts\ReadingRawData ze szczegolnym uwzglednieniem
   Reading Raw Data with the INPUT statement

*/

* UWAGA: dla wygody, we wszystkich ponizszych przykladach plik tekstowy jest zadany w kodzie
  programu. Wszystkie ponizsze przyklady i techniki dzialaja bez zmian w sytucji, gdy pliki
  tekstowe czytane sa z dysku;

/* 1. Czytanie wg list (List Input) */
/* Patrz: 
BaseSAS/SASLanguageDictionary/DictionaryOfLanguageElements/Statements/INPUT Statement, List
*/

data a;
 infile datalines; *ta linia jest opcjonalna, ale moze sie przydac, gdy bedziemy zmuszeni do
                    uzycia instrukcji INFILE, patrz pozniej;
 input kto $ plec $ ile; 
 cards;
Bolek M 100
Lolek M 120
Reksio D 29
; /* liczba spacji oddzielajacych elementy pliku dowolna, zalozenie: co najmniej jedna spacja */
run;

 * Kwestia brakow danych - opcja MISSOVER dla INFILE;
data a;
 infile datalines missover; *uzycie INFILE DATALINES jest wymuszone tutaj koniecznoscia uzycia
                             opcji MISSOVER;
                            * wiecej informacji nt. MISSOVER w OnlineDocu w miejscu, gdzie 
                              opisana jest instrukcja INFILE;
 input kto $ plec $ ile; 
 cards;
Bolek M 100
Lolek M 120
Tola F  
Reksio D 29
; 
run;

/*Co w sytuacji, gdy Tola 200 */
data a;
 infile datalines missover;
 input kto $ plec $ ile; 
 cards;
Bolek M 100
Lolek M 120
Tola 200  
Reksio D 29
; 
run;

*Inna sytuacja;
data a;
 input kto $ plec $ ile; 
 cards;
Bolek M 100
KrolikBugs M 100 
; /*tu trzeba najpierw zadeklarowac dlugosc, bo Krolik przekracza 8 bajtow*/
run;

data a;
 length kto $ 30;
 input kto $ plec $ ile; 
 cards;
Bolek M 100
KrolikBugs M 100 
; 
run;


/* Kolejny zasadniczy sposob czytania plikow tekstowych */
/* 2. Czytanie wg kolumn (Column Input) */
/* Patrz: 
BaseSAS/SASLanguageDictionary/DictionaryOfLanguageElements/Statements/INPUT Statement, Column
*/

data a;
 input kto $ 1-6 plec $ 7 ile 8-10;
 cards;
Bolek*M100
Lolek*M120
Tola**F222
ReksioD29
;
run;
* Jak widac, nie potrzeba spacji, kolejne elementy pliku wyznaczane sa przez pozycje 
kolumnowe;

data a;
 input kto $ 1-6 plec $ 7 ile 8-10;
 cards;
Bolek*M100
Lolek*M120
Tola** 200
ReksioD29
; /*tu oczywiscie nie ma problemow z brakujaca plcia Toli */
run;

/* Sposob trzeci */
/* 3. Czytanie wg informatów (Formatted Input)*/
/* Patrz: 
BaseSAS/SASLanguageDictionary/DictionaryOfLanguageElements/Statements/
INPUT Statement, Formatted
*/


* Prosty przyklad: chcemy wczytac ponizsze dane jako poprawne daty SASowe;
data a;
 input kiedy;
 cards;
 2005/12/20
 2003/09/08
 2000/07/03
 1997/11/30
 ;
run;
* To sie oczywiscie nie moze udac w ten sposob - zmienna KIEDY jest numeryczna, a w jej
wartosciach pojawiaja sie zmaki / ;
* Trzeba poinformowac SASa, jak powinien interpretowac wczytywane znaki;
* Sluza do tego INFORMATY (w tym przypadku informat yymmdd10.);
data a;
 input kiedy yymmdd10.;
 cards;
2005/12/20
2003/09/08
2000/07/03
1997/11/30
 ;
run;
* Informatow jest cala masa - patrz 
  BaseSAS\SASLanguageDictionary\DictionaryOfLanguageElements\Informats;
*Przy uzyciu INFORMATow nalezy uwazac na sytuacje w rodzaju:;
data a;
 input kiedy yymmdd10.;
 cards;
2005/12/20
 2003/09/08
2000/07/03
1997/11/30
 ;
run;
*To sie wysypie, bo SAS czyta dokladnie 10 znakow (tyle, ile zadeklarowano w dlugosci 
 informatu), w tym poczatkowa spacje.;

data f;
 input kto $6. +2 ile comma10.2 +2 kiedy yymmdd8.;
 cards;
Bolek***100,222.20**60/01/02
Lolek****78,444.33**02/02/02
Tola*********12.89**01/01/01
Reksio********1.00**00/12/31
;
run;
*Napisy typu +2 to instrukcje sterujace, tzw. POINTER CONTROLS, przesuwajace tzw. POINTER - 
w tym przypadku o dwa miejsca do przodu;

/* Sposob czwarty */
/* 4. Czytanie wg nazw (Named Input) */
/* Patrz: 
BaseSAS/SASLanguageDictionary/DictionaryOfLanguageElements/Statements/INPUT Statement, Named
*/
data a;
 input kto=$ ile=;
 cards;
 kto=Bolek ile=100
 kto=Lolek ile=0
run;
* Jesli plik wejsciowy ma taka strukture, wszystko jest latwe...;


/* Wreszcie kombinacja wszystkich (prawie) dotychczasowych sposobow: */
/* CZYTANIE W SPOSOB MIESZANY */

data f;
 input nr kto $ 3-9 +2 ile comma10.2 +2 kiedy yymmdd8.;
 cards;
1**Bolek***100,222.20**60/01/02
2**Lolek****78,444.33**02/02/02
3**Tola*********12.89**01/01/01
4**Reksio********1.00**00/12/31
;
run;

/* **************************************************************************************** */
* Krotka informacja o dodatkowych instrukcjach sterujacych;
* Jest ich cala masa, nalezy do klasowek pamietac tylko te, ktore sa uzyte w niniejszym pliku;
/* **************************************************************************************** */

*Zakladamy, ze w pliku wejsciowym zmienne KTO i ILE sa oddzielone co najmniej dwiema spacjami 
(jedna spacja nie jest separatorem zmiennych);
*Dodatkowo chcemy zarowno imie, jak i nazwisko, miec pod jedna zmienna KTO;
data g;
input kto $ ile;
cards;
Jan Kowalski  100
Jan Nowak  200
; 
run;
*Tak sie oczywiscie wysypuje;
*W takiej sytuacji pomaga ampersand: & (po zmiennej, ktorej dotyczy);
data g;
input kto $ & ile;
cards;
Jan Kowalski  100
Jan Nowak  200
; 
run;
* Musimy poprawnie zadeklarowac dlugosc;
data g;
length kto $ 20;
input kto $ & ile;
cards;
Jan Kowalski  100
Jan Nowak  200
; 
run;

/* Kolejna instrukcja sterujaca - : */
data h;
input pensja commax5.2 kto $;
cards;
12,11 Bolek
2,2 Lolek
;
run;
*Wysypka :( - Lolek nachodzi na pensje;
data h;
input pensja :commax5.2 kto $;
cards;
12,11 Bolek
2,2 Lolek
;
run;
/*
Symbol :
Uzyty przed nazwa informatu powoduje, ze podczas czytania zmiennej uwzgledniane sa tylko 
znaki do najblizszego separatora, a nie tyle, ile wynikaloby z dlugosci informatu.
*/

* Przydatny argument instrukcji INPUT - tzw. trailing @;
data f;
 infile cards;
 input indyk $ x1 @;
 if indyk='T' then input x2;
  else input @6 x3;
  cards;
    T 1 2 3
    N 2 3 4
    T 3 4 5
	;
run;
* @ na koncu linijki z instrukcja INPUT zatrzymuje rekord wejsciowy w buforze na czas
wykonania danego obrotu petli glownej;
* Uwaga: malpka w @6 ma inne znaczenie - jest to jeden z tzw. Column Pointer Controls, ktory
przesuwa pointer do zadanej kolumny; 
* Dla zrozumienia - wykonac powyzszy kod bez uzycia trailing @;

* Inny przydatny argument instrukcji INPUT - dwie malpy, czyli double trailing @;
data i;
 infile cards;
 input litera $ x @@; 
 cards;
A 1 B 2
C 3
D 4 E 5 F 6
;
run;
* @@ na koncu linijki z instrukcja INPUT zatrzymuja rekord wejsciowy w buforze takze 
pomiedzy obrotami petli glownej;
* Wykonac powyzszy kod z jedna malpka oraz bez malpek;
* W wersji z dwoma malpkami zaobserwowac za pomoca PUT _ALL_ zachowanie sie zmiennej _N_;

* Przejscie do nastepnej linijki "w obrebie" tej samej instrukcji INPUT;
data j;
 infile cards;
 input kto $ x / y; *to samo co dwa inputy;
 cards;
    Bolek 1
    22.4
    Lolek 2
    245.99
    Tola 3
    999.09
	;
run;

* Domyslnie INPUT czyta pojedyncza instrukcje. Istnieje jednak mozliwosc wczytywania kilku
linijek pliku tekstowego naraz. Sluzy do tego opcja do instrukcji INFILE - N= 
(dobrze znalezc i przeczytac odpowiedni fragment z dokumentacji. Przydatny jest w tym 
kontekscie jeden z Line Pointer Controls, #(liczba) - patrz informacja nt. Line Pointer 
Controls w opisie instrucji INPUT;


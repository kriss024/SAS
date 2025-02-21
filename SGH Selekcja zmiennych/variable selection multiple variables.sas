/* CV = Coefficient of Variation - Współczynnik zmienności*/
/*Pokazuje nam jak silnie jest zróżnicowanie danych. Służy do porównań zróżnicowania kilku zmiennych. */
/*Wynik najczęściej przedstawia się w procentach, co interpretujemy jako "typowy procentowy odchylenie od normy". Jeżeli współczynnik zmienności wynosi powyżej 10% to cecha jest istotna statystycznie*/
/*    V > 10% – jest istotność statystyczna */
/*    V < 20% – mała zmienność*/
/*    20% < V < 40% – przeciętna zmienność*/
/*    40% <V < 100% – duża zmienność*/
/*    100% < V<150% – bardzo duża zmienność*/
/*    V > 150% – skrajnie duża zmienność*/

/*Statystyka Kołmogorowa-Smirnowa (K-S) służy do ustalania maksymalnej różnicy pomiędzy skumulowanym procentem „dobrych” i „złych” kredytów. */
/*Im wyższa wartość K-S, tym większy potencjał modelu. Jeżeli wartość K-S wynosi 0, */
/*model nie jest w stanie rozróżnić kredytów „dobrych” i „złych”, */
/*natomiast wartość K-S równa 100 oznacza zdolność do całkowitego rozróżnienia tych dwóch rozkładów. */

/*Współczynnik Giniego służy do pomiaru przewagi karty punktowej nad systemem losowo podejmowanych decyzji. */
/*Przedstawia on stosunek wielkości pola obszaru B - nad przekątną i pod  krzywą */
/*(oznaczającego  efektywność podejmowania decyzji w oparciu o wyniki oceny punktowej) - */
/*do wielkości pola obszaru A+B - nad przekątną (oznaczającego losowo podejmowane decyzje). */
/*Wartości współczynnika mieszczą się  w przedziale <-1,1>. */
/*Wyższa wartość współczynnika informuje o lepszym segregowaniu klientów. */
/*Żaden „porządny” klasyfikator nie powinien mieć wartości Gini <0,5 */
/*Gini = 2*AUC-1 */

/*Krzywa ROC (Receiver Operating Characteristic Curve) umożliwia graficzne przedstawienie */
/*dokładności diagnostycznej modelu. Wykres krzywej ROC przedstawia zależność wskaźników odpowiadających odpowiednio za czułość i swoistość modelu. */
/*Czułość modelu określa zdolność modelu do właściwego klasyfikowania „złych” kredytów do grupy „złych”, */
/*natomiast swoistość określa zdolność modelu do wykrywania kredytów „dobrych” i przypisywania ich do tej właśnie grupy. */
/*Oceną modelu na podstawie krzywej ROC jest pole nad krzywą (im większe, tym lepsze). */
/*Stosuje się następującą interpretację:*/
/*	Pole = 1 – model doskonały*/
/*	0,9 ≤ pole < 1 – model bardzo dobry*/
/*	0,8 ≤ pole < 0,9 – model dobry*/
/*	0,7 ≤ pole < 0,8 – model słaby*/
/*	pole = 0,5 – model losowy*/

/*Dywergencja jest miarą pokazującą zdolność modelu scoringowego do separowania „dobrych” i „złych” klientów. */
/*Bazuje ona na średnim wyniku dla rozkładu klientów „dobrych”  i „złych” oraz zróżnicowaniu wyników w ramach każdego z tych rozkładów. */
/*Im bardziej oddalone od siebie są  te  rozkłady,  tym  większy jest  potencjał  prognostyczny  modelu. */
/*W praktyce zakłada się, że dla poprawnie działającego modelu scoringowego wartość współczynnika dywergencji jest większa od 0,5.*/

/*Współczynnik IV (Information Value – moc informacyjna zmiennej) odnosi się do oddzielenia rozkładu wyników dla kredytów „dobrych” i „złych”. */
/*Do obliczenia współczynnika stosuje się średni wynik dla rozkładu każdej grupy, jak również statystyczny rozrzut wyników w ramach każdego rozkładu. */
/*Im bardziej oddalone są od siebie rozkłady wyników dla kredytów „dobrych” i „złych” (tj. im większy jest współczynnik IV), */
/*tym większy jest potencjał prognostyczny modelu w zakresie odróżniania kredytów „dobrych” od „złych”.*/
/*Stosuje się następującą interpretację współczynnika IV:*/
/*	IV < 0,02 - brak mocy predykcyjnej*/
/*	0,02 ≤ IV < 0,1 - słaba moc predykcyjna*/
/*	0,1 ≤ IV < 0,3 - średnia moc predykcyjna*/
/*	IV ≥ 0,3 - silna moc predykcyjna.*/


/************************************/

libname tmp "C:\Users\Krzysztof\Desktop\SGH Variable Selection Gini";

data Churn;
set tmp.churn;
run;

/**************/

%MACRO DATA_QUALITY(ds_in, ds_out, variables);

%if %sysfunc(exist(&ds_out.)) %then %do;
proc delete data = &ds_out.;
run;
%end;

data _a1;
set &ds_in.;
keep &variables.;
stop;
run;

proc transpose data=_a1 out=_a2(keep=_name_);
var _all_;
run;

proc sql noprint; 
select _name_
into :var_list separated by ' '
from _a2;
select count(*)
into :num
from _a2;
quit;

data _a3;
set &ds_in.;
keep &variables.;
run;

%do i=1 %to &num.;
%let v = %scan(&var_list,&i.);

proc univariate noprint data=_a3 alpha=0.05;
var &v.;
output out=_s1 n=n nmiss=missing mean=mean std=std cv=cv;
run;

data _s2;
length variables $50;
set _s1;
variables="&v.";
run;

%if %sysfunc(exist(&ds_out.)) %then %do;
proc append base=&ds_out. data=_s2 force;
run;
%end; %else %do;
data &ds_out.;
set _s2;
run;
%end;

%end;

%MEND DATA_QUALITY;

/**************/

%DATA_QUALITY(Churn, DQStat, _numeric_)

data DQStat;
set DQStat;
where missing = 0 and cv>10;
run;

/**************/

%MACRO VARIABLE_QUALITY(dsn, P_TARGET, P_VAR);
%global auc gini ks divergence;

ods select none;
ods output wilcoxonscores = _wx;
ods output kolsmir2stats = _ks;
proc npar1way wilcoxon edf data = &dsn.;
  class &P_TARGET.;
  var &P_VAR.;
run;
ods select all;

proc sort data = _wx;
by class;
run;

*** CALCULATE ROC AND GINI ***;
data _null_;
  set _wx end = eof;
  by class;
 
  array a{2, 3} _temporary_;
  if _n_ = 1 then do;
    a[1, 1] = n;
    a[1, 2] = sumofscores;
    a[1, 3] = expectedsum;
  end;
  else do;
    a[2, 1] = n;
  end;
  if eof then do;
    auc  = (a[1, 2] - a[1, 3]) / (a[1, 1] * a[2, 1])  + 0.5;
    if auc <= 0.5 then auc = 1 - auc;
    gini = 2 * (auc - 0.5);
	call symputx('auc', auc);
	call symputx('gini', gini);
  end;
run;

*** CALCULATE KS ***;
data _null_;
  set _ks;
  if _n_ = 1 then do;
    ks = nvalue2;
    call symputx('ks', ks);
  end;
run;

proc summary data = &dsn. nway noprint;
  class &P_TARGET.;
  output out = _diver (drop = _type_ _freq_)
  mean(&P_VAR.) = mean var(&P_VAR.) = variance;
run;
 
*** CALCULATE DIVERGENCE ***;
data _null_;
  set _diver end = eof;
  array a{2, 2} _temporary_;
  if _n_ = 1 then do;
    a[1, 1] = mean;
    a[1, 2] = variance;
  end;
  else do;
    a[2, 1] = mean;
    a[2, 2] = variance;
  end;
  if eof then do;
    divergence = (a[1, 1] - a[2, 1]) ** 2 / ((a[1, 2] + a[2, 2]) / 2);
	call symputx('divergence', divergence);
  end; 
run;

%MEND VARIABLE_QUALITY;

/**************/

%MACRO VARIABLE_SCORING(ds_in, ds_out, ds_var, target);

%if %sysfunc(exist(&ds_out.)) %then %do;
proc delete data = &ds_out.;
run;
%end;

proc sql noprint; 
select variables
into :var_list separated by ' '
from &ds_var.;
select count(*)
into :num
from &ds_var.;
quit;

data _a3;
set &ds_in.;
keep &target. &var_list.;
run;

%do i=1 %to &num.;
%let v = %scan(&var_list,&i.);

%VARIABLE_QUALITY(_a3, &target., &v.);

data _s4;
length variables $50;
length auc 8.;
length gini 8.;
length ks 8.;
length divergence 8.;
variables="&v.";
auc = &auc.;
gini = &gini.;
ks = &ks.;
divergence = &divergence.;
run;

%if %sysfunc(exist(&ds_out.)) %then %do;
proc append base=&ds_out. data=_s4 force;
run;
%end; %else %do;
data &ds_out.;
set _s4;
run;
%end;

%end;

proc sort data=&ds_out.;
by descending Gini;
run;

%MEND VARIABLE_SCORING;

/**************/

%VARIABLE_SCORING(Churn, GiniStat, DQStat, Churn)

proc print data=DQStat;
run;

proc print data=GiniStat;
run;

proc rank data=GiniStat out=GiniStatRank descending 
groups=4 ties=low;
run;

data GiniStatRank;
set GiniStatRank;
best=round(mean(gini, ks, divergence),.0001);
keep variables best;
run;

proc print data=GiniStatRank;
run;


proc univariate data=Churn noprint;
class Churn;
var total_day_minutes;
histogram /normal (color=blue w=1);
run;

ods graphics on;
proc logistic data=Churn;
model Churn(event='True') = total_day_minutes number_customer_service_calls;
effectplot;
run;
ods graphics off;
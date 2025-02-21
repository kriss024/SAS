/*Interactive Matrix Language przyklady*/

data zbior;
input a b c;
datalines;
1 2 3
4 5 6
7 8 9
;

proc iml;
use zbior;
read all var {a b c} into B; *use all 3 columns of data for matrix B;
print B; *displays matrix B in the output;
quit;


proc iml;
* Read data into IML ;
use test;
read all var _NUM_ into A;
close;
B = A * 2;
print A; print B;
quit;

proc iml;
x = {1 2 3, 4 5 6};
n = nrow(x);
p = ncol(x);
dim = dimension(x);
print dim;
quit;

proc iml; *invokes IML;
a = 2; *scalar;
b = {1 2 3 4}; *1 x 4 row vector;
c = {1.0 0 0, 0.2 1.0 0, 0.8 0.4 1.0}; *3 x 3 (correlation) matrix;
quit; *closes IML;

proc iml;
reset print;
A = {1 2 3,
     4 5 6,
     7 8 9};
quit;

proc iml;
A = {1 2 3,
     4 5 6,
     7 8 9};
print A; *displays matrix A in the output;
quit;


proc iml;
A = {1 2 3,
     4 5 6,
     7 8 9};
create dane from A;
append from A;
close dane;


proc iml;
A = {1 2 3,
     4 5 6,
     7 8 9};
create dane2 from A[colname={"q" "r" "s"}];
append from A;
close dane2;


proc iml;
y = {1,0,3,2,0,3}; /** 6 x 1 vector **/
z = {8,7,6,5,6};   /** 5 x 1 vector **/
c = {A A A B B B}; /** 1 x 6 character vector **/

create dane3 var {y z c}; /** create data set **/
append;       /** write data in vectors **/
close dane3;  /** close the data set **/


proc iml;
a = I(6); * 6x6 identity matrix;
b = J(5,5,0); *5x5 matrix of 0's;
c = J(6,1); *6x1 column vector of 1's;
d=diag({1 2 4});
e=diag({1 2, 3 4});
print a; print b; print c; print d; print e;
quit;

proc iml;
reset noprint;
X ={1 2, 3 4};
Y ={-4 3,-2 -1};
a = X+X; *addition;
b = X-X; *subtraction;
c = -Y; *sign reversal;
d = abs(Y); *takiing absolute value;
e = X*X; *matrix multiplication;
f = sqrt(X); *taking square roots of the elements;
g = t(X); *transpose using function;
h = det(X); *matrix determinant;
i = inv(X); *matrix inverse;
j = tr(X); *trace of a matrix;
k = eigval(X); *eigen values of matrix;
l = eigvec(X); *eigen vector of matrix;
m = min(X); *smallest matrix element;
n = max(X); *largest matrix element;
print a; print b; print c; print d; print e; print f; print g;
print h; print i; print j; print k; print l; print m; print n;
quit;

proc iml;
reset noprint;
A = {1 2 3,
     4 5 6,
     7 8 9};
B = 2 # A;
print A; print B [format=5.2 label="Mno¿enie"];
quit;

proc iml;
reset print;
A ={1 4, 9 16};
B ={1 0,-1 0};
suma = A+B;
roznica = A-B;
iloczyn = A*B;
ioloczym_l = 2*A;
C = -A;
bezwgledna = abs(B);
pierwiastek = sqrt(A);
minimalny_elem = max(A);
maksymalny_elem = min(A);
quit;


proc iml;
reset print;
A ={1 2,3 4};
transpozycja = t(A);
wyznacznik = det(A);
m_odwrotna = inv(A);
slad = trace(A);
quit;

proc iml;
start M(x,y); *module M defined.;
  y=x*2;
finish;

start F(x); *function F defined.;
  y=x+2;
return y;
finish;

A = {1 2 3,
     4 5 6,
     7 8 9};
run M(A,B);
C = F(A);
print A; print B; print C;
quit;


/*Reading ALL variables INTO a matrix*/

data Mixed;
   x=1; y=2; z=3; a='A'; b='B'; c='C';
run;

proc iml;
use Mixed;
   read all var _ALL_;
close Mixed;
show names;

proc iml;
use Mixed;
   read all var _ALL_ into A[colname=varNames];
close Mixed;
print varNames;

proc iml;
use Mixed;
   read all var _NUM_ into X[colname=NumerNames];
   read all var _CHAR_ into C[colname=CharNames];
close;
print NumerNames, CharNames;

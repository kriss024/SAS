data Big;
length Id 8.;
length Name $8;
length Age 8.;
infile datalines delimiter='09'x;
input Id Name Age;
datalines;
1	Carol	14
2	Jane	12
3	Jeffrey	13
4	Judy	14
5	Mary	15
6	Thomas	11
7	William	15
;

data Small;
length Id 8.;
length Gender $1;
length Order 8.;
infile datalines delimiter='09'x;
input Id Gender Order;
datalines;
1	F	1
2	F	1
3	M	2
5	F	1
7	M	2
;

/*********************************************/

data inner_join(keep=Id Name Gender);
set Small (obs=1);
declare hash ht (dataset:'Small');
ht.definekey ('Id');
ht.definedata(all: 'YES');
ht.definedone ();
do until (eof);
	set Big end = eof;
	if ht.find() = 0 then output;
end;
stop;
run;

data left_join;
set Small (obs=1);
declare hash ht (dataset:'Small');
ht.DefineKey ('Id');
ht.definedata(all: 'YES');
ht.DefineDone ();
 do until(eof);     
	set Big end=eof; 
 	if ht.find() = 0 then output;
		else do; 
		call missing(of Gender--Order);    
		output;      
	end;   
 end;  
 stop;
run;

data left_join2(drop=rc);
 declare Hash ht (); 					/* declare the name Plan for hash */
 	rc = ht.DefineKey ('Id'); 			/* identify fields to use as keys */
 	rc = ht.DefineData ('Gender', 'Order');    		/* identify fields to use as data */
 	rc = ht.DefineDone (); 				/* complete hash table definition */
 do until (eof1) ; 						/* loop to read records from Plan */
 	set Small end = eof1;
 	rc = ht.add (); 					/* add each record to the hash table */
 end;
 do until (eof2) ; 						/* loop to read records from Members */
 	set Big end = eof2;
	call missing(Gender, Order); 		/* initialize the variable we intend to fill */
 	rc = ht.find(); 					/* lookup each plan_id in hash Plan */
 output; 								/* write record to Both */
 end;
 stop;
run; 

/*Wyszukiwanie*/
data _null_;
set Big (obs=1);
declare hash ht (dataset:'Big');
rc = ht.definekey('Name');
rc = ht.definedata(all:'YES');
ht.definedone();
Name='William';
rc=ht.find();
put _all_;
rc=ht.find(key:	'Carol');
put _all_;
run;

/*Sortowanie*/
data _null_;
set Big (obs=1);
declare hash ht(dataset: 'Big', multidata: 'YES' , ordered:'a');
ht.DefineKey ('Age');
ht.definedata (all: 'YES');
ht.definedone();
ht.output(dataset: 'Wynik_sort');
run;


/*Usuwanie duplikatów*/
data _null_;
set Big (obs=1);
declare hash ht(dataset: 'Big', ordered:'a');
ht.DefineKey ('Age');
ht.definedata (all: 'YES');
ht.definedone();
ht.output(dataset:'Wynik_nodupkey');
run;
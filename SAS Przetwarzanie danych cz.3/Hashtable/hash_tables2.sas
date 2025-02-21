data employee;
  input @01 employee_id   6.
        @08 last_name     $10.;
  format employee_id   6.
         last_name     $10.;
  status = .;
  datalines;
  1247 Garcia
  1078 Gibson
  1005 Knapp
  1024 Mueller
;

data managers;
  input @01 employee_id   6.
        @08 man_name     $10.;
  format employee_id   6.
         man_name     $10.;
  status = 1;
  datalines;
  1247 Mark
  1078 Mark
  1006 Anna
;

/** Obiekt HASH - aktualizacja wartoœci tabeli employee 
o wartoœci zawarte w tabeli managers **/

data employee_up (drop = rc); 
	declare hash managers_hash(dataset: 'managers (keep = employee_id status)');
	managers_hash.definekey('employee_id'); 
	managers_hash.definedata('employee_id', 'status'); 
	managers_hash.definedone(); 
	do until(koniec_tabeli); 
		set employee end = koniec_tabeli; 
		rc = managers_hash.find(); 
		output; 
	end; 
	stop;
run;


/** Obiekt HITER - sekwencyjny dostêp do tablicy 
- wypisanie zawartoœci tablicy mieszaj¹cej w kolejnoœci przechowywania **/

data managers_hiter (drop = rc); 
	set managers (obs=1); 
	declare hash managers_hash(dataset: 'managers'); 
	declare hiter managers_hiter('managers_hash'); 
	managers_hash.definekey('employee_id'); 
	managers_hash.definedata(all: 'yes'); 
	managers_hash.definedone(); 
	rc = managers_hiter.last();
	do while(rc = 0);
		output;
		rc = managers_hiter.prev();
	end;
	stop; 
run; 
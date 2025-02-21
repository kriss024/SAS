data pd3.export_formaty;
	DataCzas=datetime();
	format DataCzas datetime.;

	Data=today();
	format Data date9.;
	Czas=time();
	format Czas timeampm.;

proc print data=pd3.export_formaty;
run;
data dict;
set sashelp.class(keep=name age);
run;

data klasa_bez_wieku;
set sashelp.class(drop=age);
run;

data just_like_format;
set klasa_bez_wieku;
length age 8;
if _N_=1 then do;
  declare hash hh ( dataset: 'dict' ) ; 
  hh.DefineKey ( 'name' ) ; 
  hh.DefineData ( 'name' , 'age' ) ; 
  hh.DefineDone () ; 
end;
hh.find();
run;

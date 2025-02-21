data class;
length Sex_ 8.;
set sashelp.class;
if Sex = 'F' then Sex_ = 1; else Sex_ = 0;
if mod(_N_, 2) > 0 then Sex_ = .;
if mod(_N_, 2) = 0 then Height =.;
keep Sex_ Age Height Weight;
run;

proc means data = class nmiss n min max mean std;
var Sex_ Age Height Weight;
run; 

proc mi data=class out=class_input nimpute=1;
class Sex_;
var Sex_ Age Height Weight;
fcs logistic(Sex_);
run;

proc glm data = class_input;
class Sex_;
model Sex_ = Age Height Weight /solution ss3;
ods output ParameterEstimates=a_mvn;
run;
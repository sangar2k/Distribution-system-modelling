function [tr]=curves(type,M,TDS)
M1=M;
if type==8 
A=1.15;
B=0.015;p=0.8;
tr=TDS*((A./((M1.^p)-1))+B);

elseif type==7
A=0.95;
B=0.015;p=1.2;
tr=TDS*((A./((M1.^p)-1))+B);


elseif type==5
A=0.08;
B=0.015;p=0.02;
tr=TDS*((A./((M1.^p)-1))+B);

else
disp("This relay is not included in this program")

end

end
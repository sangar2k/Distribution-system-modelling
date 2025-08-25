%% Get the user input
clear all
bus = input('How many buses are in the system? ... ... ');
location = input('is the fault at a bus (0) or in the line(1) ? ... ... ');
if location == 0
F_bus = input('What is the faulted bus? ... ... ');
else
   In_bus = input('Enter two numbers(connected busses)  separated by space (enter small numer first): ', 's');
   busses= str2double(strsplit(In_bus));
    Z_loc = input(['Enter how far (in %) the fault is from bus ', num2str(busses(1)),': ']);Z_loc=Z_loc/100;
end
V_F = input('What is the fault voltage ? ... ... ');
Z_F = input('What is the fault impedance? ... ... ');
F_Type=input('What is the fault type? ...answer should be a 4 digit number faulted phase will be 1 nonfaulted phase will be 0. The digit format is ABCG(Phases A,B,C & Ground). EG.: 3Phase to Ground:- 1111 , Phase B to Ground fault:-0101 ', 's');
        %  app=app2
        % waitfor(app);
        % T1= tableDataFromApp


%% Temp data
% Define data for each column
% FromBus   = T1(:,1);
% ToBus     = T1(:,2);
% ConnType  = T1(:,3);
% ZeroSeqX  = T1(:,4);
% PosSeqX   = T1(:,5);
% NegSeqX   = T1(:,6);
% NeutralX  = T1(:,7); % Use NaN for missing data
FromBus   = [1;	1;	2;	2;	2;	3;	4;	4;	4;	5;	6;	6;	6;	7;	7;	9;	9;	10;	12;	13; 4;4;5; 1;2;3;6;8];
ToBus     = [2;	5;	3;	4;	5;	4;	5;	7;	9;	6;	11;	12;	13;	8;	9;	10;	14;	11;	13;	14; 8;9;6; 0;0;0;0;0];
ConnType  = [1;	1;	1;	1;	1;	1;	1;	1;	1;	1;	1;	1;	1;	1;	1;	1;	1;	1;	1;	1;	 34;34;36; 0;0;0;0;0];
ZeroSeqX  = [0.06;	0.22;	0.20;	0.18;	0.17;	0.17;	0.04;	0.21;	0.56;	0.25;	0.20;	0.26;	0.13;	0.18;	0.11;	0.08;	0.27;	0.19;	0.20;	0.35;	0.209;0.556;0.252; 0.2;0.2;0.2;0.2;0.2];
PosSeqX   = [0.06;	0.22;	0.20;	0.18;	0.17;	0.17;	0.04;	0.21;	0.56;	0.25;	0.20;	0.26;	0.13;	0.18;	0.11;	0.08;	0.27;	0.19;	0.20;	0.35;	0.209;0.556;0.252; 0.2;0.2;0.2;0.2;0.2];
NegSeqX   = [0.06;	0.22;	0.20;	0.18;	0.17;	0.17;	0.04;	0.21;	0.56;	0.25;	0.20;	0.26;	0.13;	0.18;	0.11;	0.08;	0.27;	0.19;	0.20;	0.35;	0.209;0.556;0.252; 0.2;0.2;0.2;0.2;0.2];
NeutralX  = [0;	0;	0;	0;	0;	0;	0;	0;	0;	0;	0;	0;	0;	0;	0;	0;	0;	0;	0;		0;0;0;0; 0;0;0;0;0];

    if location == 1
        bus=bus+1;F_bus=bus;
        rowToRemove=find(FromBus == busses(1) & ToBus == busses(2));  index1=rowToRemove;
    
    ZeroSeqXR1=Z_loc*ZeroSeqX(index1);PosSeqXR1=Z_loc*PosSeqX(index1);NegSeqXR1=Z_loc*NegSeqX(index1); NeutralXR1=Z_loc*NeutralX(index1);
    ZeroSeqXR2=(1-Z_loc)*ZeroSeqX(index1);PosSeqXR2=(1-Z_loc)*PosSeqX(index1);NegSeqXR2=(1-Z_loc)*NegSeqX(index1); NeutralXR2=(1-Z_loc)*NeutralX(index1);
    end
% Create table

T = table(FromBus, ToBus, ConnType, ZeroSeqX, PosSeqX, NegSeqX, NeutralX);
Y0=zeros(bus,bus);Y1=zeros(bus,bus);Y2=zeros(bus,bus);

if location == 1
    %Y0=zeros(bus-2,bus-2);Y1=zeros(bus-2,bus-2);Y2=zeros(bus-2,bus-2);
T(rowToRemove, :) = [];
newRow1={busses(1), bus, 1, ZeroSeqXR1, PosSeqXR1, NegSeqXR1, NeutralXR1};
newRow2={bus, busses(2), 1, ZeroSeqXR1, PosSeqXR1, NegSeqXR1, NeutralXR1};
newRow1_Table=cell2table(newRow1,'VariableNames',T.Properties.VariableNames);
newRow2_Table=cell2table(newRow2,'VariableNames',T.Properties.VariableNames);
T=[T;newRow1_Table;newRow2_Table];
end
%% ZBus Construction
    % Zero sequence
    for i=1:height(T)
        comp=T{i,3} ;% Check for the component type
        if comp==1 % If line
            FB=(T{i,1}); TB=(T{i,2});
            Y0(FB,TB)=-1/T{i,4};Y0(TB,FB)=Y0(FB,TB);
            Y0(FB,FB)=Y0(FB,FB)+1/T{i,4};Y0(TB,TB)=Y0(TB,TB)+1/T{i,4};
            %%%%%%%%%%%%%%%%%%%%%%% positive seq
            Y1(FB,TB)=-1/T{i,5};Y1(TB,FB)=Y1(FB,TB);
            Y1(FB,FB)=Y1(FB,FB)+1/T{i,5};Y1(TB,TB)=Y1(TB,TB)+1/T{i,5};  
            %%%%%%%%%%%%%%%%%%% Neg Seq
            Y2(FB,TB)=-1/T{i,6};Y2(TB,FB)=Y2(FB,TB);
            Y2(FB,FB)=Y2(FB,FB)+1/T{i,6};Y2(TB,TB)=Y2(TB,TB)+1/T{i,6};
        elseif comp>30   %check whether= a transformer
            FB=(T{i,1}); TB=(T{i,2});X=(T{i,4});Xn=0;
            [Zbetween,Zself1,Zself2]=TrImp(comp,FB,TB,X,Xn);
            Y0(FB,TB)=-1/Zbetween;Y0(TB,FB)=Y0(FB,TB);
            Y0(FB,FB)=Y0(FB,FB)+1/Zself1;Y0(TB,TB)=Y0(TB,TB)+1/Zself2;
           %%%%%%%%%%%%%%%%%%%%%%% positive seq
            Y1(FB,TB)=-1/T{i,5};Y1(TB,FB)=Y1(FB,TB);
            Y1(FB,FB)=Y1(FB,FB)+1/T{i,5};Y1(TB,TB)=Y1(TB,TB)+1/T{i,5};  
            %%%%%%%%%%%%%%%%%%% Neg Seq
            Y2(FB,TB)=-1/T{i,4};Y2(TB,FB)=Y2(FB,TB);
            Y2(FB,FB)=Y2(FB,FB)+1/T{i,6};Y2(TB,TB)=Y2(TB,TB)+1/T{i,6};
        else
            CB=(T{i,1});%gen connected bus
            Y0(CB,CB)=Y0(CB,CB)+1/T{i,4};
            Y1(CB,CB)=Y1(CB,CB)+1/T{i,5};
            Y2(CB,CB)=Y2(CB,CB)+1/T{i,6};
        end
    end
Z0=j*inv(Y0);Z1=j*inv(Y1);Z2=j*inv(Y2);


%% Fault Analysis
    F_Type_B = str2double(cellstr(F_Type.')).';
    Bus=F_bus;Z0n=Z0(Bus,Bus);Z1n=Z1(Bus,Bus);Z2n=Z2(Bus,Bus);
[F_Current]=Fault_Analysis(F_Type_B,V_F,F_bus,Bus,Z0n,Z1n,Z2n,Z_F);
Table=table();
a=exp(1j*2*pi/3);
A=[1,1,1;1,a^2,a;1,a,a^2];

for k=1:bus
    Bus=k;
Z0kn=Z0(k,F_bus);Z1kn=Z1(k,F_bus);Z2kn=Z2(k,F_bus);
F_Voltage=[0,V_F,0]'+[Z0kn,0,0;0,Z1kn,0;0,0,Z2kn]*F_Current';
F_Voltage=A*F_Voltage;F_Voltage=abs(F_Voltage);
newRow = array2table(F_Voltage', 'VariableNames', {'Va','Vb','Vc'});
newRow.bus=k;
newRow=newRow(:,{'bus','Va','Vb','Vc'});
Table=[Table;newRow];
end

F_Current

Table
%%input
clear all
TDS_defined=[0.5,1,2,3,4,5,6,7,8,9,10,11];
Tbreaker=0.083;Tcordination=0.3;
V_ll=input('Enter the line to line voltage(V,not kV): ');
Case=input('Do you wnat the system to calculate maximum fault current? Enter 1 for yes 0 for no ');
if Case==1
    disp('you can leave the maximum fault current entry column blank when you enter the data')
end
%% Get the data from user
 app=GUI
 uiwait(app.UIFigure); 
 T1= tableDataFromApp;
 T2= tableDataFromApp2;
n=height(T1);

%% maximum fault current calculation
if Case==1
    Zs = input('Enter the sum of the source and transfromer positive seq impedances... ');
    zth(1)=Zs;
    for i=2:n
        zij(i) = input(['what is the impedance between busses ', num2str(i),' and ', num2str(i+1),': ']);
        zth(i)=zth(i-1)+zij(i);
    end
     I_fault=abs((V_ll./zth)/sqrt(3));
else
   
    I_fault=T1(:,3)';
end
 %% TS  selection
 for i=height(T1):-1:1
     S(i)=T1(i,2);R=T2(i,4)/T2(i,3);
     IL(i)=10^6*(sum(S))/(sqrt(3)*V_ll);
     IL(i)=IL(i)*R;
     
     %%%%%%%%%%% selecting TS and Pickup currents
     if IL(i)<=1 
        IP(i)=ceil((IL(i)/0.1))*0.1;
     elseif IL(i)<=4 && IL(i)>1
          IP(i)=ceil((IL(i)/0.5))*0.5;
     else
         IP(i)=ceil(IL(i));
     end
%%%%%%%%%%%% estimating multiples of pickup

 end
 
 %% TDS Selection
for j=height(T1):-1:1
    R=T2(j,4)/T2(j,3);type=T2(j,5);
    if j==height(T1)
        TDS1=1/2;
        I_faultj=I_fault(j-1);
        Imultiple(j)=R*(I_faultj/IP(j));
    elseif j==1
        
        Imultiple(1)=R*(I_fault(1)/IP(1));
         tinterval=tr(2)+Tbreaker+Tcordination;
         for k=1:length(TDS_defined)
                TDS1=TDS_defined(k);
                tr(1)=curves(type,Imultiple(1),TDS1);
              if tr(1)>=tinterval   
              break;
              end
            
         end
    else
        tinterval=tr(j+1)+Tbreaker+Tcordination;
        I_faultj=I_fault(j);
        Imultiple(j)=R*(I_faultj/IP(j));
        
            for k=1:length(TDS_defined)
                TDS1=TDS_defined(k);
                tr(j)=curves(type,Imultiple(j),TDS1);
              if tr(j)>=tinterval   
              break;
              end
            
           end

    end
    TDS(j)=TDS1;
    tr(j)=curves(type,Imultiple(j),TDS(j));
end

disp('Please find the relay settings as follows')
a=1:1:n;
TO=table(a',IP',TDS','VariableNames', {'Breaker','Tap Settings','Time Dial Settings'})


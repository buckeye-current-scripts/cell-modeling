clear; clc; close all;

%% load and parse RCID test data
filename = 'Test Data\Current_RCID_26650Efest_Cell1.txt';
delimiter = '\t';
startRow = 4;
formatSpec = '%f%f%f%f%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,0,'HeaderLines' ,startRow-1, 'ReturnOnError', false);
fclose(fileID);
% Alocate parameters
Step = dataArray{:, 1};
TestTime = dataArray{:, 2};
StepTime = dataArray{:, 3};
Amphr = dataArray{:, 4};
Amps = dataArray{:, 5};
Volts = dataArray{:, 6};
Temp = dataArray{:, 7};
% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans;


%% calculate SOC
SOC_init=.97; %this is currently set by hand 
cell_cap=4.2;
Ah_out(1)=0;
Cap_out(1)=0;
for i=2:length(Amps)
    Ah_out(i)=Ah_out(i-1)+(TestTime(i)-TestTime(i-1)).*Amps(i)./3600;
    SOC(i)=Ah_out(i)/cell_cap+SOC_init;
end

%% plot the data so you know what the fuck you're looking at 

figure('color','white');
set(gca, 'fontsize', 16);
hold on; grid on;
yyaxis left
plot(TestTime, Amps, 'linewidth', 2);
ylabel('Current [A]');
yyaxis right
plot(TestTime, Volts, 'linewidth', 2);
xlabel('Time [s]');
ylabel('Voltage [V]');

figure('color','white');
set(gca, 'fontsize', 16);
hold on; grid on;
plot(TestTime, SOC, 'linewidth', 2);
ylabel('SOC [-]');
xlabel('Time [s]');

%% split data into SOC windows
%doing manually now, fix to be automatic later

%10 percent SOC
Start_010=find(TestTime>=112211.99,1);
End_010=find(TestTime>=121889.39,1);
V_dat{1}=Volts(Start_010:End_010);
I_dat{1}=Amps(Start_010:End_010);
Time_dat{1}=TestTime(Start_010:End_010)-TestTime(Start_010);
Temp_dat{1}=Temp(Start_010:End_010);
SOC_dat{1}=SOC(Start_010:End_010);

%20 percent SOC
Start_020=find(TestTime>=100691.29,1);
End_020=find(TestTime>=110368.69,1);
V_dat{2}=Volts(Start_020:End_020);
I_dat{2}=Amps(Start_020:End_020);
Time_dat{2}=TestTime(Start_020:End_020)-TestTime(Start_020);
Temp_dat{2}=Temp(Start_020:End_020);
SOC_dat{2}=SOC(Start_020:End_020);

%30 percent SOC
Start_030=find(TestTime>=88248.86,1);
End_030=find(TestTime>=98498.43,1);
V_dat{3}=Volts(Start_030:End_030);
I_dat{3}=Amps(Start_030:End_030);
Time_dat{3}=TestTime(Start_030:End_030)-TestTime(Start_030);
Temp_dat{3}=Temp(Start_030:End_030);
SOC_dat{3}=SOC(Start_030:End_030);

%40 percent SOC
Start_040=find(TestTime>=76267.89,1);
End_040=find(TestTime>=86405.53,1);
V_dat{4}=Volts(Start_040:End_040);
I_dat{4}=Amps(Start_040:End_040);
Time_dat{4}=TestTime(Start_040:End_040)-TestTime(Start_040);
Temp_dat{4}=Temp(Start_040:End_040);
SOC_dat{4}=SOC(Start_040:End_040);

%50 percent SOC
Start_050=find(TestTime>=65206.69,1);
End_050=find(TestTime>=73963.99,1);
V_dat{5}=Volts(Start_050:End_050);
I_dat{5}=Amps(Start_050:End_050);
Time_dat{5}=TestTime(Start_050:End_050)-TestTime(Start_050);
Temp_dat{5}=Temp(Start_050:End_050);
SOC_dat{5}=SOC(Start_050:End_050);

%60 percent SOC
Start_060=find(TestTime>=52767.29,1);
End_060=find(TestTime>=62443.39,1);
V_dat{6}=Volts(Start_060:End_060);
I_dat{6}=Amps(Start_060:End_060);
Time_dat{6}=TestTime(Start_060:End_060)-TestTime(Start_060);
Temp_dat{6}=Temp(Start_060:End_060);
SOC_dat{6}=SOC(Start_060:End_060);

%70 percent SOC
Start_070=find(TestTime>=41241.79,1);
End_070=find(TestTime>=50465.29,1);
V_dat{7}=Volts(Start_070:End_070);
I_dat{7}=Amps(Start_070:End_070);
Time_dat{7}=TestTime(Start_070:End_070)-TestTime(Start_070);
Temp_dat{7}=Temp(Start_070:End_070);
SOC_dat{7}=SOC(Start_070:End_070);

%80 percent SOC
Start_080=find(TestTime>=28801.49,1);
End_080=find(TestTime>=38818.83,1);
V_dat{8}=Volts(Start_080:End_080);
I_dat{8}=Amps(Start_080:End_080);
Time_dat{8}=TestTime(Start_080:End_080)-TestTime(Start_080);
Temp_dat{8}=Temp(Start_080:End_080);
SOC_dat{8}=SOC(Start_080:End_080);

%90 percent SOC
Start_090=find(TestTime>=17281.09,1);
End_090=find(TestTime>=26873.58,1);
V_dat{9}=Volts(Start_090:End_090);
I_dat{9}=Amps(Start_090:End_090);
Time_dat{9}=TestTime(Start_090:End_090)-TestTime(Start_090);
Temp_dat{9}=Temp(Start_090:End_090);
SOC_dat{9}=SOC(Start_090:End_090);

%100 percent SOC
Start_100=find(TestTime>=1700,1);
End_100=find(TestTime>=14514.39,1);
V_dat{10}=Volts(Start_100:End_100);
I_dat{10}=Amps(Start_100:End_100);
Time_dat{10}=TestTime(Start_100:End_100)-TestTime(Start_100);
Temp_dat{10}=Temp(Start_100:End_100);
SOC_dat{10}=SOC(Start_100:End_100);

%OCV Data
Start_OCV=find(TestTime>=131087.65,1);
End_OCV=find(TestTime>=148401.04,1);
V_OCV=Volts(Start_OCV:End_OCV);
SOC_OCV=SOC(Start_OCV:End_OCV);
V_OCV=[4.2 downsample(V_OCV',1000) 2.5];
SOC_OCV=[1 downsample(SOC_OCV,1000) 0];

%make data matrix 
clearvars -except V_dat V_OCV SOC_OCV I_dat Time_dat Temp_dat SOC_dat cell_cap
save('RCIDdata.mat')

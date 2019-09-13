function [pBCurrent, pCCurrent, BusCurrent] = read_w200( logfile ) 
%read_maccor Read in cell data from Maccor datalogs
% Outputs:
%	current		Timeseries - current measurement
%	voltage		Timeseries - voltage measurement 
%	step		Timeseries - test profile step number
%
%	Timeseries outputs are returned with relative time vectors (in
%	seconds). The TimeInfo.StartDate parameter is set to the "Date of Test"
%	parameter in the logfile, which may or may not be correct.
delimiter = ',';
startRow = 2;

formatSpec = '%{HH:mm:ss}D%s%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
fileID = fopen(logfile,'r');

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);

fclose(fileID);

Time = dataArray{:, 1};
Errors = dataArray{:, 2};
Limiters = dataArray{:, 3};
CurrentSP = dataArray{:, 4};
VelocitySP = dataArray{:, 5};
IdcSP = dataArray{:, 6};
miscSP = dataArray{:, 7};
BusVoltageV = dataArray{:, 8};
BusCurrentA = dataArray{:, 9};
Velocityms = dataArray{:, 10};
MotorRPM = dataArray{:, 11};
pCCurrentA = dataArray{:, 12};
pBCurrentA = dataArray{:, 13};
Odometerm = dataArray{:, 14};
BusChargeAh = dataArray{:, 15};
BEMFV = dataArray{:, 16};
VoutDV = dataArray{:, 17};
VoutQV = dataArray{:, 18};
IoutDA = dataArray{:, 19};
IoutQA = dataArray{:, 20};
VarName21 = dataArray{:, 21};
VarName22 = dataArray{:, 22};
VarName23 = dataArray{:, 23};
MotorTempC = dataArray{:, 24};
DSPTempC = dataArray{:, 25};
PhaseATempC = dataArray{:, 26};
PhaseBTempC = dataArray{:, 27};
PhaseCTempC = dataArray{:, 28};
CANTransErrs = dataArray{:, 29};
CANRecvErrs = dataArray{:, 30};
SlipSpeedHz = dataArray{:, 31};

sec = second(Time) + minute(Time)*60;
m = tabulate(sec);

i = find(m(:,2)> 1);
secmean = mean(m(i,2));
timediff = 1/secmean;

t = [0:timediff:timediff*(size(Time)-1)];
% Make timeseries
pBCurrent	= timeseries(pBCurrentA, t);
pBCurrent.DataInfo.Units		= 'Ampere RMS';
pBCurrent.Name                    = 'W200 Phase B Current';
pBCurrent.UserData                = logfile;

pCCurrent = timeseries(pCCurrentA, t);
pCCurrent.DataInfo.Units		= 'Ampere RMS';
pCCurrent.Name                  = 'W200 Phase C Current';
pCCurrent.UserData              = logfile;

BusCurrent	= timeseries(BusCurrentA, t);
BusCurrent.DataInfo.Units          = 'Ampere';
BusCurrent.Name                    = 'W200 BusCurrent';
BusCurrent.UserData                = logfile;

end
function [current, voltage, step] = read_maccor( logfile ) 
%read_maccor Read in cell data from Maccor datalogs
% Outputs:
%	current		Timeseries - current measurement
%	voltage		Timeseries - voltage measurement 
%	step		Timeseries - test profile step number
%
%	Timeseries outputs are returned with relative time vectors (in
%	seconds). The TimeInfo.StartDate parameter is set to the "Date of Test"
%	parameter in the logfile, which may or may not be correct.

% Read start date from file. We expect it is on the second line.
file = fopen(logfile);
StartDate = textscan( file, '%*s %s', 1, 'Delimiter', ',', 'HeaderLines',1);
StartDate = StartDate{1}{1};	% cell to string

% Read the rest of the file
% Header: Step,TestTime,StepTime,Amps,Volts,ACR
% ACR appears not to be present so we will ignore it
data = textscan( file, '%d %f %*f %f %f', 'Delimiter', ',', 'HeaderLines', 3);

fclose( file );

step = data{1};
time = data{2};
curr = data{3};
volt = data{4};

% Make timeseries
current	= timeseries(curr, time);
current.TimeInfo.StartDate	= StartDate;
current.DataInfo.Units		= 'Ampere';
current.Name				= 'Cell current';
current.UserData			= logfile;

voltage	= timeseries(volt, time);
voltage.TimeInfo.StartDate	= StartDate;
voltage.DataInfo.Units		= 'Volt';
voltage.Name				= 'Cell voltage';
voltage.UserData			= logfile;

step	= timeseries(curr, time);
step.TimeInfo.StartDate		= StartDate;
step.DataInfo.Units			= '';
step.Name					= 'Maccor step number';
step.UserData				= logfile;

end
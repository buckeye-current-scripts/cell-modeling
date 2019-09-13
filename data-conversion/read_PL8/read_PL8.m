function [TestData, CellData] = read_PL8( logfile )
%read_pl8 Read logfile data from Cellpro PowerLab 8 log files
	
	file = fopen( logfile );
	
	% Header: 
	%1	DateTime		SlaveNum	Cycle			Mode			SupplyVolts		
	%6	LSupplyVolts	SupplyAmps	PWM				SecTimer		AvgCellVolts	\
	%11 MaxCellVolts	AvgIR		FallBackVolts	CVStarted		SlowAmps		\
	%16 AvgAmps			FastAmps	SetAmpsAhrIN	AhrOUT			PackVolts		\
	%21 AvgPackVolts	Fuel1		SumError		Cell1Volts		Cell2Volts		\
	%26 Cell3Volts		Cell4Volts	Cell5Volts		Cell6Volts		Cell7Volts		\
	%31 Cell8Volts		Cell9Volts	Cell10Volts		Cell11Volts		Cell12Volts		\
	%36 Cell13Volts		Cell14Volts	Cell15Volts		Cell16Volts		Cell1IR			\
	%41 Cell2IR			Cell3IR		Cell4IR			Cell5IR			Cell6IR			\
	%46 Cell7IR			Cell8IR		Cell9IR			Cell10IR		Cell11IR		\
	%51 Cell12IR		Cell13IR	Cell14IR		Cell15I			Cell16IR		\
	%56 BP1PWM			BP2PWM		BP3PWM			BP4PWM			BP5PWM			\
	%61 BP6PWM			BP7PWM		BP8PWM			BP9PWM			BP10PWM			\
	%66 BP11PWM			BP12PWM		BP13PWM			BP14PWM			BP15PWM			\
	%71 BP16PWM			Debug1		Debug2			Debug3
	
	format = [ ...
		'%s %*d %*d %*d %*f '	...	%  1 DateTime
		'%*f %*f %*d %*d %*f '	...	%  6
		'%*f %*f %*f %*s %*f '	... % 11
		'%*f %f %*f %f %*f '	...	% 16 FastAmps,AhrOUT
		'%*f %*f %*f %f %f '	...	% 21 Cell1Volts, Cell2Volts
		'%f %f %f %f %f '		...	% 26 Cell[3-7]Volts
		'%f %*f %*f %*f %*f '	... % 31 Cell8Volts
		'%*f %*f %*f %*f %*f '	... % 36
		'%*f %*f %*f %*f %*f '	... % 41
		'%*f %*f %*f %*f %*f '	... % 46
		'%*f %*f %*f %*f %*f '	...	% 51
		'%*f %*f %*f %*f %*f '	... % 56
		'%*f %*f %*f %*f %*f '	... % 61
		'%*f %*f %*f %*f %*f '	... % 66
		'%*f %*f %*f %*f %*f'	... % 71
		];
	
	data = textscan( file, format, 'Delimiter', '\t', 'HeaderLines', 1 );

	DateTime	= data{1};
	FastAmps	= data{2};		% This might be unreliable?
	AhrOUT		= data{3};
	Cell1Volts	= data{4};
	Cell2Volts	= data{5};
	Cell3Volts	= data{6};
	Cell4Volts	= data{7};
	Cell5Volts	= data{8};
	Cell6Volts	= data{9};
	Cell7Volts	= data{10};
	Cell8Volts	= data{11};
	
	% Converting date strings to date numbers makes timeseries work much
	% faster
	StartDate	= DateTime(1);
	StartDate	= StartDate{1};
	dateFormat	= 'mm/dd/yyyy HH:MM:SS AM';
	DateTime	= (datenum(DateTime, dateFormat) - datenum(StartDate)) * 3600 * 24;
	
	% Make timeseries
	current = timeseries( FastAmps, DateTime );
	current.DataInfo.Units		= 'Ampere';
	current.TimeInfo.StartDate	= StartDate;
	current.Name				= 'Cell current';
	current.UserData			= logfile;
	
	capacity = timeseries( AhrOUT, DateTime );
	capacity.DataInfo.Units		= 'Ampere hour';
	capacity.TimeInfo.StartDate	= StartDate;
	capacity.Name				= 'Capacity discharged';
	capacity.UserData			= logfile;
	
	% TODO: parse and map cell number files
	Cell1 = timeseries( Cell1Volts, DateTime );
	Cell1.DataInfo.Units		= 'Volt';
	Cell1.TimeInfo.StartDate	= StartDate;
	Cell1.Name					= 'Cell 1 voltage';
	Cell1.UserData				= logfile;
	
	Cell2 = timeseries( Cell2Volts, DateTime );
	Cell2.DataInfo.Units		= 'Volt';
	Cell2.TimeInfo.StartDate	= StartDate;
	Cell2.Name					= 'Cell 2 voltage';
	Cell2.UserData				= logfile;
	
	Cell3 = timeseries( Cell3Volts, DateTime );
	Cell3.DataInfo.Units		= 'Volt';
	Cell3.TimeInfo.StartDate	= StartDate;
	Cell3.Name					= 'Cell 3 voltage';
	Cell3.UserData				= logfile;
	
	Cell4 = timeseries( Cell4Volts, DateTime );
	Cell4.DataInfo.Units		= 'Volt';
	Cell4.TimeInfo.StartDate	= StartDate;
	Cell4.Name					= 'Cell 4 voltage';
	Cell4.UserData				= logfile;

	Cell5 = timeseries( Cell5Volts, DateTime );
	Cell5.DataInfo.Units		= 'Volt';
	Cell5.TimeInfo.StartDate	= StartDate;
	Cell5.Name					= 'Cell 5 voltage';
	Cell5.UserData				= logfile;
	
	Cell6 = timeseries( Cell6Volts, DateTime );
	Cell6.DataInfo.Units		= 'Volt';
	Cell6.TimeInfo.StartDate	= StartDate;
	Cell6.Name					= 'Cell 6 voltage';
	Cell6.UserData				= logfile;
	
	Cell7 = timeseries( Cell7Volts, DateTime );
	Cell7.DataInfo.Units		= 'Volt';
	Cell7.TimeInfo.StartDate	= StartDate;
	Cell7.Name					= 'Cell 7 voltage';
	Cell7.UserData				= logfile;
	
	Cell8 = timeseries( Cell8Volts, DateTime );
	Cell8.DataInfo.Units		= 'Volt';
	Cell8.TimeInfo.StartDate	= StartDate;
	Cell8.Name					= 'Cell 8 voltage';
	Cell8.UserData				= logfile;
	
	% debug
	CellData			= { Cell1 Cell2 Cell3 Cell4 Cell5 Cell6 Cell7 Cell8 };
	TestData.Current	= current;
	TestData.Capacity	= capacity;

end
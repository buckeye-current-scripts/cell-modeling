clear variables; clc; close all; close all hidden;
[filename,pathname] = uigetfile('*.lvm','Select data file','MultiSelect','on');
fullname = fullfile(pathname,filename);

% Clean up if only one file is selected, figment from multiselect
if isfloat(filename)
    error('No files selected');
end

% if ischar(filename)
%     filename = {filename}; % convert char string to cellstr
%     fullname = {fullname};
% end
if ischar(fullname)
    fullname = {fullname};
    filename = {filename};
end

% Color Matrix
colors = [[0, 0.4470    0.7410]; [0.8500    0.3250    0.0980];...
        [0.9290    0.6940    0.1250];[0.4940    0.1840    0.5560]; ...
          [0.4660    0.6740    0.1880]; [0.3010    0.7450    0.9330]; ...
          [0.6350    0.0780    0.1840]; [0.25, 0.25, 0.25]; ...
          [0.75, 0.75, 0]; [0.75, 0, 0.75]];
color_index = 1;

set(figure,'numbertitle','off', 'color', 'w');
title('Cell Comparison');
index = 1;
legend_name = {};
while isfloat(filename)==false
    
    
    fid = fopen(string(fullname));
    data = textscan(fid,'%f%f%f%f%*f %*f%*f%*f%*f%*f %*f%*f%*f%*f%*f %*f%*f%*f%*f%f %*f%*f');
    fclose(fid);
    Time = data{1};         % Time
    Voltage = data{2};      % Voltage
    Current = data{3};      % Current
    Temp = data{4};         % Temperature
    job_num = data{5};      % Current Job Number
    
    % Find discharge period
    index_end = length(job_num);
    for i = 1:length(job_num)-1
        if job_num(i) ~= 11 && job_num(i+1) == 11
            index_dch = i+1;
        elseif job_num(i+1) ~= 11 && job_num(i) == 11
            index_end = i;
        end
    end
    
    
    
    % Adjust data to discharge
    Time = Time(index_dch:index_end);
    Time = Time - Time(1);
    Voltage = Voltage(index_dch:index_end);
    Current = Current(index_dch:index_end);
    Temp = Temp(index_dch:index_end);
    job_num = job_num(index_dch:index_end);
    
    % Downsample 
    sample_rate = 10;
    Time = downsample(Time,sample_rate);
    Voltage = downsample(Voltage,sample_rate);
    Current = downsample(Current,sample_rate);
    Temp = downsample(Temp,sample_rate);
    job_num = downsample(job_num,sample_rate);
    
    
    % Plotting
    cell_name = string(input('What Cell? >>> '));
    legend_name{index} = cell_name;
    index = index+1;
    
    hold on;
    yyaxis left;
    plot(Time, Voltage, 'LineWidth', 1.5, 'color', colors(color_index,:), 'linestyle', '-');
    ylabel('Voltage (V)');

    
    yyaxis right;
    plot(Time, Temp, 'LineWidth', 1, 'color', colors(color_index,:), 'linestyle', '--');
    ylabel('Temperatue (°C)');
    xlabel('Time (s)');
%     xlim([0 max(Time)]);
    legend(legend_name,'Location','northeast');
    
    
    color_index = color_index+1;
    
    
    [filename,pathname] = uigetfile('*.lvm','Select data file','MultiSelect','on');
    fullname = fullfile(pathname,filename);
    
    % Clean up if only one file is selected, figment from multiselect
    if isfloat(filename)
        error('No files selected');
    end
    
    % if ischar(filename)
    %     filename = {filename}; % convert char string to cellstr
    %     fullname = {fullname};
    % end
    if ischar(fullname)
        fullname = {fullname};
        filename = {filename};
    end
    
    
end



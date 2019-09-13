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
colors = ['b','r','g','k','m','c','y'];

figure();
for file = 1:length(filename)
    
    
    fid = fopen(string(fullname(file)));
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
    fprintf('\n%d',length(Time));
    
    
%     Plot Characterization for individual
    

    hold on;
    yyaxis left;
    plot(Time, Voltage, 'LineWidth', 2, 'color', colors(file), 'linestyle', '-');
    title('Voltage');
    ylabel('V');
    legend(strcat('Min:   ', string(min(Voltage)), 'V'), 'Location', 'southwest');
    str = filename(file);
    str = strrep(str, '_', ' ');
    title(str);
    
    
    yyaxis right;
    plot(Time, Temp, 'LineWidth', 2, 'color', colors(file), 'linestyle', '--');
    ylabel('°C');
    legend(strcat('Max:   ', string(max(Temp)), '°C'), 'Location', 'northwest');
    xlim([0 max(Time)]);
    
end



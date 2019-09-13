clear variables; clc; close all; close all hidden;
[filename,pathname] = uigetfile('*.txt','Select data file','MultiSelect','off');
fullname = fullfile(pathname,filename);

% Clean up if only one file is selected, figment from multiselect
if isfloat(filename)
    error('No files selected');
end

if ischar(fullname)
    fullname = {fullname};
    filename = {filename};
end

set(figure,'numbertitle','off', 'color', 'w');
set(gca,'xdir', 'reverse');
title('Capacity (Amp Hr) vs Voltage (V)');
xlabel('Capacity (Amp Hr)');
ylabel('Voltage (V)');
hold on;
colors = [[0, 0.4470    0.7410]; [0.8500    0.3250    0.0980]; [0.9290    0.6940    0.1250]];
color_index = 1;
while isfloat(filename)==false
    
    fid = fopen(string(fullname));
    data = textscan(fid,'%f%f%f%f%f %f%f%f%f%f %*f%*f%*f%*f%*f %*f%*f%*f%*f%*f %*f%*f%*f%*f%*f %*f%*f%*f%*f%*f %*f%*f%*f%*f%*f %*f%*f%*f%*f%*f', 'Headerlines', 3);
    fclose(fid);
    test.step.data = data{1}.';
    test.time.data = data{2}.';
    test.ampHr.data = data{4}.';
    test.ampHr.data = 3 - test.ampHr.data;
    test.current.data = data{6}.';
    test.voltage.data = data{7}.';
    
    % Find discharge at different C-rates
    cRate_count = 1;
    cRate_cond = 0;
    for index = 1:length(test.current.data)-1
        if test.current.data(index+1) < 0 && cRate_count == 1 && cRate_cond == 0
            index_1amp_head = index;
            cRate_cond = 1;
        elseif test.current.data(index+1) >= 0 && cRate_count == 1 && cRate_cond ~= 0
            index_1amp_end = index;
            cRate_cond = 0;
            cRate_count = 2;
        elseif test.current.data(index+1) < 0 && cRate_count == 2 && cRate_cond == 0
            index_20amp_head = index;
            cRate_cond = 1;
        elseif test.current.data(index+1) >= 0 && cRate_count == 2 && cRate_cond ~= 0
            index_20amp_end = index;
            cRate_cond = 0;
        end
    end
    
    % Discharge for different C-rates
    test.voltage.amp1 = test.voltage.data(index_1amp_head:index_1amp_end);
    test.voltage.amp20 = test.voltage.data(index_20amp_head:index_20amp_end);
    
    test.current.amp1 = test.current.data(index_1amp_head:index_1amp_end);
    test.current.amp20 = test.current.data(index_20amp_head:index_20amp_end);
    
    test.ampHr.amp1 = test.ampHr.data(index_1amp_head:index_1amp_end);
    test.ampHr.amp20 = test.ampHr.data(index_20amp_head:index_20amp_end);
    
    % Plot
    xlim([0 max(test.ampHr.amp1)]);
    plot(test.ampHr.amp1,test.voltage.amp1,test.ampHr.amp20,test.voltage.amp20,'LineWidth', 1.5, 'color', colors(color_index,:));
%     legend(strrep(strrep(strcat(string(filename),' 1 amp'),'_',' '),'.txt',''), strrep(strrep(strcat(string(filename),' 20 amp'),'_',' '),'.txt',''));
    color_index = color_index + 1;
    
    
    % Select next file
    [filename,pathname] = uigetfile('.txt','Select data file','MultiSelect','off');
    fullname = fullfile(pathname,filename);
    
    % Clean up if only one file is selected, figment from multiselect
    if isfloat(filename)
        error('No files selected');
    end
    
    if ischar(fullname)
        fullname = {fullname};
        filename = {filename};
    end
    

end

% legend('Samsung 30Q', 'Samsung 30Q', 'Efest 3Ah', 'Efest 3Ah', 'LG HG2', 'LG HG2');

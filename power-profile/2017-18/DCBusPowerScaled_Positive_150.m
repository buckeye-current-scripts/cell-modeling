clc; clear; close all; close all hidden;
% DC Bus Power Scaled

PPICH = load('PPIHC2017_RW3x2_RaceData_allVarStruct_raceOnly.mat');
time = PPICH.data.time;
time(1) = 0;
power = PPICH.data.DC_Powernone1;


% Import Data File
test_name = 'PPIHC_18650HG2_P0_2';


fid = fopen(strcat('/Users/krisliu/Documents/OSU/Buckeye Current/', ... 
    '2017-2018/Cell Testing/Power Profile/Test Data/PPIHC 150% Insulation/', ... 
    strcat(test_name, '.txt'))); 
    % Change Directory Location when importing
    
    
data_test = textscan(fid,'%f%f%*f%*f%*f%f%f%f','Headerlines',3);
fclose(fid);
test_step = data_test{1};
test_time = data_test{2};
test_i = data_test{3};
test_v = data_test{4};
test_temp = data_test{5};
% test_temp = test_temp(test_step == 4);
% test_i = test_i(test_step==4);
% test_time = test_time(test_step==4);
% test_v  = test_v(test_step==4);
test_p = test_i .* test_v;
% 
% % Convert time to Discharge Step
% for i = 1:length(test_time)
%     test_time2(i) = test_time(i) - test_time(1);
% end

% Plot Characterization
title_name = strcat(test_name,' Characterization');
set(figure,'name',title_name,'numbertitle','off', 'color', 'w');
hold on;
yyaxis left;
plot(test_time, -test_p, 'LineWidth', 1.5);
plot(test_time, test_temp, '-r', 'LineWidth', 2);

yyaxis right;
plot(test_time, test_v, 'LineWidth', 1.5);
legend('Power', 'Temperture', 'Voltage');
hold off;

ax1 = subplot(4,1,1);
plot(test_time, -test_p, 'LineWidth', 1);
title('Power');
ylabel('Watts');

ax2 = subplot(4,1,2);
plot(test_time, test_temp, 'LineWidth', 2);
title('Temperature');
ylabel('°C');

ax3 = subplot(4,1,3);
plot(test_time, test_v, 'LineWidth', 2);
title('Voltage');
ylabel('V');

ax4 = subplot(4,1,4);
plot(test_time, test_i, 'LineWidth', 2);
title('Current');
xlabel('Time(s)');
ylabel('Amp');
linkaxes([ax1, ax2, ax3, ax4], 'x');

fprintf('\nThe Max Power is %.4f Watts.', max(-test_p));
fprintf('\nThe Max Temperature is %.4f °C.', max(test_temp));
fprintf('\nThe Min Voltage is %.4f Volts.', min(test_v));
fprintf('\nThe Max current is %.4f Amps.', max(-test_i));




% Change negative value to 0
for i = 1:length(power)
    if power(i) < 0
        power(i) = 0;
    end
end

powerScaled = power;



% Sack 1 Rescale
factor = 120000 / max(power(5801:5900));
for i = 5801:5900
    powerScaled(i) = powerScaled(i) * factor;
end

% Sack 2 Rescale
factor = 120000 / max(power(5901:6000));
for i = 5901:6000
    powerScaled(i) = powerScaled(i) * factor;
end

% Sack 3 Rescale
factor = 120000 / max(power(6001:6150));
for i = 6001:6150
    powerScaled(i) = powerScaled(i) * factor;
end

% Sack 4 Rescale
factor = 120000 / max(power(6151:6420));
for i = 6151:6420
    powerScaled(i) = powerScaled(i) * factor;
end

% Sack 5 Rescale
factor = 120000 / max(power(6421:6630));
for i = 6421:6630
    powerScaled(i) = powerScaled(i) * factor;
end

% Power Plot
% set(figure,'name','DC Bus Power Scaled','numbertitle','off')
% plot(time, powerScaled, time, power, 'LineWidth', 1.5);
% title('DC Bus Power Rescale');
% xlabel('Time [s]');
% ylabel('Power [W]');

% Data for individual cell
num_cell = [1420, 1420, 1460, 1420, 994, 938, 938, 938, 938];
num_string = [142, 142, 146, 142, 142, 134, 134, 134, 134];
num_parallel = [10, 10, 10, 10, 7, 7, 7, 7, 7];
vol_cell = [3.7, 3.635, 3.7, 3.6, 3.62, 3.6, 3.7, 3.7, 3.2, 3.3];

% Power for Individual Cell 
for i = 1:length(num_cell)
    for j = 1:6630
        power_cell(j,i) = powerScaled(j) / num_cell(i);
    end
end

power_cell = power_cell.*1.5;


% Current for Individual Cell
for i = 1:length(num_cell)
    for j = 1:6630
        i_cell(j,i) = power_cell(j,i) / vol_cell(i);
    end
end


% Total Current
for i = 1:length(num_cell)
    for j = 1:6630
        i_total(j,i) = i_cell(j,i) * num_parallel(i);
    end
end

% NCR18650GA - Panasonic & INR18650MH1 - LG Chem & IMR18650 - Efest
power_cell1(:,2) = power_cell(:,1);
power_cell1(:,1) = time;
i_cell1 = i_cell(:,1);
i_cell1total = i_total(:,1);

% INR18650MJ1 - LG Chem
power_cell2(:,2) = power_cell(:,2);
power_cell2(:,1) = time;
i_cell2 = i_cell(:,2);
i_cell2total = i_total(:,2);

% 18650HG2 - LG Chem
power_cell3(:,2) = power_cell(:,3);
power_cell3(:,1) = time;
i_cell3 = i_cell(:,3);
i_cell3total = i_total(:,3);

% 18650MG1 - LG Chem
power_cell4(:,2) = power_cell(:,4);
power_cell4(:,1) = time;
i_cell4 = i_cell(:,4);
i_cell4total = i_total(:,4);

% NCR20700B	- Panasonic
power_cell5(:,2) = power_cell(:,5);
power_cell5(:,1) = time;
i_cell5 = i_cell(:,5);
i_cell5total = i_total(:,5);

% NCR26650A - Panasonic
power_cell6(:,2) = power_cell(:,6);
power_cell6(:,1) = time;
i_cell6 = i_cell(:,6);
i_cell6total = i_total(:,6);

% IMR26650 - Efest
power_cell7(:,2) = power_cell(:,7);
power_cell7(:,1) = time;
i_cell7 = i_cell(:,7);
i_cell7total = i_total(:,7);

% LFP26650P - K2 Energy & LFP26650EV - K2 Energy
power_cell8(:,2) = power_cell(:,8);
power_cell8(:,1) = time;
i_cell8 = i_cell(:,8);
i_cell8total = i_total(:,8);

% A123
power_cell9(:,2) = power_cell(:,9);
power_cell9(:,1) = time;
i_cell9 = i_cell(:,9);
i_cell9total = i_total(:,9);

% Write CSV files
% csvwrite('P0_NCR18650GA_150p.csv',power_cell1);
% csvwrite('P0_INR18650MH1_150p.csv',power_cell1);
% csvwrite('P0_IMR18650_150p.csv',power_cell1);
% csvwrite('P0_INR18650MJ1_150p.csv',power_cell2);
% csvwrite('P0_18650HG2_150p.csv',power_cell3);
% csvwrite('P0_18650MG1_150p.csv',power_cell4);
% csvwrite('P0_NCR20700B_150p.csv',power_cell5);
% csvwrite('P0_NCR26650A_150p.csv',power_cell6);
% csvwrite('P0_IMR26650_150p.csv',power_cell7);
% csvwrite('P0_LFP26650P_150p.csv',power_cell8);
% csvwrite('P0_LFP26650EV_150p.csv',power_cell8);
csvwrite('P0_A123_150p.csv',power_cell9);

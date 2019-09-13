clc; clear; close all; close all hidden;
% DC Bus Power Scaled

PPICH = load('PPIHC2017_RW3x2_RaceData_allVarStruct_raceOnly.mat');
time = PPICH.data.time;
power = PPICH.data.DC_Powernone1;


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
set(figure,'name','DC Bus Power Scaled','numbertitle','off')
plot(time, powerScaled, time, power, 'LineWidth', 2);
title('DC Bus Power Rescale');
xlabel('Time [s]');
ylabel('Power [W]');

% Data for individual cell
num_cell = [1420, 1420, 1460, 1420, 994, 938, 938, 938];
num_string = [142, 142, 146, 142, 142, 134, 134, 134];
num_parallel = [10, 10, 10, 10, 7, 7, 7, 7];
vol_cell = [3.7, 3.635, 3.7, 3.6, 3.62, 3.6, 3.7, 3.7, 3.2];

% Power for Individual Cell 
for i = 1:length(num_cell)
    for j = 1:6630
        power_cell(j,i) = powerScaled(j) / num_cell(i);
    end
end


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

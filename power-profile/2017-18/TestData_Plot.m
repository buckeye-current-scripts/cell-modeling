clear all; clc; close all;

% Ask user to select folder
% Data_Location = uigetfile();
% if Data_Location == 0
% 	return;
% end
% load(Data_Location);

load('PPIHC_Cycle_Data.mat')

% names and percentages of all cycle types
Cyc={Cyc200_data, Cyc150_data, Cyc100_data};
Perc=[200, 150, 100];
% process all data to start at discharge portion and change cell names to
% something that makes sense
for k=1:length(Cyc)
    for j=1:length(Cyc{k})
        if (max(Cyc{k}(j).test_step) >= 5) %this is for cells charged first
            Cyc{k}(j).test_temp = Cyc{k}(j).test_temp(Cyc{k}(j).test_step >= 4);
            Cyc{k}(j).test_i = Cyc{k}(j).test_i(Cyc{k}(j).test_step>=4);
            Cyc{k}(j).test_time = Cyc{k}(j).test_time(Cyc{k}(j).test_step>=4);
            Cyc{k}(j).test_v  = Cyc{k}(j).test_v(Cyc{k}(j).test_step>=4);
            Cyc{k}(j).test_p = Cyc{k}(j).test_i .* Cyc{k}(j).test_v;
        else %this is for cells that were just discharged
            Cyc{k}(j).test_temp = Cyc{k}(j).test_temp(Cyc{k}(j).test_step >= 2);
            Cyc{k}(j).test_i = Cyc{k}(j).test_i(Cyc{k}(j).test_step>=2);
            Cyc{k}(j).test_time = Cyc{k}(j).test_time(Cyc{k}(j).test_step>=2);
            Cyc{k}(j).test_v  = Cyc{k}(j).test_v(Cyc{k}(j).test_step>=2);
            Cyc{k}(j).test_p = Cyc{k}(j).test_i .* Cyc{k}(j).test_v;
        end
        % Convert time to Discharge Step
        for i = 2:length(Cyc{k}(j).test_time)
            Cyc{k}(j).test_time(i) = Cyc{k}(j).test_time(i) - Cyc{k}(j).test_time(1);
        end
        
        %Convert cell name to actual cell name
        if isempty(strfind(Cyc{k}(j).cell_name, '18650HG2'))==0
            Cyc{k}(j).cell_name='LG HG2 18650';
        elseif isempty(strfind(Cyc{k}(j).cell_name, '18650MG1'))==0
            Cyc{k}(j).cell_name= 'LG MG1 18650';
        elseif isempty(strfind(Cyc{k}(j).cell_name, 'IMR18650_'))==0
            Cyc{k}(j).cell_name= 'Efest IMR 18650';
        elseif isempty(strfind(Cyc{k}(j).cell_name, 'IMR26650_'))==0
            Cyc{k}(j).cell_name= 'Efest IMR 26650';
        elseif isempty(strfind(Cyc{k}(j).cell_name, 'INR18650MH1'))==0
            Cyc{k}(j).cell_name= 'LG INR-MH1 18650';
        elseif isempty(strfind(Cyc{k}(j).cell_name, 'INR18650MJ1'))==0
            Cyc{k}(j).cell_name= 'LG INR-MJ1 18650';
        elseif isempty(strfind(Cyc{k}(j).cell_name, 'LFP26650EV'))==0
            Cyc{k}(j).cell_name= 'K2 LFP-EV 26650';
        elseif isempty(strfind(Cyc{k}(j).cell_name, 'LFP26650P'))==0
            Cyc{k}(j).cell_name= 'K2 LFP-P 26650';
        elseif isempty(strfind(Cyc{k}(j).cell_name, 'NCR18650GA'))==0
            Cyc{k}(j).cell_name= 'Sanyo NCR-GA 18650';
        elseif isempty(strfind(Cyc{k}(j).cell_name, 'NCR20700B'))==0
            Cyc{k}(j).cell_name= 'Sanyo NCR-B 20700';
        elseif isempty(strfind(Cyc{k}(j).cell_name, 'NCR26650A'))==0
            Cyc{k}(j).cell_name= 'Panasonic NCR-A 26650';
        elseif isempty(strfind(Cyc{k}(j).cell_name, 'A123'))==0
            Cyc{k}(j).cell_name= '2017 A123 26650';
        end
        
    end
end


% make a plot of each cycle percentage voltage and temperature
for k=1:length(Cyc)
    figure('color', 'w', 'units','normalized', 'outerposition',[0 0 1 1], 'name', strcat(num2str(Perc(k)),'% Cycle Discharge'));
    hold on; grid on; set(gca, 'fontsize', 14);
    col=lines(15);
    for i=1:length(Cyc{k})
        pv=Cyc{k}(i);
        yyaxis left;
        plot(pv.test_time, pv.test_temp, '-', 'LineWidth', 1.5, 'color', col(i,:));
        yyaxis right;
        plot(pv.test_time, pv.test_v, '-', 'LineWidth', 1.5, 'color', col(i,:));
    end
    xlabel('Time [s]'); xlim([0,700]);
    title(strcat(num2str(Perc(k)),'% Cycle Discharge'));
    yyaxis left; ylabel('Temperature [C]'); ylim([20, 65])
    yyaxis right; ylabel('Voltage [V]'); ylim([1.5, 4.5])
    legend(Cyc{k}.cell_name, 'location', 'southeast');
end

% make a plot of each different cell cycled at 150 and 200 percent voltage and temperature
for i=1:length(Cyc{1}) %loop through 200% data
    pv=Cyc{1}(i);
    figure('color', 'w', 'units','normalized', 'outerposition',[0 0 1 1], 'name', pv.cell_name);
    hold on; grid on; set(gca, 'fontsize', 14);
    col=lines(15);
    yyaxis left;
    plot(pv.test_time, pv.test_temp, '-', 'LineWidth', 1.5, 'color', col(1,:));
    yyaxis right;
    plot(pv.test_time, pv.test_v, '-', 'LineWidth', 1.5, 'color', col(1,:));
    
    %find matching 150% data
    for j=1:length(Cyc{2})
        pv_200=Cyc{2}(j);
        if strcmpi(pv.cell_name,pv_200.cell_name)
            yyaxis left;
            plot(pv_200.test_time, pv_200.test_temp, '-', 'LineWidth', 1.5, 'color', col(3,:));
            yyaxis right;
            plot(pv_200.test_time, pv_200.test_v, '-', 'LineWidth', 1.5, 'color', col(3,:));
        end
    end
    
    %find matching 100% data
    for j=1:length(Cyc{3})
        pv_100=Cyc{3}(j);
        if strcmpi(pv.cell_name,pv_100.cell_name)
            yyaxis left;
            plot(pv_100.test_time, pv_100.test_temp, '-', 'LineWidth', 1.5, 'color', col(2,:));
            yyaxis right;
            plot(pv_100.test_time, pv_100.test_v, '-', 'LineWidth', 1.5, 'color', col(2,:));
        end
    end
 
    xlabel('Time [s]'); xlim([0,700]);
    title(pv.cell_name);
    yyaxis left; ylabel('Temperature [C]'); ylim([20, 65])
    yyaxis right; ylabel('Voltage [V]'); ylim([1.5, 4.5])
    legend('200%', '150%', '100%', 'location', 'southeast');
end

for k=1:length(Cyc)
    for j=1:length(Cyc{k})
        vals.integ(j,k)=trapz(Cyc{k}(j).test_p(1:4000));
        vals.cellv{j,k}=Cyc{k}(j).cell_name;
    end
end


clear all;
%close all;
warning off;
clc; format compact;

%% Load Experimental Data (this is currently made by the script parse_dat.m)
load RCIDdata.mat;


% this for loop cycles through all of the different individual segmented current profiles in the parsed data, 
% which are segmented by SOC. note that you chan remove the loop and just
% feed it an individual profile if you'd like 
for i=1:length(I_dat) 
    t_data = Time_dat{i}; % Time stamp array
    I_data = -I_dat{i}; % Current (input) signal
    V_data = V_dat{i}; % Experimental voltage (output) signal
    Tc_data = Temp_dat{i};% Cell temperature
    Ta_data = 25*ones(length(Temp_dat{i}),1);% Ambient temperature
    
    %Plots current profile, voltage data, temperature data for chosen plot
    figure('color','white')
    ax1 = subplot(311);
    plot(t_data,I_data, 'linewidth', 2);
    set(gca, 'fontsize', 16);
    hold on
    grid on
    set(gca,'xticklabel',[])
    ylabel('Current [A]')
    ax2 = subplot(312);
    plot(t_data,V_data, 'linewidth', 2);
    set(gca, 'fontsize', 16);
    hold on
    grid on
    set(gca,'xticklabel',[])
    ylabel('Voltage [V]')
    ax3 = subplot(313);
    plot(t_data,Tc_data,'r', 'linewidth', 2);
    set(gca, 'fontsize', 16);
    hold on
    grid on
    plot(t_data,Ta_data,'b', 'linewidth', 2);
    legend('Cell','Ambient');
    xlabel('Time [s]')
    ylabel('Temperature [C]')
    linkaxes([ax1,ax2,ax3],'x')
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Load Parameters for Cell Model
    capacity=cell_cap; %capacity in Ah
    e0=V_OCV; % OCV profile
    s0=fliplr(SOC_OCV); %matching SOC profile
    initialSoC=interp1(e0,s0,V_data(1)); %calculate initial SOC, note that this is a shitty assumption and only works because the data we're feeding is for sure at 0A initially 
   
    
    % Initial Guess for Model Parameters
    R1 = 0.0025;     % RC Resistor 1
    C1 = 2000;      % RC Capacitor 1
    R2 = 0.0020;     % RC Resistor 2
    C2 = 1000;      % RC Capacitor 2
    r0 = 0.20;     % R0 Resistor
    
    % Put parameters in model form
    beta1 = 1/(R1*C1);
    gamma1 = 1/C1;
    beta2 = 1/(R2*C2);
    gamma2 = 1/C2;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Initialize Simulink Model
    Tend = t_data(end); % Set simulation end time
    sim('CellModel_secOrd',[Tend]); %simulate second order model

    %plot model results before tuning 
    figure('color','white');
    %SOC
    ax1 = subplot(211);
    set(gca, 'fontsize', 16);
    hold on
    grid on
    plot(t_data, I_data, 'linewidth', 2);
    plot(t_sim, current, 'linewidth', 2);
    xlabel('Time [s]');
    ylabel('Current [-]');
    %Voltage
    ax2 = subplot(212);
    plot(t_sim,voltage(:,1), 'linewidth', 2);
    set(gca, 'fontsize', 16);
    hold on
    grid on
    plot(t_sim,voltage(:,2),'m:', 'linewidth', 2);
    xlabel('Time [s]');
    ylabel('Voltage [V]');
    legend('Data','Model');
    
    
    %% Simulate Model with Optimized parameters and Plot Results
    %define function to estimate parameters and optimize circuit components
    options = optimset('Display','iter', 'MaxIter', 100000); %display optimization steps
    opt_val=fminsearch(@errFun_multi, [r0, R1, C1, R2, C2], options) %optimize RMS error
    %reset model parameters to optimized values
    r0=opt_val(1);
    R1=opt_val(2);
    C1=opt_val(3);
    R2=opt_val(4);
    C2=opt_val(5);
    
    % Put parameters in model form
    beta1 = 1/(R1*C1);
    gamma1 = 1/C1;
    beta2 = 1/(R2*C2);
    gamma2 = 1/C2;
    Tend = t_data(end); % Set simulation end time
    %simulate model with new tuned parameters
    sim('CellModel_secOrd',[Tend]);

    %plot voltage predicted by model against corresponding experimental data
    figure('color','white');
    plot(t_sim,voltage(:,1), 'linewidth', 2);
    set(gca, 'fontsize', 16);
    hold on
    grid on
    plot(t_sim,voltage(:,2),'m:', 'linewidth', 2);
    xlabel('Time [s]');
    ylabel('Voltage [V]');
    legend('Data','Model');
    
    %plot point by point error
    figure('color','white');
    plot(t_sim,voltage(:,1)-voltage(:,2), 'linewidth', 2);
    set(gca, 'fontsize', 16);
    hold on
    grid on
    xlabel('Time [s]');
    ylabel('Error [V_{data}-V_{Model}]');
    
    %calculate RMS error
    errVolt = sqrt(sum((voltage(:,1)-voltage(:,2)).^2)) %EF
    
end
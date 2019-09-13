close all; clear; clc;
format compact
warning('off')

%% Load Cell Data
load cell_data
fields = fieldnames(data);
n = length(data.(fields{1}));

%% Define Design Space
Vol_max = 75; % maximum pack volume [L]
for i = 1:n
    if strcmp(data.Format{i},'Pouch')
        Vol_mult(i,1) = 1.25;
    else
        Vol_mult(i,1) = 1.85; % was originally 200%, found we can save ~15% in cell spacing
    end
end   
V_range = 500:50:750; % nominal voltage range [V]
P_cont_range = 80:5:110; % min continuous power range [kW]
E_range = 25:30; % min energy range [kWh]

%% Iterate through Design Space
for i = 1:length(V_range)
    % Table initialization
    check = 0;
    Mfr_tf = {}; Model_tf = {}; Format_tf = {};
    Ns_tf = []; Np_tf = []; V_nom_tf = []; C_nom_tf = []; % Crate_tf = [];
    P_cont_tf = []; E_nom_tf = []; Vol_tf = []; m_cellOnly_tf = [];
    
    V_min = V_range(i);
    Ns(:,1) = ceil(V_min./data.NomVoltage);
    V_nom(:,1) = Ns.*data.NomVoltage;
    for j = 1:length(P_cont_range)
        check = 0;
        P_cont_min = P_cont_range(j);
        I = P_cont_min*1000/V_min;
        Np_I(:,1) = ceil(I./data.ContCurrent);        
        for k = 1:length(E_range)
            E_min = E_range(k);
            Np_E(:,1) = ceil(E_min*1000./V_nom./data.NomCapacity);
            Np = max(Np_I,Np_E);
            C_nom(:,1) = Np.*data.NomCapacity;
%             Crate(:,1) = I./C_nom;
            P_cont(:,1) = Np.*data.ContCurrent.*V_nom/1000;
            E_nom(:,1) = V_nom.*C_nom/1000;
            Vol(:,1) = Vol_mult.*Ns.*Np.*data.Volume;
            m_cellOnly(:,1) = Ns.*Np.*data.Mass;
            
            tf = Vol <= Vol_max;
            if any(tf) ~= false()
                Mfr_tf = [Mfr_tf;data.Mfr(tf)];
                Model_tf = [Model_tf;data.Model(tf)];
                Format_tf = [Format_tf;data.Format(tf)];
                Ns_tf = vertcat(Ns_tf,Ns(tf));
                Np_tf = vertcat(Np_tf,Np(tf));
                V_nom_tf = vertcat(V_nom_tf,V_nom(tf));
                C_nom_tf = vertcat(C_nom_tf,C_nom(tf));
%                 Crate_tf = vertcat(Crate_tf,Crate(tf));
                P_cont_tf = vertcat(P_cont_tf,P_cont(tf));
                E_nom_tf = vertcat(E_nom_tf,E_nom(tf));
                Vol_tf = vertcat(Vol_tf,Vol(tf));
                m_cellOnly_tf = vertcat(m_cellOnly_tf,m_cellOnly(tf));
                check = 1;
            end
        end
    end
    if check == 1
        T = table(Mfr_tf,Model_tf,Format_tf,Ns_tf,Np_tf,V_nom_tf,C_nom_tf,P_cont_tf,E_nom_tf,Vol_tf,m_cellOnly_tf); %Crate_tf
        T.Properties.VariableNames = {'Mfr','Model','Format','Ns','Np','V_nom_V','C_nom_Ah','P_cont_kW','E_nom_kWh','Vol_L','m_kg'}; % 'Crate_C'
        T = unique(T)

        date_str = date;
        filename = strcat('cell_opt_',date_str,'.xlsx');
        sheetname = num2str(V_min);
        writetable(T,filename,'FileType','spreadsheet','Sheet',sheetname)
    end
end

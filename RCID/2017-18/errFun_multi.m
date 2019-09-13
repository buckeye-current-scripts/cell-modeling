function [err] = errFun_multi(x) % Define Objective Function
load RCIDdata.mat;
i=evalin('base', 'i');
t_data = Time_dat{i}; % Time stamp array
I_data = -I_dat{i}; % Current (input) signal
V_data = V_dat{i}; % Experimental voltage (output) signal
Tc_data = Temp_dat{i};% Cell temperature
Ta_data = 25*ones(length(Temp_dat{i}),1);% Ambient temperature

capacity=cell_cap;
e0=V_OCV;
s0=fliplr(SOC_OCV);
SOC_calc=SOC_dat{i};
[e0_un ind_un] = unique(e0); 
initialSoC=interp1(e0_un,s0(ind_un),V_data(1)); %note that this is a shitty assumption and only works because the data we're feeding is for sure at 0A initially 
%initialSoC=SOC_calc(1);
    
Tend = t_data(end); % Set simulation end time

% Define model parameters to be optimized
r0=x(1);
R1=x(2);
C1=x(3);
R2=x(4);
C2=x(5);

% Put parameters in model form
beta1 = 1/(R1*C1);
gamma1 = 1/C1;
beta2 = 1/(R2*C2);
gamma2 = 1/C2;

% Simulate the Model
options = simset('SrcWorkspace','current'); % CRITICAL: set workspace for model I/O
sim('CellModel_secOrd',[Tend],options);
% Compute SSE on the output
err = sqrt(sum((voltage(:,1)-voltage(:,2)).^2)); %EF
end
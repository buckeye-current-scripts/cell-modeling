%%% 1st Order OTC from Samsung 30Q RCID
%%% Chris Liu

clc; clear variables; close all;

%% Load data
try
    [filename,pathname] = uigetfile('*.txt','Select data file','MultiSelect','off');
    fullname = fullfile(pathname,filename);
    fid = fopen(string(fullname));
    source_data = textscan(fid, '%f%f%f%f%f %f%f', 'Headerlines', 3);
    fclose(fid);
catch
    error('Error: No files selected');
end

%% RCID test data
step = source_data{1};
time = source_data{2};
stepTime = source_data{3};
ampHr = source_data{4};
wattHr = source_data{5};
amp = source_data{6};
volt = source_data{7};

%% Seperate data for different SOC's
startpoint = [9260, 245100, 272700, 291700, 310300, 328200, 351700, ...
    375300, 399200, 422800, 446200, 470000, 484000, 499400, 513400];

endpoint = [245100, 272700, 291700, 310300, 328200, 351700, 375300, ...
    399200, 422800, 446200, 470000, 484000, 499400, 513400, 528800];

for i = 1:15
    data{i}.step = step(startpoint(i):endpoint(i));
    data{i}.time = time(startpoint(i):endpoint(i));
    data{i}.stepTime = stepTime(startpoint(i):endpoint(i));
    data{i}.ampHr = ampHr(startpoint(i):endpoint(i));
    data{i}.wattHr = wattHr(startpoint(i):endpoint(i));
    data{i}.amp = amp(startpoint(i):endpoint(i));
    data{i}.volt = volt(startpoint(i):endpoint(i));
    
    if i == 1; data{1}.soc = 'initial';
    elseif ismember(i, 2:6); data{i}.soc = 100 - 5*(i-2);
    elseif ismember(i, 12:15); data{i}.soc = 5 + 5*(15-i);
    else data{i}.soc = 140 - 10*i;
    end
end

%% 1st Order OTC

% Curve Fit settings
fit_len = 200; % set relaxing length for more accurate OTC curve fit
ft = fittype('a-b*exp(-x/c)');
options = fitoptions(ft);
options.StartPoint = [2, 0, 1]; % V_oc(SOC), V_OTC, tau
options.Lower = [0, 0, 0];
options.Upper = [5, 5, 1e8];

OCV_vec = zeros(1,14);

for i = 2:15
    index_disch = 1;
    disch_start = 0;
    disch_time = 0;
    disch_num = 0;
    relax_start = 0;
    relax_end = 0;
    
    OCV_vec(i-1) = data{i}.volt(1);
    
    % 2-11, 100%-20% SOC's discharge pattern: -1A, -3A, -9A, -15A
    if ismember(i, 2:11) 
        index = 1;
        while index <= length(data{i}.time)-1
            index = index + 1;
            
            % Get first discharge point
            if (abs(data{i}.amp(index)+1)<=1e-1 || abs(data{i}.amp(index)+3)<=1e-1 ...
                    || abs(data{i}.amp(index)+9)<=1e-1 || abs(data{i}.amp(index)+15)<=1e-1)...
                    && abs(data{i}.amp(index-1))<=1e-1
                disch_start = index;
            end
            
            % Relax Curve
            if abs(data{i}.amp(index)) <= 1e-1 && (abs(data{i}.amp(index-1)+1)<=1e-1 || abs(data{i}.amp(index-1)+3)<=1e-1...
                     || abs(data{i}.amp(index-1)+9)<= 1e-1 || abs(data{i}.amp(index-1)+15)<=1e-1) ...
                     && relax_start == 0
                 
                % Set relax start point
                relax_start = index;
                
                % Calculate discharge time
                disch_time = data{i}.time(relax_start) - data{i}.time(disch_start);
                
                % Find relax end point
                for j = index:length(data{i}.time)-1
                    if abs(data{i}.amp(j+1)) >= 1e-1 || j == length(data{i}.time)-1
                        relax_end = j;
                        break
                    end
                end
                
                % Set index = relax end point
                index = relax_end;
                
                % Curve Fit for 1st order OTC
                data{i}.OTC(index_disch).time = data{i}.time(relax_start+1:relax_start+fit_len);
                data{i}.OTC(index_disch).time = data{i}.OTC(index_disch).time - data{i}.OTC(index_disch).time(1);
                data{i}.OTC(index_disch).volt = data{i}.volt(relax_start+1:relax_start+fit_len);
                data{i}.OTC(index_disch).amp = data{i}.amp(relax_start+1:relax_start+fit_len);
                
                f1 = fit(data{i}.OTC(index_disch).time, data{i}.OTC(index_disch).volt, ft, options);
                
                if abs(data{i}.amp(relax_start-1)+1)<=1e-1
                    r_OTC = f1.b/((1 - exp(-(disch_time)/f1.c))*1);
                    c_OTC = f1.c/r_OTC;
                elseif abs(data{i}.amp(relax_start-1)+3)<=1e-1
                    r_OTC = f1.b/((1 - exp(-(disch_time)/f1.c))*3);
                    c_OTC = f1.c/r_OTC;
                elseif abs(data{i}.amp(relax_start-1)+9)<=1e-1
                    r_OTC = f1.b/((1 - exp(-(disch_time)/f1.c))*9);
                    c_OTC = f1.c/r_OTC;
                elseif abs(data{i}.amp(relax_start-1)+15)<=1e-1
                    r_OTC = f1.b/((1 - exp(-(disch_time)/f1.c))*15);
                    c_OTC = f1.c/r_OTC;
                end
                
                % For quick fit check
%                 figure;
%                 plot(data{i}.OTC(index_disch).time,data{i}.OTC(index_disch).volt);
%                 hold on;
%                 plot(f1);
%                 hold off;
                
                % Save OTC characteristics
                data{i}.OTC(index_disch).r0 = abs((data{i}.volt(relax_start-1) - data{i}.volt(relax_start)) / data{i}.amp(relax_start-1));
                data{i}.OTC(index_disch).r_OTC = r_OTC;
                data{i}.OTC(index_disch).c_OTC = c_OTC;
                
                % Reset start and end points
                disch_start = 0;
                relax_start = 0;
                relax_end = 0;
                
                % Move to the next discharge
                index_disch = index_disch + 1;
            end
        end
        
    % 12-15, 20%-5% SOC's discharge pattern: -1A, -3A, -3A    
    else 
        index = 1;
        while index <= length(data{i}.time)-1
            index = index + 1;
            
            % Get first discharge point
            if (abs(data{i}.amp(index)+1)<=1e-1 || abs(data{i}.amp(index)+3)<=1e-1) ...
                    && abs(data{i}.amp(index-1))<=1e-1
                disch_start = index;
            end
            
            % Relax Curve
            if abs(data{i}.amp(index)) <= 1e-1 && (abs(data{i}.amp(index-1)+1)<=1e-1 || abs(data{i}.amp(index-1)+3)<=1e-1)...
                     && relax_start == 0
                 
                % Set relax start point
                relax_start = index;
                
                % Calculate discharge time
                disch_time = data{i}.time(relax_start) - data{i}.time(disch_start);
                
                % Find relax end point
                for j = index:length(data{i}.time)-1
                    if abs(data{i}.amp(j+1)) >= 1e-1 || j == length(data{i}.time)-1
                        relax_end = j;
                        break
                    end
                end
                
                % Set index = relax end point
                index = relax_end;
                
                % Curve Fit for 1st order OTC
                data{i}.OTC(index_disch).time = data{i}.time(relax_start+1:relax_start+fit_len);
                data{i}.OTC(index_disch).time = data{i}.OTC(index_disch).time - data{i}.OTC(index_disch).time(1);
                data{i}.OTC(index_disch).volt = data{i}.volt(relax_start+1:relax_start+fit_len);
                data{i}.OTC(index_disch).amp = data{i}.amp(relax_start+1:relax_start+fit_len);
                
                f1 = fit(data{i}.OTC(index_disch).time, data{i}.OTC(index_disch).volt, ft, options);
                
                
                if abs(data{i}.amp(relax_start-1)+1)<=1e-1
                    r_OTC = f1.b/((1 - exp(-(disch_time)/f1.c))*1);
                    c_OTC = f1.c/r_OTC;
                elseif abs(data{i}.amp(relax_start-1)+3)<=1e-1
                    r_OTC = f1.b/((1 - exp(-(disch_time)/f1.c))*3);
                    c_OTC = f1.c/r_OTC;
                end
                
                % For quick fit check
%                 figure;
%                 plot(data{i}.OTC(index_disch).time,data{i}.OTC(index_disch).volt);
%                 hold on;
%                 plot(f1);
%                 hold off;
                
                % Save OTC characteristics
                data{i}.OTC(index_disch).r0 = abs((data{i}.volt(relax_start-1) - data{i}.volt(relax_start)) / data{i}.amp(relax_start-1));
                data{i}.OTC(index_disch).r_OTC = r_OTC;
                data{i}.OTC(index_disch).c_OTC = c_OTC;
                
                % Reset start and end points
                disch_start = 0;
                relax_start = 0;
                relax_end = 0;
                
                % Move to the next discharge
                index_disch = index_disch + 1;
            end
        end
        
    end
end

%% Load r0,r_OTC,c_OTC at 100%-5% SOC after various discharge currents
for index_soc = 1:14
    soc_vec(index_soc) = data{index_soc+1}.soc;
    % 2nd discharge pattern at -1A, -3A, -9A, -15A (100%-20% SOC)
    if ismember(index_soc, 1:10) 
        for index_disch = 1:4
            OTC.r0{index_soc}.disch(index_disch) = data{index_soc+1}.OTC(index_disch).r0;
            OTC.r1{index_soc}.disch(index_disch) = data{index_soc+1}.OTC(index_disch).r_OTC;
            OTC.c1{index_soc}.disch(index_disch) = data{index_soc+1}.OTC(index_disch).c_OTC;
        end
        
    % 2nd discharge pattern at -1A, -3A, -3A (20%-5% SOC)
    else        
        OTC.r0{index_soc}.disch(1) = data{index_soc+1}.OTC(1).r0;
        OTC.r1{index_soc}.disch(1) = data{index_soc+1}.OTC(1).r_OTC;
        OTC.c1{index_soc}.disch(1) = data{index_soc+1}.OTC(1).c_OTC;
        
        % Average of repeated -3A discharge
        OTC.r0{index_soc}.disch(2) = (data{index_soc+1}.OTC(2).r0 + data{index_soc+1}.OTC(3).r0)/2;
        OTC.r1{index_soc}.disch(2) = (data{index_soc+1}.OTC(2).r_OTC + data{index_soc+1}.OTC(3).r_OTC)/2;
        OTC.c1{index_soc}.disch(2) = (data{index_soc+1}.OTC(2).c_OTC + data{index_soc+1}.OTC(3).c_OTC)/2;
    end
end

%% Plot
set(groot, 'defaultLineLinewidth', 1);
soc_i = linspace(min(soc_vec), max(soc_vec), 150); 
soc_i2 = linspace(min(soc_vec(1)), max(soc_vec(10)), 150); 

% Plot SOC vs OCV
figure;
ax = gca;
plot(soc_vec, OCV_vec, 'o');
hold on;

ax.ColorOrderIndex = 1;
OCV_vec_i = interp1(soc_vec, OCV_vec(1,:), soc_i, 'spline', 'extrap');
plot(soc_i, OCV_vec_i);
hold off;

xlabel('State of Charge (%)');
ylabel('Open Circuit Voltage (V)');
title('State of Charge (%) vs Open Circuit Voltage (V)');
set(gca, 'xdir','reverse');


% Plot SOC vs r0 after -1A, -3A discharge
r0_vec = zeros(4,14);
figure;
hold on;
for index_soc = 1:14
    if ismember(index_soc,1:10)
        for index_disch = 1:4
            r0_vec(index_disch,index_soc) = OTC.r0{index_soc}.disch(index_disch)*1000;
        end
    else
        for index_disch = 1:2
            r0_vec(index_disch,index_soc) = OTC.r0{index_soc}.disch(index_disch)*1000;
        end
    end
end 
r0_vec_1 = interp1(soc_vec, r0_vec(1,:), soc_i, 'spline', 'extrap');
r0_vec_3 = interp1(soc_vec, r0_vec(2,:), soc_i, 'spline', 'extrap');
r0_vec_9 = interp1(soc_vec(1:10), r0_vec(3,1:10), soc_i2, 'spline', 'extrap');
r0_vec_15 = interp1(soc_vec(1:10), r0_vec(4,1:10), soc_i2, 'spline', 'extrap');

plot(soc_vec, r0_vec(1,:), 'o', soc_vec, r0_vec(2,:), 'o');
plot(soc_vec(1:10), r0_vec(3,1:10), 'o', soc_vec(1:10), r0_vec(4,1:10), 'o');

ax = gca;
ax.ColorOrderIndex = 1;
plot(soc_i, r0_vec_1, soc_i, r0_vec_3, soc_i2, r0_vec_9, soc_i2, r0_vec_15);
hold off;

xlabel('State of Charge (%)');
ylabel('Ohmic Resistance (m?)');
title('State of Charge (%) vs Ohmic Resistance (m?)');
legend('1A Discharge', '3A Discharge', '9A Discharge', '15A Discharge');
set(gca, 'xdir','reverse');


% Plot SOC vs r1 after -1A, -3A, -9A, -15A discharge
r1_vec = zeros(4,14);
figure;
for index_soc = 1:14
    if ismember(index_soc,1:10)
        for index_disch = 1:4
            r1_vec(index_disch,index_soc) = OTC.r1{index_soc}.disch(index_disch)*1000;
        end
    else
        for index_disch = 1:2
            r1_vec(index_disch,index_soc) = OTC.r1{index_soc}.disch(index_disch)*1000;
        end
    end
end
hold on;
r1_vec_1 = interp1(soc_vec, r1_vec(1,:), soc_i, 'spline', 'extrap');
r1_vec_3 = interp1(soc_vec, r1_vec(2,:), soc_i, 'spline', 'extrap');
r1_vec_9 = interp1(soc_vec(1:10), r1_vec(3,1:10), soc_i2, 'spline', 'extrap');
r1_vec_15 = interp1(soc_vec(1:10), r1_vec(4,1:10), soc_i2, 'spline', 'extrap');

plot(soc_vec, r1_vec(1,:), 'o', soc_vec, r1_vec(2,:), 'o');
plot(soc_vec(1:10), r1_vec(3,1:10), 'o', soc_vec(1:10), r1_vec(4,1:10), 'o');

ax = gca;
ax.ColorOrderIndex = 1;
plot(soc_i, r1_vec_1, soc_i, r1_vec_3, soc_i2, r1_vec_9, soc_i2, r1_vec_15);

xlabel('State of Charge (%)');
ylabel('Dynamic Resistance Values (m?)');
title('State of Charge (%) vs Dynamic Resistance Values (m?)');
legend('1A Discharge', '3A Discharge', '9A Discharge', '15A Discharge');
set(gca, 'xdir','reverse');
set(gca, 'xdir','reverse');
hold off;


% Plot SOC vs c1 after -1A, -3A, -9A, -15A discharge
c1_vec = zeros(4,14);
figure;
for index_soc = 1:14
    if ismember(index_soc,1:10)
        for index_disch = 1:4
            c1_vec(index_disch,index_soc) = OTC.c1{index_soc}.disch(index_disch)/1000;
        end
    else
        for index_disch = 1:2
            c1_vec(index_disch,index_soc) = OTC.c1{index_soc}.disch(index_disch)/1000;
        end
    end
end
hold on;
soc_i2 = linspace(min(soc_vec(1)), max(soc_vec(10)), 150); 
c1_vec_1 = interp1(soc_vec, c1_vec(1,:), soc_i, 'spline', 'extrap');
c1_vec_3 = interp1(soc_vec, c1_vec(2,:), soc_i, 'spline', 'extrap');
c1_vec_9 = interp1(soc_vec(1:10), c1_vec(3,1:10), soc_i2, 'spline', 'extrap');
c1_vec_15 = interp1(soc_vec(1:10), c1_vec(4,1:10), soc_i2, 'spline', 'extrap');

plot(soc_vec, c1_vec(1,:), 'o', soc_vec, c1_vec(2,:), 'o');
plot(soc_vec(1:10), c1_vec(3,1:10), 'o', soc_vec(1:10), c1_vec(4,1:10), 'o');

ax = gca;
ax.ColorOrderIndex = 1;
plot(soc_i, c1_vec_1, soc_i, c1_vec_3, soc_i2, c1_vec_9, soc_i2, c1_vec_15);

xlabel('State of Charge (%)');
ylabel('Dynamic Capacitance Values (kF)');
title('State of Charge (%) vs Dynamic Capacitance Values (kF)');
legend('1A Discharge', '3A Discharge', '9A Discharge', '15A Discharge');
set(gca, 'xdir','reverse');
set(gca, 'xdir','reverse');
hold off;

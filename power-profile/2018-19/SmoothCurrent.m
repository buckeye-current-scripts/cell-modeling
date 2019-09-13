clc; clear variables; close all;

load('Current.mat');
load('Velocity.mat');
time = 0:0.1:length(Batt_Current)/10-0.1;

figure();
plot(Batt_Current, 'linewidth', 2);
hold on;
plot(Target_Velocity, 'linewidth', 2);
plot(Veh_Velocity, 'linewidth', 2);
legend('Current','Target','Actual');
hold off;

old = Batt_Current/15;
figure();
plot(time,Batt_Current/15, 'linewidth', 1.5);
xlabel('Time (s)');
ylabel('Discharge Current (A)');
title('Discharge Current Profile');
hold on;

% Smooth Current Data
for i = 1:length(Batt_Current)-1
    
    % Idea braking
    if Target_Velocity(i+1) < Target_Velocity(i)
        if Veh_Velocity(i) >= Target_Velocity(i)
            brake_start = i;
            
            
            % Find braking endpoint
            for j = brake_start:length(Batt_Current)-1
                if Target_Velocity(j+1) > Target_Velocity(j)
                    brake_end = j;
                    break;
                end
            end
            
            Batt_Current(i:j) = 0;
            
        end
    
    
    % Accelarating too fast
    elseif Target_Velocity(i+1) > Target_Velocity(i) && Veh_Velocity(i) >= Target_Velocity(i)
        
        for j = i:length(Batt_Current)-1
            if Veh_Velocity(j) < Target_Velocity(j)
                brake_end = j;
                break;
            end
        end
        
        Batt_Current(i:j) = (Batt_Current(i-1)+Batt_Current(j))/2;
    end

end


Cell_Current = Batt_Current/15;   % 13p for 20700
plot(time,Cell_Current, 'linewidth', 1.5);
legend('Original Cell Current', 'Smoothed Cell Current');
xlim([0 max(time)]);
% 
% diff_current = old-Cell_Current;
% plot(time,diff_current);

figure();
hold on;
axis auto
plot(Target_Velocity, 'linewidth', 2);
plot(Veh_Velocity, 'linewidth', 2);
legend('Target Velocity','Actual Velocity');
xlabel('Time (s)');
ylabel('Velocity (m/s)');
title('Isle of Man Ideal vs. Actual Velocity');

hold off;

figure();
plot(Cell_Current, 'linewidth', 2);
xlabel('Time (s)');
ylabel('Discharge Current (A)');
title('Discharge Current Profile');

profile18650(:,1) = 0:0.2:1042.4;
profile18650(:,2) = Cell_Current*1.5; %150%
profile18650_1hz = downsample(profile18650, 5);

% figure();
% plot(profile18650(:,1), profile18650(:,2));
% hold on;
% plot(profile18650_1hz(:,1), profile18650_1hz(:,2));
% hold off;

csvwrite('CurrentProfile_18650_1hz_15p_150percent.csv',profile18650_1hz);




close all; clear; clc;

% Load cell data spreadsheet
filename = 'cell_data_master.xlsx';
range = 'C2:S99';
[xls_num,xls_txt,xls_raw] = xlsread(filename,1,range);

fieldname = xls_txt(1,:)';

n_txt = 4;
for i = 1:length(fieldname)
    if i <= n_txt
        data.(fieldname{i}) = xls_txt(2:end,i);
    else
        data.(fieldname{i}) = xls_num(:,i-n_txt);
    end
end

N = length(data.(fieldname{1}));
for i = 1:N
    if strcmp(data.Format{i},'Pouch')
        data.Volume(i,1) = data.Length(i)*data.Width(i)*data.Thickness(i)*1e-6;
    else
        data.Volume(i,1) = pi*data.Diameter(i)^2/4*data.Height(i)*1e-6;
    end
end
data.VED = data.NomEnergy./data.Volume;
data.GED = data.NomEnergy./data.Mass;
data.VPD = data.ContPower./data.Volume;
data.GPD = data.ContPower./data.Mass;

data.date_made = date;

save('cell_data.mat','data')


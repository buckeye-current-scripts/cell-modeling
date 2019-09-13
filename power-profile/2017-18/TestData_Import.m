clear all; clc; close all; 

% Ask user to select folder
	fprintf('Select a folder');

topLevelFolder = uigetdir();
if topLevelFolder == 0
	return;
end

% Get list of subfolders in the selected folder
allSubFolders = genpath(topLevelFolder);

% Parse into a cell array.
remain = allSubFolders;
listOfFolderNames = {};
while true
	[singleSubFolder, remain] = strtok(remain, ';');
	if isempty(singleSubFolder)
		break;
	end
	listOfFolderNames = [listOfFolderNames singleSubFolder];
end
numberOfFolders = length(listOfFolderNames)

% start log of data parameters
Cyc200_data={};
Cyc150_data={};
Cyc100_data={};

% Process all text files in those folders.
for k = 1 : numberOfFolders
	% Get this folder and print it out.
	thisFolder = listOfFolderNames{k};
	fprintf('Processing folder %s\n', thisFolder);
	
	% Get filenames of all TXT files.
	filePattern = sprintf('%s/*.txt', thisFolder);
	baseFileNames = dir(filePattern);
	numberOfFiles = length(baseFileNames);
    
	if numberOfFiles >= 1
        % Go through all those text files.
        for f = 1 : numberOfFiles
            fullFileName = fullfile(thisFolder, baseFileNames(f).name);
            fprintf('     Processing text file %s\n', baseFileNames(f).name);
            fid = fopen(fullFileName);
            data_test = textscan(fid,'%f%f%*f%*f%*f%f%f%f','Headerlines',3);
            fclose(fid);
            if isempty(strfind(fullFileName, '100%'))==0;
                Cyc100_data(f).test_step = data_test{1};
                Cyc100_data(f).test_time = data_test{2};
                Cyc100_data(f).test_i = data_test{3};
                Cyc100_data(f).test_v = data_test{4};
                Cyc100_data(f).test_p = Cyc100_data(f).test_i.*Cyc100_data(f).test_v;
                Cyc100_data(f).test_temp = data_test{5};
                Cyc100_data(f).cell_name = baseFileNames(f).name;
            elseif isempty(strfind(fullFileName, '150%'))==0;
                Cyc150_data(f).test_step = data_test{1};
                Cyc150_data(f).test_time = data_test{2};
                Cyc150_data(f).test_i = data_test{3};
                Cyc150_data(f).test_v = data_test{4};
                Cyc150_data(f).test_p = Cyc150_data(f).test_i.*Cyc150_data(f).test_v;
                Cyc150_data(f).test_temp = data_test{5};
                Cyc150_data(f).cell_name = baseFileNames(f).name;
            elseif isempty(strfind(fullFileName, '200%'))==0
                Cyc200_data(f).test_step = data_test{1};
                Cyc200_data(f).test_time = data_test{2};
                Cyc200_data(f).test_i = data_test{3};
                Cyc200_data(f).test_v = data_test{4};
                Cyc200_data(f).test_p = Cyc200_data(f).test_i.*Cyc200_data(f).test_v;
                Cyc200_data(f).test_temp = data_test{5};
                Cyc200_data(f).cell_name = baseFileNames(f).name;
            end
		end
	else
		fprintf('     Folder %s has no text files in it.\n', thisFolder);
	end
end

%clear everything but the newly made variables
clearvars -except Cyc200_data Cyc150_data Cyc100_data
save('PPIHC_Cycle_Data');


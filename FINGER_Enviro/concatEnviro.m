function concatData = concatEnviro(username,subname,saveBool)
%concatEnviro
%
% concatEnviro concatenates the files from the environmental FINGER study
% into a structure.
%
% The concatData structure contains a single raw data array that is 
% 256_channels x nTimeSamples. It also contains an index array containing 
% the beginning indices for each sub-test. note: this function excludes
% resting state data from the final structure.
%
% Input: subname (identifier) as string, e.g. 'LASF', 
%        username as string, e.g. 'Sumner'


%% Load in subject .mat data file, timing data, and head model
setPathEnviro(username,subname);

%Read in .mat file
filename = celldir([subname '*.mat']);
for i = 1:2
    filename{i} = filename{i}(1:end-4);
    disp(['Loading ' filename{i} '...']);
    load(filename{i});
end

%% info regarding the experimental setup
%sampling rate
concatData.sr = samplingRate;   

%% concatenate data
eeg{1} = strcat(filename{1},'mff1');  eeg{5} = strcat(filename{2},'mff1');
eeg{2} = strcat(filename{1},'mff2');  eeg{6} = strcat(filename{2},'mff2');
eeg{3} = strcat(filename{1},'mff3');  eeg{7} = strcat(filename{2},'mff3');
eeg{4} = strcat(filename{1},'mff4');  %EEG sub-sessions

vid{1} = strcat(filename{1},'mff1Video_trigger');  
vid{2} = strcat(filename{1},'mff2Video_trigger');  
vid{3} = strcat(filename{1},'mff3Video_trigger');  
vid{4} = strcat(filename{1},'mff4Video_trigger'); 
vid{5} = strcat(filename{2},'mff1Video_trigger');
vid{6} = strcat(filename{2},'mff2Video_trigger');
vid{7} = strcat(filename{2},'mff3Video_trigger');

for i = 1:length(eeg)   % replacing spaces with underscores
    eeg{i} = strrep(eeg{i},' ','_');
    vid{i} = strrep(vid{i},' ','_');
end

%concatData.eeg = eval(['[' eeg{2} ' ' eeg{3} ' ' eeg{4} ' ' eeg{5} ' ' eeg{6} ' ' eeg{7} '];']);
%concatData.vid = eval(['[' vid{2} ' ' vid{3} ' ' vid{4} ' ' vid{5} ' ' vid{6} ' ' vid{7} '];']);
for i = 2:length(eeg)
    concatData.eeg{i-1} = eval([eeg{i} ';']);
    concatData.vid{i-1} = eval([vid{i} ';']);
end

%% save concatenated data
if saveBool
    disp('Saving concatenated data...');
    save(strcat(subname,'_concatData'),'concatData');
    disp('Done.');
else
    disp('Warning: Data not saved to disk; must pass directly');
end

end

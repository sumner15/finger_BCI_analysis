function [concatData] = concatTherapy(username,subname)
%SegFingerTherapy
%
% Segments FINGER therapy data into a sample by channel by trial array
%
% Input: subname (identifier) as string, e.g. 'LASF', 
%        username ast string, e.g. 'Sumner'


%% Load in data

% change path to user home
setPathTherapy(username,subname);
cd('raw data');

% Read in .mat file
filename = celldir([subname '*.mat']);
filePre = filename{1}(1:end-4);
disp(['Loading ' filePre '...']);
load(filePre);  % pre-exam
filePost = filename{2}(1:end-4);
disp(['Loading ' filePost '...']);
load(filePost); % post-exam

% load the EGI head model
% load egihc256redhm;
% concatData.hm = EGIHC256RED;
% number of eeg channels in the headmodel
% nChans = length(EGIHC256RED.ChansUsed); 

%% info regarding the experimental setup
concatData.sr = samplingRate;

%% Saving out sampling rate and EEG DATA
concatData.sr = samplingRate; 
filePre  = strrep(filePre,' ','_');
filePost = strrep(filePost,' ','_');
concatData.eeg{1} = eval([filePre  '2']);
concatData.eeg{2} = eval([filePre  '3']);
concatData.eeg{3} = eval([filePost '2']);
concatData.eeg{4} = eval([filePost '3']);

%% Marker data for FINGER Game
concatData.vid{1} = eval([filePre  '2Video_trigger']);
concatData.vid{2} = eval([filePre  '3Video_trigger']);
concatData.vid{3} = eval([filePost '2Video_trigger']);
concatData.vid{4} = eval([filePost '3Video_trigger']);

%% filtering data
% disp('Filtering the data...');
% eeg1 = filtereeg(eeg1(EGIHC256RED.ChansUsed,:)',sr);

%% save concatenated data
fprintf('Saving concatenated data...');
cd ..; 
save(strcat(subname,'_concatData'),'concatData');
fprintf('Done.\n');

end

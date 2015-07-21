function [concatData] = concatTherapy(username,subname,saveBool)
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

%% %%%%%%%%%%%%%%% EXCEPTIONS (MANUAL ENTRIES) %%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(subname,'LOUW')
    disp('warning: LOUW OVERRIDE!!!!');
    concatData.eeg{1} = eval([filePre  '3']);
    concatData.eeg{2} = eval([filePre  '4']);
    concatData.eeg{3} = eval([filePost '3']);
    concatData.eeg{4} = eval([filePost '4']);
    concatData.vid{1} = eval([filePre  '3Video_trigger']);
    concatData.vid{2} = eval([filePre  '4Video_trigger']);
    concatData.vid{3} = eval([filePost '3Video_trigger']);
    concatData.vid{4} = eval([filePost '4Video_trigger']);
end
if strcmp(subname,'MALJ')
    disp('warning: MALJ OVERRIDE!!!!');    
    concatData.eeg{2} = eval([filePost '3']);    
    concatData.vid{2} = eval([filePost '3Video_trigger']);    
    disp('Speed test is POST ONLY! (pre missing)');
    concatData.warning = 'Speed test is POST ONLY! (pre missing)';
end
if strcmp(subname,'MCCL')
    disp('warning: MCCL OVERRIDE!!!!');    
    concatData.eeg{4} = eval([filePre '3']);    
    concatData.vid{4} = eval([filePre '3Video_trigger']);    
    disp('Speed test is PRE ONLY! (post missing)');
    concatData.warning = 'Speed test is PRE ONLY! (post missing)';
end 

%% save concatenated data
if saveBool
    fprintf('Saving concatenated data...');
    cd ..; 
    concatData.params.preProcess = false;
    save(strcat(subname,'_concatData'),'concatData');
    fprintf('Done.\n');
else
    disp('warning: data not saved, must pass directly');
end

end

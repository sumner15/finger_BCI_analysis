function concatData = screenDataEnviro(username, subname,concatData)
% wrapper function for artscreen to screen the environmental data set
% also functions as wrapper for ica review
%
% Input: 
% subname as string (e.g. 'NORS')
% 
% concat data as structure containing .eeg, 1x6 cell containing 256 x time
% sample array of data
%
% uses subjects concatData file where concatData is a structure containing
% concatData.sr (sampling rate) and concatData.eeg (the signal) where:
% signal = array of signals as vectors (channel x samples)
%
%
% Outputs: 
% concatData is saved out again, now containing a clean version of 
% concatData.eeg and also concatData.motorEEG where:
% motorEEG = (channel x sample) 2D array of time domain data of motor
% channels only.

%% checks
if ~exist('subname','var')  || ~exist('username','var')
    error('username and subname must be defined');
end

%% %% loading data 
setPathEnviro(username,subname)

% read in .mat file
if ~exist('concatData','var')
    filename = celldir([subname '*concatData.mat']);
    filename{1} = filename{1}(1:end-4);

    fprintf(['Loading ' filename{1} '...']);
    load(filename{1});  
    fprintf('Done.\n');
end

% read in note timing
cd ..
load note_timing_Blackbird.mat
setPathEnviro(username,subname);

%% options
trialTime = 3000;    %ms
nChans = size(concatData.eeg{1},1);             %starts at 256 -> 194 (hm)
trialSpan = ceil(trialTime/1000*concatData.sr); %n samples in trial

% common vars
nSongs = length(concatData.eeg);
if nSongs ~= 6; error('wrong number of exams'); end; %check data size
load egihc256redhm; 
screenIn.hm = EGIHC256RED;
screenIn.sr = concatData.sr;

%% Create marker spike trains
markerInds = cell(1,nSongs);
marker =     cell(1,nSongs);

for song = 1:nSongs
    %start index of time sample marking beginning of trial (from labjack)
    startInd = find(abs(concatData.vid{song})>1000, 1 );
    %markerInds is an integer array of marker indices (for all trials)
    markerInds{song} = startInd+round(blackBird);
end

%% breaking into trials
%initializing cell array to be filled
screenIn.data = cell(1,nSongs);    
% nSamples = zeros(1,nSongs); nTrials = zeros(1,nSongs);
nTrials = length(blackBird);
for song = 1:nSongs    
    %{song}(sample, channel, trial) -- initializing
    screenIn.eeg{song} = zeros(trialSpan,nChans,nTrials);
end

%segmenting data
for song = 1:nSongs
   fprintf('\\\\%i//',song)   
   for trial = 1:nTrials       
       %sample index of trial               
       sampleSpan = (1:trialSpan)+markerInds{song}(trial);
       %screenIn:  {song}(sample, channel, trial)
       screenIn.eeg{song}(:,:,trial) = ...     
            concatData.eeg{song}(1:nChans,sampleSpan)';             
   end
end
fprintf('\n');

%% using art screen
for song = 1:nSongs
    fprintf('\\\\%i//\n',song);
    
    %adjusting number of channels / making sure head model is correct
    if size(screenIn.eeg{song},2)==length(screenIn.hm.ChansUsed)
        screenIn.data = screenIn.eeg{song};
    elseif size(screenIn.eeg{song},2)>=256
        screenIn.data = screenIn.eeg{song}(:,screenIn.hm.ChansUsed,:);    
    end
    
    %skip AV only conds
    if song == 1 || song == 6 
        dataOut = screenIn;
    else
    %% actual screening performed here!! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        dataOut = artscreen(screenIn);
        dataOut = icasegdata(dataOut);
        dataOut = icareview(dataOut);
        dataOut = icatochan(dataOut);
    end
    
    % reshaping output (flattening trials)
    % IMPORTANT: All eeg values are set to zero if they are outside the
    % trial epoch periods defined. This typically only defines about 10% of
    % the data set. However, all baseline periods or other data analysis
    % must analyze within epoch periods from this point forward. 
    for trial = 1:nTrials
       %sample index of trial
       sampleSpan = (1:trialTime) + markerInds{song}(trial);
       %saving trial into its time slot in flat data array (chan x sample)
       flatData(:,sampleSpan) = squeeze(dataOut.data(:,:,trial))';
    end
    % concatData is filled here and changes size depending on HM!!!
    concatData.eeg{song} = flatData; 
    concatData.hm = EGIHC256RED;        
end
%% modifying for new hm & saving motor channels separately 
if size(screenIn.eeg{song},2)==length(screenIn.hm.ChansUsed)
    %oldMotorChans = concatData.motorChans; %[81 90  101 119 131 130 129 128 143 142]
    oldMotorChans = [81 90  101 119 131 130 129 128 143 142];
    [~,concatData.motorChans] = ismember(oldMotorChans,concatData.hm.ChansUsed);

    for song = 1:nSongs
        clear concatData.motorEEG
        concatData.motorEEG{song} = concatData.eeg{song}(concatData.motorChans,:);    
    end
end

%% save concatenated data
concatData.params.screened = true; %marking the data as cleaned
fprintf('Saving pre-processed data...');
save(strcat(subname,'_concatData'),'concatData');
fprintf('Done.\n');

end
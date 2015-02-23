function subData = segFingerOscillate(subData)
%
% Segments FINGER oscillation study data into a 
% {test number}(trial x chn x time) cell array of segmented data
%
% Input: subData as structure including .eeg{1 x nExams}(chan x sample)
%                                       .sr as double 


%% loading data 
%Read in note/trial timing data when ready

%% info regarding the experimental setup
nExams = length(subData.eeg);           % number of recordings
sr = subData.sr;                        % sampling rate
nChans = size(subData.eeg{1},1);        % number of active channels

subData.trialLength = 20;                       % length of oscillation (sec)
subData.breakLength = 8;                        % length of inter-trial break(sec)
subData.introLength = 5;                        % length of introduction (sec)
subData.nTrials = 6;                            % number of trials per exam

%% Create marker spike train
markerTimes = zeros(1,subData.nTrials); % beginning of trial in seconds
for trial = 1:subData.nTrials
    markerTimes(trial) = (trial-1)*(subData.trialLength+subData.breakLength)+subData.introLength;
end
markerInds = markerTimes*sr;    % beginning of trial in samples 

%% Initialize data structure components
for examNo = 1:nExams  
    %structure:    {exam}          (trial x chn x trial-time)
    subData.segEEG{examNo} = zeros(subData.nTrials,nChans,sr*subData.trialLength);
end

%% Segment EEG data
for examNo = 1:nExams
    fprintf('\n Exam Number %i / %i \n',examNo,nExams);    
    for trialNo = 1:subData.nTrials
        fprintf('- %2i ',trialNo);
        %time indices that the current trial spans
        timeSpan = markerInds(trialNo):markerInds(trialNo)+sr*subData.trialLength-1;
        %filling segment into segEEG
        subData.segEEG{examNo}(trialNo,:,:) = subData.eeg{examNo}(:,timeSpan);
    end
    fprintf('\n');
end
end

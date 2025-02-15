function data = segFingerOscillate(data,saveBool,username,subname)
%
% Segments FINGER oscillation study data into a 
% {test number}(trial x chn x time) cell array of segmented data
%
% Input: data as structure including .eeg{1 x nExams}(chan x sample)
%                                       .sr as double 

disp('--- SEGMENTING ---');

%% info regarding the experimental setup
nExams = length(data.eeg);           % number of recordings
sr = data.sr;                        % sampling rate

data.trialLength = 20;               % length of oscillation (sec)
data.breakLength = 8;                % length of inter-trial break(sec)
data.introLength = 5;                % length of introduction (sec)
data.nTrials = 6;                    % number of trials per exam
data.epochLength = 1;                % length of epochs (sec)

badChans = 15; %used for PASK (PO8 bad connection)

%% zero-ing bad channels
for examNo = 1:nExams
   data.eeg{examNo}(badChans,:) = 0;   
end

%% Create marker spike train
markerTimes = zeros(1,data.nTrials); % beginning of trial in seconds
for trial = 1:data.nTrials
    markerTimes(trial) = (trial-1)*(data.trialLength+data.breakLength)+data.introLength;
end
markerInds = markerTimes*sr;            % beginning of trial in samples 

%% Segment EEG data
for examNo = 1:nExams
    fprintf('Exam Number %i / %i \n',examNo,nExams);    
    for trialNo = 1:data.nTrials
        fprintf('- %2i ',trialNo);
        
        %time indices that the current trial and following break spans
        timeSpan = markerInds(trialNo) : markerInds(trialNo)+sr*data.trialLength-1;
        timeSpanBreak = timeSpan(end)+1 : timeSpan(end)+sr*data.breakLength;
        
        %filling segment into segEEG
        %structure:         {exam}  (epoch x chn x trial-time)
             data.segEEG{examNo}(trialNo, :, :) = data.eeg{examNo}(:,timeSpan);
        data.segEEGBreak{examNo}(trialNo, :, :) = data.eeg{examNo}(:,timeSpanBreak);        
    end
    fprintf('\n');
end
data.params.segmented = true;

%% saving data if requested
if saveBool    
    concatData = data; clear data
    fprintf('Saving segmented data...');
    setPathOscillate(username,subname);
    save(strcat(subname,'_concatData'),'concatData','-v7.3');
    data = concatData; clear concatData
    fprintf('Done.\n');
else
    disp('warning: data not saved, must pass directly');
end

end %function

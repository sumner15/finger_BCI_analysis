function subData = segFingerOscillate(subData)
%
% Segments FINGER oscillation study data into a 
% {test number}(trial x chn x time) cell array of segmented data
%
% Input: subData as structure including .eeg{1 x nExams}(chan x sample)
%                                       .sr as double 

%% info regarding the experimental setup
nExams = length(subData.eeg);           % number of recordings
sr = subData.sr;                        % sampling rate

subData.trialLength = 20;               % length of oscillation (sec)
subData.breakLength = 8;                % length of inter-trial break(sec)
subData.introLength = 5;                % length of introduction (sec)
subData.nTrials = 6;                    % number of trials per exam

badChans = 15; %used for PASK (PO8 bad connection)

%% zero-ing bad channels
for examNo = 1:nExams
   subData.eeg{examNo}(badChans,:) = 0;   
end

%% Create marker spike train
markerTimes = zeros(1,subData.nTrials); % beginning of trial in seconds
for trial = 1:subData.nTrials
    markerTimes(trial) = (trial-1)*(subData.trialLength+subData.breakLength)+subData.introLength;
end
markerInds = markerTimes*sr;            % beginning of trial in samples 

%% Segment EEG data
for examNo = 1:nExams
    fprintf('\n Exam Number %i / %i \n',examNo,nExams);    
    for trialNo = 1:subData.nTrials
        fprintf('- %2i ',trialNo);
        
        %time indices that the current trial and following break spans
        timeSpan = markerInds(trialNo) : markerInds(trialNo)+sr*subData.trialLength-1;
        timeSpanBreak = timeSpan(end)+1 : timeSpan(end)+sr*subData.breakLength;
        
        %filling segment into segEEG
        %structure:         {exam}  (trial x chn x trial-time)
             subData.segEEG{examNo}(trialNo, :, :) = subData.eeg{examNo}(:,timeSpan);
        subData.segEEGBreak{examNo}(trialNo, :, :) = subData.eeg{examNo}(:,timeSpanBreak);
        
    end
    fprintf('\n');
end

end %function

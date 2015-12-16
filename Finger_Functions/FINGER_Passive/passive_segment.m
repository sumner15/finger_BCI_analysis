function segData = passive_segment(data)
% this function segments the data from the unimpaired phase 1 data set 
% taken in 12/2015. It does this by looking for changes in the state vars
% such as target (color of queues on screen) and the robot positions
% themselves. There are two primary phases: preparation and movement. 
% This function will output a segData structure that contains segmented
% eeg for the preparation and movement phases of each trial, separately.

%% setting experimental vars
preRunTime = 2;                     % sec (PreRunDuration in BCI2000)
preRunLength = preRunTime*data.sr;  % samples 
runTime = 3;                        % sec (FeedbackDuration in BCI2000)
runLength = runTime*data.sr;        % samples
nConds = length(data.eeg); 
nChans = data.bciPrm.SourceCh.NumericValue;

%% creating the resulting structure segData, 
% segData is a a cell array of 3D double arrays.
% format: segData{condition}(trial,channel,sample)
segData.prep = cell(1,nConds);
segData.move = cell(1,nConds);
for cond = 1:nConds
    % finds the index of every change in target 
    trialStartInds = find(diff(data.target{cond})~=0);
    % number of trials for this condition (different for each)
    nTrials = length(trialStartInds);
    % initializing segData
    segData.prep{cond} = zeros(nChans,preRunLength,nTrials);
    segData.move{cond} = zeros(nChans,runLength,nTrials);
    
    for trial = 1:nTrials
        prepInds = trialStartInds:(trialStartInds+preRunLength-1);
        moveInds = (prepInds(end)+1):(prepInds(end)+runLength);
        segData.prep{cond}(:,:,trial) = data.eeg{cond}(:,prepInds);
        segData.move{cond}(:,:,trial) = data.eeg{cond}(:,moveInds);
    end    
end   
    
end
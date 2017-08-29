% Uses the result of 'datToMat', a data structure, to calculate the
% force traces for every trial in phase 3.
% 
% takes in dataIn, the raw data from the datToMat function, the session
% number (e.g. 07), and the target (e.g. 1-yellow or 2-blue)
%
% takes in 
function [traces, otherFinger, individuation] = ...
    getForceTrace(dataIn, session, target, finger)

% default to yellow target
if ~exist('target','var')
    target = 1;
    warning('assuming you wanted yellow square results')
end

% default to index finger
if ~exist('finger','var')
    finger = 1;
    warning('assuming you wanted the index finger results')
end

%% get data into continuous format
[f1a, f1b, f2a, f2b, pos1, pos2, ...
 moveTarget, EEGTarget, ~, ~, result, nTrials, goInds] = ...
    getContinuousData(dataIn);

tau1 = -1.55*f1a - 2.82*f1b + 7.87;
tau2 = -1.55*f2a - 2.82*f2b + 7.87;

% we will assume the target was always the one we wanted  during phase 1,  
% or if not specified, in order to include all of the movement trials
if session<= 3 || ~exist('target','var')
    target = 1;
    EEGTarget = target*ones(size(EEGTarget));
    result = ones(size(result));
%     warning('including all trials (not filtering by EEG target)')
end

%% get movement traces
samplesInTrace = 400;
[traces, otherFinger, individuation] = deal(NaN(nTrials,samplesInTrace));

for trial = 1:nTrials   
    % find sample 0 and final sample indices & extract movement data
    sample0 = goInds(trial);
    sampleF = min(sample0+samplesInTrace-1,goInds(trial+1)); 
    
    tauStart1 = tau1(sample0);
    tauStart2 = tau2(sample0);   

    tauDiff1 = smooth(tau1(sample0:sampleF)-tauStart1);
    tauDiff2 = smooth(tau2(sample0:sampleF)-tauStart2);    
    
    posStart1 = pos1(sample0);
    posStart2 = pos2(sample0);   

    posDiff1 = smooth(abs(pos1(sample0:sampleF)-posStart1));
    posDiff2 = smooth(abs(pos2(sample0:sampleF)-posStart2));
    
    % was this the EEG target we wanted? The Finger target we wanted?
    targetWanted = (EEGTarget(goInds(trial))==target);
    fingerWanted = (moveTarget(goInds(trial))==finger);
    % did the person succeed in moving? 
    successful = max(result(sample0:sampleF));    
    % don't look at last movement if the trial ended early (fringe case)
    successful = successful * (sample0+samplesInTrace-1 < length(result));   
    successful = true * (sample0+samplesInTrace-1 < length(result));   
    % don't look at falsely triggered movements
    if max(posDiff1(1:100))>50 || max(posDiff2(1:100))>50
        successful = 0;
    end
    
%     if successful ~= 0 && targetWanted && fingerWanted       
    if successful ~= 0 && fingerWanted       
        switch finger
            case 1
                traces(trial,:) = tauDiff1';   
                otherFinger(trial,:) = tauDiff2';
                individuation(trial,:) = ...
                    transpose(tauDiff1-tauDiff2);
%                     transpose((tauDiff1-tauDiff2)./(tauDiff1+tauDiff2));
            case 2 
                traces(trial,:) = tauDiff2'; 
                otherFinger(trial,:) = tauDiff1';
                individuation(trial,:) = ...
                    transpose(tauDiff2-tauDiff1);
%                     transpose((tauDiff2-tauDiff1)./(tauDiff1+tauDiff2));
            case 3
                traces(trial,:) = tauDiff1';
                otherFinger(trial,:) = tauDiff2';
                individuation(trial,:) = ...
                    transpose(tauDiff1-tauDiff2);
%                     transpose((tauDiff1-tauDiff2)./(tauDiff1+tauDiff2));
        end                             
    end
end

end
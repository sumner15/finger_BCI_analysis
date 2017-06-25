%Uses the result of 'datToMat', a data structure, to calculate the latency
%on each trial. 
% takes in dataIn, the raw data from the datToMat function, the session
% number (e.g. 07), and the target (e.g. 1-yellow or 2-blue)
% returns latency, a vector of latency values, one for each trial during
% the session.
function [latency, maxP, latMaxP, maxV, latMaxV] = ...
                                getLatency(dataIn, session, target, finger)

% phase 2 has no latency results
if session >= 4 && session <=9
    [latency, maxP, latMaxP, maxV, latMaxV] = deal(NaN);
    return
end

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
[~, ~, ~, ~, pos1, pos2, moveTarget, EEGTarget,...
    ~, t, result, nTrials, goInds] = getContinuousData(dataIn);

% we will assume the target was always the one we wanted  during phase 1 
% in order to include all of the movement trials
if session<= 3
    EEGTarget = target*ones(size(EEGTarget));
end

%% compute latency 
samplesInTrace = 400;
[latency, maxP, latMaxP, maxV, latMaxV] = deal(NaN(nTrials,1));

for trial = 1:nTrials   
    % find sample 0 and final sample indices & extract movement data
    sample0 = goInds(trial);
    sampleF = min(sample0+samplesInTrace-1,goInds(trial+1)); 
    
    posStart1 = pos1(sample0);
    posStart2 = pos2(sample0);   

    posDiff1 = smooth(abs(pos1(sample0:sampleF)-posStart1));
    posDiff2 = smooth(abs(pos2(sample0:sampleF)-posStart2));
    
    v1 = [0; posDiff1(2:end)-posDiff1(1:end-1)];
    v2 = [0; posDiff2(2:end)-posDiff2(1:end-1)];
    
    % was this the EEG target we wanted? The Finger target we wanted?
    targetWanted = (EEGTarget(goInds(trial))==target);
    fingerWanted = (moveTarget(goInds(trial))==finger);
    % did the person succeed in moving? 
    successful = max(result(sample0:sampleF));    
    % don't look at last movement if the trial ended early (fringe case)
    successful = successful * (sample0+samplesInTrace-1 < length(result));   
    % don't look at falsely triggered movements
    if max(posDiff1(1:100))>50 || max(posDiff2(1:100))>50
        successful = 0;
    end
    % did we get an errant value?     
    if max(posDiff1)>1000 || max(posDiff1)>1000
        successful = 0;
    end 
    
    if successful ~= 0 && targetWanted && fingerWanted
        % record the maximum change in position for this trial
        switch finger
            case 1
                [maxP(trial), latMaxP(trial)] = max(abs(posDiff1));
                [maxV(trial), latMaxV(trial)] = max(abs(v1));
            case 2
                [maxP(trial), latMaxP(trial)] = max(abs(posDiff2));
                [maxV(trial), latMaxV(trial)] = max(abs(v2));
            case 3
                [maxP(trial), latMaxP(trial)] = ...
                    max([max(abs(posDiff1)) max(abs(posDiff2))]);
                [maxV1, latMaxV1(1)] = max(abs(v1));
                [maxV2, latMaxV1(2)] = max(abs(v2));
                [maxV(trial), fingerMaxed] = max([maxV1 maxV2]);
                latMaxV(trial) = latMaxV1(fingerMaxed);
        end
        
        % count samples until movement occurred 
        samplesElapsed = 1;
        moved = false;
        while moved == false
            samplesElapsed = samplesElapsed+1;
            % if movement passed a threshold 
            if (finger==1 && posDiff1(samplesElapsed) > 50) || ...
               (finger==2 && posDiff2(samplesElapsed) > 50) || ...
               (finger==3 && posDiff1(samplesElapsed) > 50) || ...
               (finger==3 && posDiff2(samplesElapsed) > 50)
                                
                % calculate difference in time
                tMove = t(sample0+samplesElapsed);
                t0 = t(goInds(trial));    
                latency(trial) = tMove-t0;
                % set exit flag
                moved = true;
            end
        end                        
    end
end
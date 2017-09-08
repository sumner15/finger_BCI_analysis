%Uses the result of 'datToMat', a data structure, to calculate the latency
%on each trial. 
% takes in dataIn, the raw data from the datToMat function, the session
% number (e.g. 07), and the target (e.g. 1-yellow or 2-blue)
% returns latency, a vector of latency values, one for each trial during
% the session.
function [latency, maxP, latMaxP, maxV, latMaxV, maxT, minT, latMaxT] = ...
                                getLatency(dataIn, session, target, finger)

% phase 2 has no latency results
if session >= 4 && session <=9
    [latency, maxP, latMaxP, maxV, latMaxV, maxT, minT, latMaxT] = ...
        deal(NaN);
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
[f1a, f1b, f2a, f2b, pos1, pos2, moveTarget, EEGTarget,...
    ~, t, result, nTrials, goInds] = getContinuousData(dataIn);

% we will assume the target was always the one we wanted  during phase 1 
% in order to include all of the movement trials
if session<= 3
    EEGTarget = target*ones(size(EEGTarget));
end

tau1 = -1.55*f1a - 2.82*f1b + 7.87;
tau2 = -1.55*f2a - 2.82*f2b + 7.87;

%% compute latency 
samplesInTrace = 400;
[latency, maxP, latMaxP, maxV, latMaxV, maxT, minT, latMaxT] = ...
    deal(NaN(nTrials,1));

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
    
    v1 = [0; posDiff1(2:end)-posDiff1(1:end-1)]/256;
    v2 = [0; posDiff2(2:end)-posDiff2(1:end-1)]/256;
    
    %% was this the EEG target we wanted? The Finger target we wanted?
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
    if max(posDiff1)>1000 || max(posDiff2)>1000
        successful = 0;
    end 
    
    %% if this is a trial worth saving (successful, target, finger correct)
    %  then record all movement parameters 
    if successful ~= 0 && targetWanted && fingerWanted        
        switch finger
            case 1
                [maxP(trial), latMaxP(trial)] = max(abs(posDiff1));
                [maxV(trial), latMaxV(trial)] = max(abs(v1));
                [maxT(trial), latMaxT(trial)] = max(tauDiff1);
                [minT(trial), ~] = min(tauDiff1);
            case 2
                [maxP(trial), latMaxP(trial)] = max(abs(posDiff2));
                [maxV(trial), latMaxV(trial)] = max(abs(v2));
                [maxT(trial), latMaxT(trial)] = max(tauDiff2);
                [minT(trial), ~] = min(tauDiff2);
            case 3
                [maxP(trial), latMaxP(trial)] = ...
                    max([max(abs(posDiff1)) max(abs(posDiff2))]);
                [maxV1, latMaxV1(1)] = max(abs(v1));
                [maxV2, latMaxV1(2)] = max(abs(v2));
                [maxV(trial), fingerMaxed] = max([maxV1 maxV2]);
                latMaxV(trial) = latMaxV1(fingerMaxed);
                [maxT1, latMaxT1(1)] = max(tauDiff1);
                [maxT2, latMaxT1(2)] = max(tauDiff2);
                [maxT(trial), fingerMaxed] = max([maxT1, maxT2]);
                latMaxT(trial) = latMaxT1(fingerMaxed);
                minT(trial) = min([min(tauDiff1) min(tauDiff2)]);                
        end
        
        %% latency: count samples until movement occurred to get 
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

latMaxP = latMaxP/256*1000;
latMaxV = latMaxV/256*1000;
latMaxT = latMaxT/256*1000;
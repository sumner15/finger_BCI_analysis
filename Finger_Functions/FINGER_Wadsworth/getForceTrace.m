% Uses the result of 'datToMat', a data structure, to calculate the
% force traces for every trial in phase 3.
% 
% takes in dataIn, the raw data from the datToMat function, the session
% number (e.g. 07), and the target (e.g. 1-yellow or 2-blue)
%
% takes in 
function [traces, otherFinger] = ...
    getForceTrace(dataIn, session, target, finger)

% phase 2 has no latency results
if session >= 4 && session <=9
    traces = NaN;
    warning(['session ' num2str(session) ' is not a movement session'])
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

%% put needed data in continuous format
nRuns = length(dataIn.state);
[f1a, f1b, f2a, f2b, pos1, pos2, moveTarget, EEGTarget, taskState, t, result] = deal([]);

for run = 1:nRuns
    % note:
    % move target (cursorColors)  0-none 1-index 2-middle 3-both
    % EEG target (targetCode) 0-none 1-yellowSquare 2-blueSquare
    % taskState 0-none 1-EEGSquare 2-preMovement 3-moveCircles 4-feedback
    pos1 = [pos1 ; double(dataIn.state{1,run}.FRobotPos1)];
    pos2 = [pos2 ; double(dataIn.state{1,run}.FRobotPos2)];
    f1a = [f1a ; double(dataIn.state{1,run}.FRobotForceF1a)];
    f1b = [f1b ; double(dataIn.state{1,run}.FRobotForceF1b)];
    f2a = [f2a ; double(dataIn.state{1,run}.FRobotForceF2a)];
    f2b = [f2b ; double(dataIn.state{1,run}.FRobotForceF2b)];
    moveTarget = [moveTarget ; double(dataIn.state{1,run}.CursorColors)];
    EEGTarget = [EEGTarget ; double(dataIn.state{1,run}.TargetCode)];
    taskState = [taskState ; double(dataIn.state{1,run}.TaskState3)];
    t = [t ; double(dataIn.state{1,run}.SourceTime)];    
    result = [result ; double(dataIn.state{1,run}.CursorResult)];
end
tau1 = -1.55*f1a - 2.82*f1b + 7.87;
tau2 = -1.55*f2a - 2.82*f2b + 7.87;

% we will assume the target was always the one we wanted  during phase 1 
% in order to include all of the movement trials
if session<= 3
    EEGTarget = target*ones(size(EEGTarget));
end

%% fix time vector to be monotonically increasing
for i = 2:length(t)
    if t(i) < t(i-1)
        t(i:end) = t(i:end)+t(i-1)-t(i);
    end
end
t = t-t(1);

%% find movement cue (task state -> 3)
goCue = zeros(size(taskState));
for sample = 2:length(taskState)
    % if, at this sample, we gave 'go' cue 
    if taskState(sample)==3 && taskState(sample-1)~=3 
        goCue(sample) = 1;
    end
end
goInds = find(goCue==1);
goInds = [goInds ; length(t)];
nTrials = length(goInds)-1;

%% get movement traces
samplesInTrace = 400;
[traces, otherFinger] = deal(NaN(nTrials,samplesInTrace));

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
    % don't look at falsely triggered movements
    if max(posDiff1(1:100))>50 || max(posDiff2(1:100))>50
        successful = 0;
    end
    
    if successful ~= 0 && targetWanted && fingerWanted                
        switch finger
            case 1
                traces(trial,:) = tauDiff1';   
                otherFinger(trial,:) = tauDiff2';
            case 2 
                traces(trial,:) = tauDiff2'; 
                otherFinger(trial,:) = tauDiff1';
            case 3
                traces(trial,:) = tauDiff1';
                otherFinger(trial,:) = tauDiff2';
        end                             
    end
end
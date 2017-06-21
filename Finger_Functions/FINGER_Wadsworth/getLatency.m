%Uses the result of 'datToMat', a data structure, to calculate the latency
%on each trial. 
% takes in dataIn, the raw data from the datToMat function, the session
% number (e.g. 07), and the target (e.g. 1-yellow or 2-blue)
% returns latency, a vector of latency values, one for each trial during
% the session.
function latency = getLatency(dataIn,session, target)

% phase 2 has no latency results
if session >= 4 && session <=9
    latency = NaN;
    return
end

% default to yellow target
if ~exist('target','var')
    target = 1;
    warning('assuming you wanted yellow square results')
end

%% put needed data in continuous format
nRuns = length(dataIn.state);
[pos1, pos2, moveTarget, EEGTarget, taskState, t, result] = deal([]);

for run = 1:nRuns
    % note:
    % move target (cursorColors)  0-none 1-index 2-middle 3-both
    % EEG target (targetCode) 0-none 1-yellowSquare 2-blueSquare
    % taskState 0-none 1-EEGSquare 2-preMovement 3-moveCircles 4-feedback
    pos1 = [pos1 ; double(dataIn.state{1,run}.FRobotPos1)];
    pos2 = [pos2 ; double(dataIn.state{1,run}.FRobotPos2)];
    moveTarget = [moveTarget ; double(dataIn.state{1,run}.CursorColors)];
    EEGTarget = [EEGTarget ; double(dataIn.state{1,run}.TargetCode)];
    taskState = [taskState ; double(dataIn.state{1,run}.TaskState3)];
    t = [t ; double(dataIn.state{1,run}.SourceTime)];    
    result = [result ; double(dataIn.state{1,run}.CursorResult)];
end

% we will assume the target was always yellow during phase 1 in order to
% include all of the movement trials
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

%% compute latency 
latency = NaN(nTrials,1);

for trial = 1:nTrials   
    % if the trial was a success and EEG target was what we want
    sample0 = goInds(trial);
    sampleF = min(sample0+256,goInds(trial+1)); %limits responses > 1 sec
    targetWanted = (EEGTarget(goInds(trial))==target);
    successful = max(result(sample0:sampleF));    
    
    if successful ~= 0 && targetWanted
        % extract movement for this trial
        posStart1 = pos1(sample0);
        posStart2 = pos2(sample0);   
        
        posDiff1 = abs(pos1(sample0:sampleF)-posStart1);
        posDiff2 = abs(pos2(sample0:sampleF)-posStart2);
        
        % count samples until movement occurred 
        samplesElapsed = 1;
        moved = false;
        while moved == false
            samplesElapsed = samplesElapsed+1;
            % if movement passed a threshold 
            if posDiff1(samplesElapsed) > 20 || posDiff2(samplesElapsed) > 20
                moved = true;
                % calculate difference in time
                tMove = t(sample0+samplesElapsed);
                t0 = t(goInds(trial));    
                latency(trial) = tMove-t0;
            end
        end                        
    end
end
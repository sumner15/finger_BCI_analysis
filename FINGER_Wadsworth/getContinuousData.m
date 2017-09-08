% This function is typically called by the get movement measure functions
% to pass back continuous data from all 8 runs for the current session

function [f1a, f1b, f2a, f2b, pos1, pos2, moveTarget, EEGTarget,...
    taskState, t, result, nTrials, goInds] = getContinuousData(dataIn)

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

end
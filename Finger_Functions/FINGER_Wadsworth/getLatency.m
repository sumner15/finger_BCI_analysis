%Uses the result of 'datToMat', a data structure, to calculate the latency
%on each trial. 
% takes in dataIn, the raw data from the datToMat function, and the session
% number (e.g. 07).
% returns latency, a vector of latency values, one for each trial during
% the session.
function latency = getLatency(dataIn,session)

% phase 2 has no latency results
if session >= 4 && session <=9
    latency = NaN;
    return
end

%% put needed data in continuous format
nRuns = length(dataIn.state);
[pos1, pos2, taskState, t, result] = deal([]);

for run = 1:nRuns
    pos1 = [pos1 ; double(dataIn.state{1,run}.FRobotPos1)];
    pos2 = [pos2 ; double(dataIn.state{1,run}.FRobotPos2)];
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
    % if the trial was a success    
    sample0 = goInds(trial);
    sampleF = goInds(trial+1);
    
    successful = max(result(sample0:sampleF));    
    
    if successful ~= 0
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
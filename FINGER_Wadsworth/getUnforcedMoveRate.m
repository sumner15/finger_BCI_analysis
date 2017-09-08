% get unforced move rate computes session-by-session measurements of
% movement performance from the movement analysis (unforced/robot off)
% trials, taken at the end of each session.
% 
% output:
% move rate, a percentage (%) of trials that the person moved
% latency, the mean latency (s) for movement to start
% 
% inputs:
% subID, e.g. "CHEA"
% TFS, a structure, usually loaded from tracesForStats.mat, e.g. by
% createSubjectTable.m 
function [indexMoveRate, middleMoveRate, bothMoveRate,...
          indexLatency, middleLatency, bothLatency] = ...
          getUnforcedMoveRate(subID, TFS)
    
%unpack TFS structure (for readability)
allTaus = TFS.allTaus;
allTraces = TFS.allTraces;
subjects = TFS.subjects;
clear TFS

% get subject index
logicalCells = strfind(subjects, subID);
subIndex = find(not(cellfun('isempty', logicalCells)));

% organize data
[indexMoveRate, middleMoveRate, bothMoveRate,...
 indexLatency, middleLatency, bothLatency] = deal(NaN(12,1));
indexMoveData = allTraces{subIndex,1};
middleMoveData = allTraces{subIndex,2};
bothMoveData = allTraces{subIndex,3};

% get move rate
for session = 1:12
    if ~isempty(indexMoveData{session})
        % compute mean latency
        indexLatency(session) = getSessionLatency(indexMoveData{session});       
        middleLatency(session) = getSessionLatency(middleMoveData{session});
        bothLatency(session) = getSessionLatency(bothMoveData{session});
        
        % return movement rates (did the person move at all?)
        indexMoveRate(session) = sum(~isnan(indexMoveData{session}(:,1)))...
                                 /size(indexMoveData{session},1)*100;
        middleMoveRate(session) = sum(~isnan(middleMoveData{session}(:,1)))...
                                /size(indexMoveData{session},1)*100;
        bothMoveRate(session) = sum(~isnan(bothMoveData{session}(:,1)))...
                                /size(indexMoveData{session},1)*100;
    else
        [indexMoveRate(session), middleMoveRate(session), ...
            bothMoveRate(session)] = deal(NaN);
    end
end

function meanLatency = getSessionLatency(data)
    nTrials = size(data,1);
    latency = NaN(1,nTrials);
    for trial = 1:nTrials
        if ~isnan(data(trial,1))
            latency(trial) = getTrialLat(data(trial,:));
        end
    end
    meanLatency = nanmean(latency);
end

function trialLatency = getTrialLat(data)
    pos = smooth(abs(data));
    % if we got an errant trace return NaN
    if max(pos(1:100))>50 || max(pos)>1000 || max(pos)<50
        trialLatency = nan;
        return
    end
    % compute latency        
    samplesElapsed = find(pos>=50,1);
    trialLatency = samplesElapsed/256;                        
end

end

        
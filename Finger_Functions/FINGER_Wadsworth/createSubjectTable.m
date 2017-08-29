%Useful for calculating within-subject measures of performance!
%calls datToMat to parse data from BCI2000 Wadsworth BCI study and stores
%the results in a table 
%
% takes in subID as a string, e.g. "NORS"
%       and session as integer, e.g. 09
%
% function dependencies:
% getERD(), getHitRate(), getMaxF()

function tableOut = createSubjectTable(subID)
%% load clinical data into mat format

dataDirectory();
clinicalData = load('ClinicalDataSummary.mat');
clinicalData = clinicalData.clinicalData;

% allocate the clinical scores
[BBT, FM, NIHSS, MOCA] = deal(NaN(12,1));
subRow = find(strcmp(clinicalData.StudyID,subID));

BBTString = ['BBT' clinicalData.ImpairedSide{subRow}]; %#ok<FNDSB>
FMString = 'FMAMATotal';
NIHSSString = 'NIHSSTotalScore';
MOCAString = 'MoCATotal';

% set the session numbers and phase teypes
sessionNum = {'S1','S2','S3','S4','S5','S6','S7','S8','S9','S10','S11','S12'};
vickySession = [1 1 2 2 2 2 2 2 2 3 3 4];
phaseTable = table([1 1 1 2 2 2 2 2 2 3 3 3]','VariableNames',{'phase'});

for session = 1:12        
    % get the table for the session (includes all trials)
    sessionTable = createTableFromSession(subID, session);
    
    % initialize the table out for later manipulation (arbitrary table ok)
    if session == 1
        tableOut = sessionTable(1,:);
    end
    sessionMeans = nanmean(sessionTable{:,:},1);
    
    % calculate the means for each session and build the table
    tableOut{session,:} = sessionMeans;    
    
    % arrange the clinical scores        
    BBT(session) = eval(['clinicalData.' BBTString ...
        num2str(vickySession(session)) '(subRow)']);
    FM(session) = eval(['clinicalData.' FMString ...
        num2str(vickySession(session)) '(subRow)']);
    NIHSS(session) = eval(['clinicalData.' NIHSSString ...
        num2str(vickySession(session)) '(subRow)']);
    MOCA(session) = eval(['clinicalData.' MOCAString ...
        num2str(vickySession(session)) '(subRow)']);
end

% create clinical sub-tables 
BBTTable = table(BBT,'VariableNames',{'BBT'});
FMTable = table(FM,'VariableNames',{'FM'});
NIHSSTable = table(NIHSS,'VariableNames',{'NIHSS'});
MOCATable = table(MOCA,'VariableNames',{'MOCA'});

%% load hit rate values 
[hitRateRobot, hitRateEEG] = deal(NaN(12,1));
for session = 1:12
    hitRateRobot(session) = getHitRateRobot(subID,session);
    hitRateEEG(session) = getHitRateEEG(subID,session);    
end
hitRateRobotTable = table(hitRateRobot,'VariableNames',{'hitRateRobot'});
hitRateEEGTable = table(hitRateEEG,'VariableNames',{'hitRateEEG'});

%% load unforced hit rate values
dataDirectory()
load tracesForStats.mat
% get subject index
logicalCells = strfind(subjects, subID);
subIndex = find(not(cellfun('isempty', logicalCells)));
% organize data
[indexMoveRate, middleMoveRate, bothMoveRate] = deal(NaN(12,1));
indexMoveData = allTraces{subIndex,1};
middleMoveData = allTraces{subIndex,2};
bothMoveData = allTraces{subIndex,3};
for session = 1:12
    if ~isempty(indexMoveData{session})
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
iMRTable = table(indexMoveRate,'VariableNames',{'indexMoveRate'});
mMRTable = table(middleMoveRate,'VariableNames',{'middleMoveRate'});
bMRTable = table(bothMoveRate,'VariableNames',{'bothMoveRate'});

%% load ERD values
dataDirectory(true);
load('ERDp.mat');
load('ERDR2.mat');
ERDp = eval(['ERDp.' subID]);
ERDR2 = eval(['ERDR2.' subID]);
ERDpTable = table(ERDp,'VariableNames',{'ERDp'});
ERDR2Table = table(ERDR2,'VariableNames',{'ERDR2'});

%% update table w new scores and finalize
tableOut = [phaseTable tableOut ERDpTable ERDR2Table ...
    BBTTable FMTable NIHSSTable MOCATable ...
    hitRateRobotTable hitRateEEGTable ...
    iMRTable mMRTable bMRTable];

tableOut.Properties.RowNames = sessionNum;

% this property is necessary for the plotting GUI to function
tableOut.Properties.VariableDescriptions = ...
    tableOut.Properties.VariableNames;

end


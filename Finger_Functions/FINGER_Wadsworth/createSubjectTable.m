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
    % calculate the means for each session and build the table
    sessionTable = createTableFromSession(subID, session);
    if session == 1
        tableOut = sessionTable(1,:);
    end
    sessionMeans = mean(sessionTable{:,:},1);
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

%% load ERD p values
dataDirectory(true);
load('ERDp.mat');
ERDp = eval(['ERDp.' subID]);
ERDpTable = table(ERDp,'VariableNames',{'ERDp'});

%% update table w clinical scores and finalize
tableOut = [phaseTable tableOut ERDpTable ...
    BBTTable FMTable NIHSSTable MOCATable];
tableOut.Properties.RowNames = sessionNum;

% this property is necessary for the plotting GUI to function
tableOut.Properties.VariableDescriptions = ...
    tableOut.Properties.VariableNames;

end


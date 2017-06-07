clear; clc; close all
subjects = {'MCCL','VANT','MAUA','HATA','PHIC','CHEA','RAZT','TRUL'};
nSubs = length(subjects);

%% load clinical data
clinicalDataSimple = load('ClinicalDataSimple.mat');
clinicalDataSimple = clinicalDataSimple.clinicalDataSimple;

%% rearrange data by subject
[FM, BBT, NIHSS] = deal(cell(nSubs,1));
for sub = 1:nSubs    
        % set variables of interest (clinical scores of interest)
    FMVars = {'FMAMATotalscreen','FMAMATotal1','FMAMATotal2',...
    'FMAMATotal3','FMAMATotal4'};
    BBTVars = {...
        ['BBT' clinicalDataSimple.ImpairedSide{subjects{sub}} 'screen'],...
        ['BBT' clinicalDataSimple.ImpairedSide{subjects{sub}} '1'],...
        ['BBT' clinicalDataSimple.ImpairedSide{subjects{sub}} '2'],...
        ['BBT' clinicalDataSimple.ImpairedSide{subjects{sub}} '3'],...
        ['BBT' clinicalDataSimple.ImpairedSide{subjects{sub}} '4']};
    NIHSSVars = {'NIHSSTotalScorescreen','NIHSSTotalScore1',...
        'NIHSSTotalScore2','NIHSSTotalScore3','NIHSSTotalScore4'};
        
    % allocate 
    [FM{sub}, BBT{sub}, NIHSS{sub}] = deal(NaN(1,length(FMVars)));
    % fill in the vector for each subjects clinical scores
    for visit = 1:length(FMVars)
        FM{sub}(visit) = eval(['clinicalDataSimple.' FMVars{visit} '(subjects{sub})']);
        BBT{sub}(visit) = eval(['clinicalDataSimple.' BBTVars{visit} '(subjects{sub})']);
        NIHSS{sub}(visit) = eval(['clinicalDataSimple.' NIHSSVars{visit} '(subjects{sub})']);
    end
end

%% plot results
plotOverSession(FM, 'FM', subjects)
plotOverSession(BBT, 'BBT', subjects)
    
%% temporary conversion code to get change in clinical scores 
% note: Only use this to create the new change values for the subject
% tables. This code should not have to be ran more than once
% 
% [dFM, dBBT] = deal(zeros(nSubs,1));
% for sub = 1:nSubs
%    dFM(sub) = mean(FM{sub}(4:5))-mean(FM{sub}(1:3));
%    dBBT(sub) = mean(BBT{sub}(4:5))-mean(BBT{sub}(1:3));
% end
% TdFM = table(dFM,'VariableNames',{'changeFMAMA'});
% TdBBT = table(dBBT,'VariableNames',{'changeBBT'});   
% 
% [BBTscreenI, BBT1I, BBT2I, BBT3I, BBT4I] = deal(NaN(nSubs,1));
% for sub = 1:nSubs
%     iSide = clinicalDataSimple.ImpairedSide{subjects{sub}};
%     BBTscreenI(sub) = ...
%         eval(['clinicalDataSimple.BBT' iSide 'screen(subjects{sub})']);
%     BBT1I(sub) = eval(['clinicalDataSimple.BBT' iSide '1(subjects{sub})']);
%     BBT2I(sub) = eval(['clinicalDataSimple.BBT' iSide '2(subjects{sub})']);
%     BBT3I(sub) = eval(['clinicalDataSimple.BBT' iSide '3(subjects{sub})']);
%     BBT4I(sub) = eval(['clinicalDataSimple.BBT' iSide '4(subjects{sub})']);
% end
% BBTT = table(BBTscreenI,BBT1I,BBT2I,BBT3I,BBT4I,'VariableNames',...
%     {'BBTscreenI', 'BBT1I', 'BBT2I', 'BBT3I', 'BBT4I'});



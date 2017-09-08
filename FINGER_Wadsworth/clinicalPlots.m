clear; clc; close all
% subjects = {'MCCL','VANT','MAUA','HATA','PHIC','CHEA','RAZT','TRUL'};
subjects = {'CHEA','HATA','MAUA','MCCL','PHIC','RAZT','TRUL','VANT'};
nSubs = length(subjects);

%% load clinical data & rearrange data by subject
load('ClinicalDataSimple.mat');

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

figure(1)
plotOverSession(BBT,'Box & Blocks',subjects,false)
figure(2)
plotOverSession(BBT,'Box & Blocks',subjects,true)
    
%% temporary conversion code to get change in clinical scores 
% note: Only use this to create the new change values for the subject
% tables. This code should not have to be ran more than once

% [dFM, dBBT] = deal(zeros(nSubs,1));
% for sub = 1:nSubs
% %    dFM(sub) = mean(FM{sub}(4:5))-mean(FM{sub}(1:3));
% %    dBBT(sub) = mean(BBT{sub}(4:5))-mean(BBT{sub}(1:3));
%    dFM(sub) = mean(FM{sub}(5))-mean(FM{sub}(1:2));
%    dBBT(sub) = mean(BBT{sub}(5))-mean(BBT{sub}(1:2));
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

%% temporary conversion code to save movement data to table
% note: this code should only have to be run once

% [iLatUnforced1, iLatUnforced2, iLatUnforced3, iLatUnforced4,...
%  mLatUnforced1, mLatUnforced2, mLatUnforced3, mLatUnforced4,...
%  bLatUnforced1, bLatUnforced2, bLatUnforced3, bLatUnforced4]...
%     = deal(NaN(8,1));
%     
% subjects = {'MCCL','VANT','MAUA','HATA','PHIC','CHEA','RAZT','TRUL'};
% for sub = 1:length(subjects)    
%     subID = subjects{sub};
%     dataDirectory()    
%     load([subID '.mat']);
%     
%     iLatUnforced1(sub) = subData.iLatUnforced(1);
%     iLatUnforced2(sub) = subData.iLatUnforced(3);
%     iLatUnforced3(sub) = subData.iLatUnforced(10);
%     iLatUnforced4(sub) = subData.iLatUnforced(12);
%     
%     mLatUnforced1(sub) = subData.mLatUnforced(1);
%     mLatUnforced2(sub) = subData.mLatUnforced(3);
%     mLatUnforced3(sub) = subData.mLatUnforced(10);
%     mLatUnforced4(sub) = subData.mLatUnforced(12);
%     
%     bLatUnforced1(sub) = subData.bLatUnforced(1);
%     bLatUnforced2(sub) = subData.bLatUnforced(3);
%     bLatUnforced3(sub) = subData.bLatUnforced(10);
%     bLatUnforced4(sub) = subData.bLatUnforced(12);    
% end
% unforced = table(iLatUnforced1, iLatUnforced2, iLatUnforced3, iLatUnforced4,...
%                  mLatUnforced1, mLatUnforced2, mLatUnforced3, mLatUnforced4,...
%                  bLatUnforced1, bLatUnforced2, bLatUnforced3, bLatUnforced4,...
%                  'VariableNames',...
%                  {'iLatUF1','iLatUF2', 'iLatUF3', 'iLatUF4',...
%                  'mLatUF1', 'mLatUF2', 'mLatUF3', 'mLatUF4',...
%                  'bLatUF1', 'bLatUF2', 'bLatUF3', 'bLatUF4'});
% unforced.Properties.VariableDescriptions = ...
%     unforced.Properties.VariableNames;

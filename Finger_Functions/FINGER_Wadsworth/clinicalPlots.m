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

%% plot clinical data over time
set(0,'defaultlinelinewidth',2.5)
sessions = [0 1 3 10 12];

% plot measures separately 
set(figure,'Position',[150 20 1400 900]);
subplot(221)
hold on
for sub = 1:nSubs
    plot(sessions,BBT{sub},'-o')        
end
title('Box & Blocks Assessment')
ylabel('BBT')

subplot(222)
hold on
for sub = 1:nSubs
    plot(sessions,FM{sub},'-o')
end
title('Fugl-Meyer Assessment')
ylabel('FMA')

subplot(223)
hold on
for sub = 1:nSubs
    plot(sessions,BBT{sub}-BBT{sub}(1),'-o')
end
title('Change in Box & Blocks')
ylabel('\delta BBT')

subplot(224)
hold on
for sub = 1:nSubs
    plot(sessions,FM{sub}-FM{sub}(1),'-o')
end
title('Change in Fugl Meyer')
ylabel('\delta FMA')

% set type and legend
set(findall(gcf,'-property','FontSize'),'FontSize',14)
sessionTitles = {'BL','Phase 1','','','Phase 2','','','','','',...
    'Phase 3','','end'};
for sub = 1:4  
    subplot(2,2,sub)  
    xlim([-1 13])
    xticks(0:12)
    xticklabels(sessionTitles)                   
    xlabel('session')    
    xtickangle(45)    
end
leg1 = legend(subjects,'location','best');
    set(leg1,'FontSize',10)
    
%% temporary conversion code to get change in clinical scores
[dFM, dBBT] = deal(zeros(nSubs,1));
for sub = 1:nSubs
   dFM(sub) = mean(FM{sub}(4:5))-mean(FM{sub}(1:3));
   dBBT(sub) = mean(BBT{sub}(4:5))-mean(BBT{sub}(1:3));
end
TdFM = table(dFM,'VariableNames',{'changeFMAMA'});
TdBBT = table(dBBT,'VariableNames',{'changeBBT'});   
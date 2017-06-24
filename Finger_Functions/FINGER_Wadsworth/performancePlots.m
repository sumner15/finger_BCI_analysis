clear; clc; close all

%% plot results for all subjects
subjects = {'MCCL','VANT','MAUA','HATA','PHIC','CHEA','RAZT','TRUL'};
loadAndPlot(subjects)

%% plot results for performers
subjects = {'MCCL','VANT','CHEA','RAZT','TRUL'};
loadAndPlot(subjects)

function loadAndPlot(subjects)
    fprintf('\nPlotting performance over sessions\n')
    
    %% load hit Rate performance
    dataDirectory();
    nSubs = length(subjects);

    [ERDp, ERDR2, hitRateEEG, hitRateRobot, latencyYI, latencyBI, ...
        latencyYM, latencyBM] = deal(cell(nSubs,1));
    
    for sub = 1:nSubs
       load(subjects{sub}) 

       ERDp{sub} = subData.ERDp;
       ERDR2{sub} = subData.ERDR2;
       hitRateEEG{sub} = subData.hitRateEEG;
       hitRateRobot{sub} = subData.hitRateRobot;
       latencyYI{sub} = subData.latencyYI;      
       latencyBI{sub} = subData.latencyBI;  
       latencyYM{sub} = subData.latencyYM;
       latencyBM{sub} = subData.latencyBM;
    end

    %% plot results over session
%     plotOverSession(ERDp, 'ERD p-val', subjects)
%     plotOverSession(ERDR2, 'ERD (R^2)', subjects)
%     plotOverSession(hitRateEEG, 'hit rate EEG (%)', subjects)
%     plotOverSession(hitRateRobot, 'hit rate robot (%)', subjects)
    plotOverSession(latencyYI, 'index latency w/ ERD (ms)', subjects) 
    plotOverSession(latencyYM, 'middle latency w/ ERD (ms)', subjects)
    plotOverSession(latencyBI, 'index latency w/ ERS (ms)', subjects)
    plotOverSession(latencyBM, 'middle latency w/ ERS (ms)', subjects)
    
    
    %% plot phase 3 results
    plotPhase3(latencyYI, latencyBI, 'index latency (ms)', subjects)
    plotPhase3(latencyYM, latencyBM, 'middle latency (ms)', subjects)
end
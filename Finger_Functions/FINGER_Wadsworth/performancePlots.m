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

    [ERDp, ERDR2, hitRateEEG, hitRateRobot, latency] = deal(cell(nSubs,1));
    for sub = 1:nSubs
       load(subjects{sub}) 

       ERDp{sub} = subData.ERDp;
       ERDR2{sub} = subData.ERDR2;
       hitRateEEG{sub} = subData.hitRateEEG;
       hitRateRobot{sub} = subData.hitRateRobot;
       latency{sub} = subData.latency;
    end

    %% plot results
    plotOverSession(ERDp, 'ERD p-val', subjects)
    plotOverSession(ERDR2, 'ERD (R^2)', subjects)
    plotOverSession(hitRateEEG, 'hit rate EEG (%)', subjects)
    plotOverSession(hitRateRobot, 'hit rate robot (%)', subjects)
    plotOverSession(latency, 'latency (ms)', subjects)
end
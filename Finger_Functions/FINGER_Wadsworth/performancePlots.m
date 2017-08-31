clear; close all

%% plot results for all subjects
% subjects = {'MCCL','VANT','MAUA','HATA','PHIC','CHEA','RAZT','TRUL'};
subjects = {'CHEA','HATA','MAUA','MCCL','PHIC','RAZT','TRUL','VANT'};
loadAndPlot(subjects)

% % debugging 
% subjects = {'CHEA'};
% loadAndPlot(subjects)

function loadAndPlot(subjects)
    fprintf('\nPlotting performance over sessions\n')
    
    %% load hit Rate performance
    dataDirectory();
    nSubs = length(subjects);

    [ERDp, ERDR2, hitRateEEG, hitRateRobot, ...
        indexLatency, middleLatency, bothLatency] = ...
        deal(cell(nSubs,1));
    
    for sub = 1:nSubs
       load(subjects{sub}) 

       ERDp{sub} = subData.ERDp;
       ERDR2{sub} = subData.ERDR2;
       hitRateEEG{sub} = subData.hitRateEEG;
       hitRateRobot{sub} = subData.hitRateRobot;      
       indexLatency{sub} = subData.iLatUnforced;
       middleLatency{sub} = subData.mLatUnforced;
       bothLatency{sub} = subData.bLatUnforced;
    end

    %% plot results over session
    figure(1)
    plotOverSession(ERDp, 'ERD p-val', subjects)
    figure(2)
    plotOverSession(ERDR2, 'ERD (R^2)', subjects)
    figure(3)
    plotOverSession(hitRateEEG, 'SMR hit rate (%)', subjects)    
    figure(4)
    plotOverSession(hitRateRobot, 'hit rate robot (%)', subjects)      
    figure(5)
    plotOverSession(indexLatency, 'index latency, unforced (s)', subjects)    
    figure(6)
    plotOverSession(middleLatency, 'middle latency, unforced (s)', subjects)    
    figure(7)
    plotOverSession(bothLatency, 'both latency, unforced (s)', subjects)    
    
    
end
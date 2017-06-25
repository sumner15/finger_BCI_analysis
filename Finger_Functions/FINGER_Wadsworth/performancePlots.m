clear; clc; close all

%% plot results for all subjects
subjects = {'MCCL','VANT','MAUA','HATA','PHIC','CHEA','RAZT','TRUL'};
loadAndPlot(subjects)

%% plot results for performers
subjects = {'MCCL','VANT','CHEA','RAZT','TRUL'};
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
        latYI, latBI, latYM, latBM, latYB, latBB,...
        maxPYI, maxPBI, maxPYM, maxPBM, maxPYB, maxPBB,...
        maxVYI, maxVBI, maxVYM, maxVBM, maxVYB, maxVBB,...
        maxTYI, maxTBI, maxTYM, maxTBM, maxTYB, maxTBB,...
        minTYI, minTBI, minTYM, minTBM, minTYB, minTBB,...
        latMaxTYI, latMaxTBI, latMaxTYM, latMaxTBM, latMaxTYB, latMaxTBB]...
         = deal(cell(nSubs,1));
    
    for sub = 1:nSubs
       load(subjects{sub}) 

       ERDp{sub} = subData.ERDp;
       ERDR2{sub} = subData.ERDR2;
       hitRateEEG{sub} = subData.hitRateEEG;
       hitRateRobot{sub} = subData.hitRateRobot;

       latYI{sub} = subData.latencyYI;      
       latBI{sub} = subData.latencyBI;       
       latYM{sub} = subData.latencyYM;
       latBM{sub} = subData.latencyBM;       
       latYB{sub} = subData.latencyYB;
       latBB{sub} = subData.latencyBB;
       
       maxPYI{sub} = subData.maxPYI;      
       maxPBI{sub} = subData.maxPBI;       
       maxPYM{sub} = subData.maxPYM;
       maxPBM{sub} = subData.maxPBM;       
       maxPYB{sub} = subData.maxPYB;
       maxPBB{sub} = subData.maxPBB;
       
       maxVYI{sub} = subData.maxVYI;      
       maxVBI{sub} = subData.maxVBI;       
       maxVYM{sub} = subData.maxVYM;
       maxVBM{sub} = subData.maxVBM;       
       maxVYB{sub} = subData.maxVYB;
       maxVBB{sub} = subData.maxVBB;
       
       maxTYI{sub} = subData.maxTYI;      
       maxTBI{sub} = subData.maxTBI;       
       maxTYM{sub} = subData.maxTYM;
       maxTBM{sub} = subData.maxTBM;       
       maxTYB{sub} = subData.maxTYB;
       maxTBB{sub} = subData.maxTBB;
       
       minTYI{sub} = subData.minTYI;      
       minTBI{sub} = subData.minTBI;       
       minTYM{sub} = subData.minTYM;
       minTBM{sub} = subData.minTBM;       
       minTYB{sub} = subData.minTYB;
       minTBB{sub} = subData.minTBB;
       
       latMaxTYI{sub} = subData.latMaxTYI;      
       latMaxTBI{sub} = subData.latMaxTBI;       
       latMaxTYM{sub} = subData.latMaxTYM;
       latMaxTBM{sub} = subData.latMaxTBM;       
       latMaxTYB{sub} = subData.latMaxTYB;
       latMaxTBB{sub} = subData.latMaxTBB;
    end

    %% plot results over session
%     plotOverSession(ERDp, 'ERD p-val', subjects)
%     plotOverSession(ERDR2, 'ERD (R^2)', subjects)
%     plotOverSession(hitRateEEG, 'hit rate EEG (%)', subjects)
%     plotOverSession(hitRateRobot, 'hit rate robot (%)', subjects)
    
    set(figure,'Position',[100 20 2000 1100]);  
    fingers = 3; 
    measures = 2;
    
    subplot(fingers, measures, 1)
    plotOverSession(latYI, 'index latency w/ ERD (ms)', subjects) 
    subplot(fingers, measures, 2)
    plotOverSession(latBI, 'index latency w/ ERS (ms)', subjects)
    subplot(fingers, measures, 3)
    plotOverSession(latYM, 'middle latency w/ ERD (ms)', subjects)
    subplot(fingers, measures, 4)
    plotOverSession(latBM, 'middle latency w/ ERS (ms)', subjects)
    subplot(fingers, measures, 5)
    plotOverSession(latYB, 'both latency w/ ERD (ms)', subjects)
    subplot(fingers, measures, 6)
    plotOverSession(latBB, 'both latency w/ ERS (ms)', subjects)
    
    %% plot phase 3 movement results
    set(figure,'Position',[100 20 2000 1100]);      
    fingers = 3; 
    measures = 3;
    
    % plot latency results (first row)
    subplot(fingers, measures, 1)
    plotPhase3(latYI, latBI, 'index latency (ms)', subjects)
    subplot(fingers, measures, measures+1)
    plotPhase3(latYM, latBM, 'middle latency (ms)', subjects)
    subplot(fingers, measures, 2*measures+1)
    plotPhase3(latYB, latBB, 'both latency (ms)', subjects)
    
    % plot max position results (second row)
    subplot(fingers, measures, 2)
    plotPhase3(maxPYI, maxPBI, 'index max pos', subjects)
    subplot(fingers, measures, measures+2)
    plotPhase3(maxPYM, maxPBM, 'middle max pos', subjects)
    subplot(fingers, measures, 2*measures+2)
    plotPhase3(maxPYB, maxPBB, 'both max pos', subjects)
    
    % plot max velocity results (third row)
    subplot(fingers, measures, 3)
    plotPhase3(maxVYI, maxVBI, 'index max vel', subjects)
    subplot(fingers, measures, measures+3)
    plotPhase3(maxVYM, maxVBM, 'middle max vel', subjects)
    subplot(fingers, measures, 2*measures+3)
    plotPhase3(maxVYB, maxVBB, 'both max vel', subjects, true)
    
    %% plot phase 3 force results
    set(figure,'Position',[100 20 2000 1100]);   
    
    % plot max torque results (first row)
    subplot(fingers, measures, 1)
    plotPhase3(maxTYI, maxTBI, 'index max \tau', subjects)
    subplot(fingers, measures, measures+1)
    plotPhase3(maxTYM, maxTBM, 'middle max \tau', subjects)
    subplot(fingers, measures, 2*measures+1)
    plotPhase3(maxTYB, maxTBB, 'both max \tau', subjects)
    
    % plot min torque results (second row)
    subplot(fingers, measures, 2)
    plotPhase3(minTYI, minTBI, 'index min \tau', subjects)
    subplot(fingers, measures, measures+2)
    plotPhase3(minTYM, minTBM, 'middle min \tau', subjects)
    subplot(fingers, measures, 2*measures+2)
    plotPhase3(minTYB, minTBB, 'both min \tau', subjects)
    
    % plot latency to max torque (third row)
    subplot(fingers, measures, 3)
    plotPhase3(latMaxTYI, latMaxTBI, 'index t to max \tau (ms)', subjects)
    subplot(fingers, measures, measures+3)
    plotPhase3(latMaxTYM, latMaxTBM, 'middle t to max \tau (ms)', subjects)
    subplot(fingers, measures, 2*measures+3)
    plotPhase3(latMaxTYB, latMaxTBB, 'both t to max \tau (ms)', subjects, true)
    
end
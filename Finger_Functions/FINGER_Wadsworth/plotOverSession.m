function plotOverSession(data,label,subjects)
% This function plots a single measure across all sessions for individual
% components. A second plot shows the change in this measure compared to
% baseline (useful for clinical data and basic performance measures)
%
% data is a {nSubs x 1} cell array where each cell should contain a 1 x
% nSessions array of measurement data
% 
% label is a string containing the measure description/label
%
% subjects is a {1 x nSubs} cell array where each cell contains a string
% subject identifier, e.g. 'NORS'

    %% set up colors
    co = [  0.0000    0.4470    0.7410;...
            0.8500    0.3250    0.0980;...
            0.9290    0.6940    0.1250;...
            0.4940    0.1840    0.5560;...
            0.4660    0.6740    0.1880;...
            0.3010    0.7450    0.9330;...
            0.6350    0.0780    0.1840;...
            0.2000    0.2000    1.0000];
    set(groot,'defaultAxesColorOrder',co)

    %% set up 
    if length(data{1})==5 %if this is clinical data
        sessions = [0 1 3 10 12];
    elseif length(data{1})==12 %if this is another measure
        sessions = 1:12;
    end
    
    nSubs = length(subjects);

    %% plot measure 
    set(figure,'Position',[150 20 1400 500]);
    subplot(121)
    hold on
    set(0,'defaultlinelinewidth',2.5)
    for sub = 1:nSubs
        plot(sessions,data{sub},'-o')        
    end    
    ylabel(label)

    subplot(122)
    hold on
    for sub = 1:nSubs
        plot(sessions,data{sub}-data{sub}(1),'-o')
    end    
    ylabel(['\delta ' label])    

    %% set type and legend    
    set(findall(gcf,'-property','FontSize'),'FontSize',14)
    sessionTitles = {'BL','Phase 1','','','Phase 2','','','','','',...
        'Phase 3','','end'};
    for sub = 1:2
        subplot(1,2,sub)  
        xlim([-1 13])
        xticks(0:12)
        xticklabels(sessionTitles)                   
        xlabel('session')    
        xtickangle(45)    
    end
    leg1 = legend(subjects,'location','best');
        set(leg1,'FontSize',10)    
end
function plotPhase3(measure1, measure2, label, subjects, showLegend)
% This function plots a single measure across phase 3 sessions only, but
% plots the measure in different colors for the ERD trials vs the ERS
% trials (although this is decided elsewhere). i.e. it plots measure1 and
% measure2 in different colors. 
%
% data is a {nSubs x 1} cell array where each cell should contain a 1 x
% nSessions array of measurement data
% 
% label is a string containing the measure description/label
%
% subjects is a {1 x nSubs} cell array where each cell contains a string
% subject identifier, e.g. 'NORS'
%
% plotChange is a bool to plot the change from baseline

%% set up
    nSubs = length(subjects);
    sessions = 10:12;
        
    co = [  0.0000    0.4470    0.7410;...
            0.8500    0.3250    0.0980;...
            0.9290    0.6940    0.1250;...
            0.4940    0.1840    0.5560;...
            0.4660    0.6740    0.1880;...
            0.3010    0.7450    0.9330;...
            0.6350    0.0780    0.1840;...
            0.2000    0.2000    1.0000];
    set(groot,'defaultAxesColorOrder',co)

%     %% plot measure      
%     hold on
%     set(0,'defaultlinelinewidth',2.5)
%     for sub = 1:nSubs
%         plot(sessions,measure1{sub}(sessions),'-o','color',co(sub,:))
%         plot(sessions,measure2{sub}(sessions),'--x','color',co(sub,:))
%     end    
%     ylabel(label)
%     leg1 = legend('yellow squares (ERD)','blue squares (ERS)',...
%         'location','best');  
%     setType(leg1)
    
    %% plot difference in measures     
    hold on
    set(0,'defaultlinelinewidth',2.5)
    for sub = 1:nSubs
        plot(sessions,measure1{sub}(sessions)-measure2{sub}(sessions),...
            '-o','color',co(sub,:))        
    end    
    ylabel([label ' (yel-blu)'])    
    if exist('showLegend','var')
        if showLegend
            leg2 = legend(subjects,'location','best');
            setType(leg2)
        else
            setType()
        end
    else
        setType()
    end

    %% set type and legend    
    function setType(leg)
        set(findall(gcf,'-property','FontSize'),'FontSize',14)
        sessionTitles = {'Phase 3','','end'};            
        xlim([9 13])
        xticks(10:12)
        xticklabels(sessionTitles)                   
        xlabel('session')    
        xtickangle(45)      
        if exist('leg','var')
            set(leg,'FontSize',10)   
        end
    end
end
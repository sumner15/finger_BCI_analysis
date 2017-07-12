function plotOverSession(data,label,subjects,plotChange)
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
%
% plotChange is a bool to plot the change from baseline
subjectsDeIdentify = {'a','b','c','d','e','f','g','h'};
nSubs = length(subjects);
if nSubs ~= length(subjectsDeIdentify)
    error('subject mismatch')
end

    %% set up colors
%     co = [  0.0000    0.4470    0.7410;...
%             0.8500    0.3250    0.0980;...
%             0.9290    0.6940    0.1250;...
%             0.4940    0.1840    0.5560;...
%             0.4660    0.6740    0.1880;...
%             0.3010    0.7450    0.9330;...
%             0.6350    0.0780    0.1840;...
%             0.2000    0.2000    1.0000];
%     set(groot,'defaultAxesColorOrder',co)
    co = [  0 0 0 ; ...
            0 0 1 ; ...
            1 0 0 ; ... 
            1 0 0 ; ...
            0 0 1 ; ...
            0 0 0 ; ...
            0 0 0 ; ... 
            0 0 0 ];
    set(groot,'defaultAxesColorOrder',co)
    
    code = {'-o','-o','-o','-x','-x','-x','-*','-+'};

    %% set up 
    if length(data{1})==5 %if this is clinical data
        sessions = [0 1 3 10 12];
    elseif length(data{1})==12 %if this is another measure
        sessions = 1:12;
    end           

    %% plot measure or change in measure
    if nargin <= 3
        hold on
        set(0,'defaultlinelinewidth',1.5)
        for sub = 1:nSubs
            plot(sessions,data{sub},code{sub})
        end    
        ylabel(label)
        setType(subjectsDeIdentify)
    end

    %% plot change in measure
    if nargin >= 4
        hold on
        set(0,'defaultlinelinewidth',1.5)
        if plotChange                           
            for sub = 1:nSubs
                plot(sessions,data{sub}-data{sub}(2),code{sub})
            end    
            ylabel(['\delta ' label])    
            setType(subjectsDeIdentify)
        else
            for sub = 1:nSubs
                plot(sessions,data{sub},code{sub})        
            end    
            ylabel(label)
            setType(subjectsDeIdentify)
        end
    end

    %% set type and legend    
    function setType(subjects)
        set(findall(gcf,'-property','FontSize'),'FontSize',20)
        sessionTitles = {'BL','Phase 1','','','Phase 2','','','','','',...
            'Phase 3','','end'};            
        xlim([-1 13])
        xticks(0:12)
        xticklabels(sessionTitles)                   
%         xlabel('session')    
        xtickangle(45)        
        leg1 = legend(subjects,'location','best');
        set(leg1,'FontSize',14)    
    end
end
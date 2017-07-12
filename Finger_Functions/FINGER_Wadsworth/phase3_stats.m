clear; clc; close all

subjects = {'CHEA','HATA','MAUA','MCCL','PHIC','RAZT','TRUL','VANT'};
set(0,'defaultlinelinewidth',2.5)
nSubs = length(subjects);
startDir = dataDirectory();

index = 1; middle = 2; both = 3;
yellow = 1; blue = 2;

%% load latency and maxT results, compute stats (p val)
for sub = 1:nSubs
    subID = subjects{sub};
    disp(['Processing data for ' subID])
    load(['Phase3_' subID '.mat'])
    
    fingerInds{index} = find(strcmp('index',phase3Table{:,5})); %#ok<*SAGROW>
    fingerInds{middle} = find(strcmp('middle',phase3Table{:,5}));
    fingerInds{both} = find(strcmp('both',phase3Table{:,5}));
    targetInds{yellow} = find(strcmp('yellow',phase3Table{:,6}));
    targetInds{blue} = find(strcmp('blue',phase3Table{:,6}));        
    
    for finger = index:both
        for target = yellow:blue
            % get mean movement measure values
            relevantInds = intersect(fingerInds{finger},targetInds{target});
            latency{sub}(finger,target) = ...
                mean(phase3Table.latency(relevantInds));
            maxT{sub}(finger,target) = ...
                mean(phase3Table.maxT(relevantInds));
            latMaxT{sub}(finger,target) = ...
                mean(phase3Table.latMaxT(relevantInds));
            % get std of movement measure values
            latencySTD{sub}(finger,target) = ...
                std(phase3Table.latency(relevantInds));
            maxTSTD{sub}(finger,target) = ...
                std(phase3Table.maxT(relevantInds));
            latMaxTSTD{sub}(finger,target) = ...
                std(phase3Table.latMaxT(relevantInds));
        end
        % get p values for t-tests across yellow/blue condition
        relevantInds = fingerInds{finger};
        latencyP{sub}(finger) = ...
            anova1(phase3Table.latency(relevantInds),...
            phase3Table.target(relevantInds),'off');
        maxTP{sub}(finger) = ...
            anova1(phase3Table.maxT(relevantInds),...
            phase3Table.target(relevantInds),'off');
        latMaxTP{sub}(finger) = ...
            anova1(phase3Table.latMaxT(relevantInds),...
            phase3Table.target(relevantInds),'off');
    end            
end
cd(startDir);


%% plot results
subsToPlot = [1 6 7 8];
% subsToPlot = 1:8;
nSubsPlot = length(subsToPlot);
set(figure,'Position',[100 20 800 1100]);  
set(0,'defaultAxesFontSize',20)
for sub = 1:nSubsPlot
    % plot latency
    subplot(nSubsPlot,3,3*(sub-1)+1)
    for finger = index:both
        bar(finger-0.2,latency{subsToPlot(sub)}(finger,yellow)+...
            latencySTD{subsToPlot(sub)}(finger,yellow),0.05,'FaceColor', [0 0 0]);
        hold on       
        bar(finger-0.2,latency{subsToPlot(sub)}(finger,yellow),0.25,'FaceColor', [1 0.85 0]);
        bar(finger+0.2,latency{subsToPlot(sub)}(finger,blue)+...
            latencySTD{subsToPlot(sub)}(finger,blue),0.05,'FaceColor', [0 0 0]);
        bar(finger+0.2,latency{subsToPlot(sub)}(finger,blue),0.25,'FaceColor',[0 0.4 0.65]);
        if latencyP{subsToPlot(sub)}(finger) < 0.05
            text(finger,1350,'*','FontSize',40)
        end
    end
    setType()
    ylabel('latency (ms)')
    yticks([0 500 1000 1500])
    ylim([0 1700])
    % plot max T
    subplot(nSubsPlot,3,3*(sub-1)+2)
    for finger = index:both
        bar(finger-0.2,maxT{subsToPlot(sub)}(finger,yellow)+...
            maxTSTD{subsToPlot(sub)}(finger,yellow),0.05,'FaceColor', [0 0 0]);
        hold on
        bar(finger-0.2,maxT{subsToPlot(sub)}(finger,yellow),0.25,'FaceColor', [1 0.85 0]);
        bar(finger+0.2,maxT{subsToPlot(sub)}(finger,blue)+...
            maxTSTD{subsToPlot(sub)}(finger,blue),0.05,'FaceColor', [0 0 0]);
        bar(finger+0.2,maxT{subsToPlot(sub)}(finger,blue),0.25,'FaceColor',[0 0.4 0.65]);
        if maxTP{subsToPlot(sub)}(finger) < 0.05
            text(finger,320,'*','FontSize',40)
        end
    end
    setType()    
    ylabel('MCP torque')
    ylim([0 400])
    % plot latency to Max T
    subplot(nSubsPlot,3,3*(sub-1)+3)
    for finger = index:both
        bar(finger-0.2,latMaxT{subsToPlot(sub)}(finger,yellow)+...
            latMaxTSTD{subsToPlot(sub)}(finger,yellow),0.05,'FaceColor', [0 0 0]);
        hold on
        bar(finger-0.2,latMaxT{subsToPlot(sub)}(finger,yellow),0.25,'FaceColor', [1 0.85 0]);
        bar(finger+0.2,latMaxT{subsToPlot(sub)}(finger,blue)+...
            latMaxTSTD{subsToPlot(sub)}(finger,blue),0.05,'FaceColor', [0 0 0]);
        bar(finger+0.2,latMaxT{subsToPlot(sub)}(finger,blue),0.25,'FaceColor',[0 0.4 0.65]);
        if latMaxTP{subsToPlot(sub)}(finger) < 0.05
            text(finger,1350,'*','FontSize',40)
        end
    end
    setType()    
    ylabel('\deltat max\tau (ms)')
    yticks([0 500 1000 1500])
    ylim([0 1700])
end

function setType()
    xticks([1 2 3])
    xticklabels({'index','middle','both'})    
    xtickangle(45)      
end

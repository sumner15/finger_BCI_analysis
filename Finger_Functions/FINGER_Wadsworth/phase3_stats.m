clear; clc; close all

subjects = {'MCCL','VANT','MAUA','HATA','PHIC','CHEA','RAZT','TRUL'};
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
            relevantInds = intersect(fingerInds{finger},targetInds{target});
            latency{sub}(finger,target) = ...
                mean(phase3Table.latency(relevantInds));
            maxT{sub}(finger,target) = ...
                mean(phase3Table.maxT(relevantInds));
            latencyP{sub}(finger) = ...
                anova1(phase3Table.latency(relevantInds),...
                phase3Table.target(relevantInds),'off');
            maxTP{sub}(finger) = ...
                anova1(phase3Table.maxT(relevantInds),...
                phase3Table.target(relevantInds),'off');
        end
    end            
end
cd(startDir);


%% plot results
subsToPlot = [3 6 8];
set(figure,'Position',[100 20 800 1100]);  
set(0,'defaultAxesFontSize',20)
for sub = 1:length(subsToPlot)
    subplot(3,2,2*(sub-1)+1)
    for finger = index:both
        bar(finger-0.2,latency{subsToPlot(sub)}(finger,yellow),0.25,'FaceColor', [1 0.85 0]);
        hold on
        bar(finger+0.2,latency{subsToPlot(sub)}(finger,blue),0.25,'FaceColor',[0 0.4 0.65]);
    end
    setType()
    ylabel('latency (ms)')
    
    subplot(3,2,2*(sub-1)+2)
    for finger = index:both
        bar(finger-0.2,maxT{subsToPlot(sub)}(finger,yellow),0.25,'FaceColor', [1 0.85 0]);
        hold on
        bar(finger+0.2,maxT{subsToPlot(sub)}(finger,blue),0.25,'FaceColor',[0 0.4 0.65]);
    end
    setType()    
    ylabel('MCP torque')
end

function setType()
    xticks([1 2 3])
    xticklabels({'index','middle','both'})    
    xtickangle(45)      
end

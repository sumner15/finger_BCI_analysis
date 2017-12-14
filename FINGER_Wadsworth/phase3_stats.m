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
            % create values for barAnovas (does not save)
            latencyVerbose{sub,finger,target} = phase3Table.maxT(relevantInds); 
            maxTVerbose{sub,finger,target} = phase3Table.maxT(relevantInds); 
            maxTLatVerbose{sub,finger,target} = phase3Table.maxT(relevantInds);
            
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
set(figure,'Position',[100 20 950 1250]);  
set(0,'defaultAxesFontSize',20)
for sub = 1:nSubsPlot
    % plot latency
    latMin = min(min(latency{subsToPlot(sub)}))-...
        max(max(latencySTD{subsToPlot(sub)}));
    latMax = max(max(latency{subsToPlot(sub)}))+...
        2*max(max(latencySTD{subsToPlot(sub)}));
    subplot(nSubsPlot,2,2*(sub-1)+1)
    for finger = index:both
        bar(finger-0.2,latency{subsToPlot(sub)}(finger,yellow)+...
            latencySTD{subsToPlot(sub)}(finger,yellow),0.05,'FaceColor', [0 0 0]);
        hold on       
        bar(finger-0.2,latency{subsToPlot(sub)}(finger,yellow),0.25,'FaceColor', [1 0.85 0]);
        bar(finger+0.2,latency{subsToPlot(sub)}(finger,blue)+...
            latencySTD{subsToPlot(sub)}(finger,blue),0.05,'FaceColor', [0 0 0]);
        bar(finger+0.2,latency{subsToPlot(sub)}(finger,blue),0.25,'FaceColor',[0 0.4 0.65]);
        if latencyP{subsToPlot(sub)}(finger) < 0.05
            text(finger-0.2,0.8*(latMax-latMin)+latMin,'*','FontSize',30)
        end
    end
    setType()
    ylabel('latency (ms)')
    yticks([0 500 750 1000 1250 1500])    
    ylim([latMin, latMax])
    % plot max T
    maxTMin = max(min(min(maxT{subsToPlot(sub)}))-...
        max(max(maxTSTD{subsToPlot(sub)})),0);
    maxTMax = max(max(maxT{subsToPlot(sub)}))+...
        2*max(max(maxTSTD{subsToPlot(sub)}));
    subplot(nSubsPlot,2,2*(sub-1)+2)
    for finger = index:both
        bar(finger-0.2,maxT{subsToPlot(sub)}(finger,yellow)+...
            maxTSTD{subsToPlot(sub)}(finger,yellow),0.05,'FaceColor', [0 0 0]);
        hold on
        bar(finger-0.2,maxT{subsToPlot(sub)}(finger,yellow),0.25,'FaceColor', [1 0.85 0]);
        bar(finger+0.2,maxT{subsToPlot(sub)}(finger,blue)+...
            maxTSTD{subsToPlot(sub)}(finger,blue),0.05,'FaceColor', [0 0 0]);
        bar(finger+0.2,maxT{subsToPlot(sub)}(finger,blue),0.25,'FaceColor',[0 0.4 0.65]);
        if maxTP{subsToPlot(sub)}(finger) < 0.05
            text(finger,0.8*(maxTMax-maxTMin)+maxTMin,'*','FontSize',30)
        end
    end
    setType()    
    ylabel('MCP torque')
    yticks(0:100:1000)    
    ylim([maxTMin, maxTMax])
end

function setType()
    xticks([1 2 3])
    xticklabels({'index','middle','both'})    
    xtickangle(45)      
end

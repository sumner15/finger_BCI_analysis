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
            relevantInds = intersect(fingerInds{finger},targetInds{target});
            
            % create values for barAnovas (does not save)
            latencyVerbose{sub,finger,target} = phase3Table.latency(relevantInds); 
            maxTVerbose{sub,finger,target} = phase3Table.maxT(relevantInds); 
            maxTLatVerbose{sub,finger,target} = phase3Table.latMaxT(relevantInds);
            
            % get mean movement measure values            
            latency{sub}(finger,target) = ...
                mean(phase3Table.latency(relevantInds))/1000;
            maxT{sub}(finger,target) = ...
                mean(phase3Table.maxT(relevantInds));            
            latMaxT{sub}(finger,target) = ...
                mean(phase3Table.latMaxT(relevantInds));
            % get std of movement measure values
            latencySTD{sub}(finger,target) = ...
                std(phase3Table.latency(relevantInds))/1000;
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
    
    % normalize torque values
    if sum(isnan(maxT{sub}(:)))==0
        maxT{sub} = maxT{sub}/max(phase3Table.maxT);
        maxTSTD{sub} = maxTSTD{sub}/max(phase3Table.maxT);
    end
end
cd(startDir);

%% load phase 3 power results
T = load('clinicalDataSimple.mat'); T = T.clinicalDataSimple;
T = sortrows(T,'RowNames');
T.phase3PowerMeanY = abs(T.phase3PowerMeanY);
T.phase3PowerMeanB = abs(T.phase3PowerMeanB);
T.phase3PowerSTDY = T.phase3PowerSTDY.*sign(T.phase3PowerMeanY);
T.phase3PowerSTDB = T.phase3PowerSTDB.*sign(T.phase3PowerMeanB);

%% plot results
subsToPlot = [1 6 7 8];
% subsToPlot = 1:8;
nSubsPlot = length(subsToPlot);
set(figure,'Position',[50 0 1200 900]);  
set(0,'defaultAxesFontSize',15)
set(0,'DefaultAxesFontName','Arial')
for sub = 1:nSubsPlot
    %% plot power        
    powY = T.phase3PowerMeanY(subsToPlot(sub));
    powB = T.phase3PowerMeanB(subsToPlot(sub));
    stdY = T.phase3PowerSTDY(subsToPlot(sub));
    stdB = T.phase3PowerSTDB(subsToPlot(sub));
    
    subplot(nSubsPlot,5,5*(sub-1)+1)
    bar(1, powY+stdY,0.05,'FaceColor', [0 0 0]);
    hold on    
    bar(1, powY,0.25,'FaceColor', [1 0.85 0]);
    bar(2, powB+stdB,0.05,'FaceColor', [0 0 0]);
    bar(2, powB,0.25,'FaceColor', [0 0.4 0.65]);
    if T.phase3ANOVAp(subsToPlot(sub)) < 0.05
        text(1.4,1.1*(max([powY powB])+max([stdY stdB])),'*','FontSize',30)
    end
    xticks([1 2])
    xticklabels({'up','down'})        
%     ylabel('SMR power')
    if sign(powY)==1
        ylim([0 1.3*max([powY+stdY powB+stdB])])
    elseif sign(powY)==-1
        ylim([1.3*min([powY+stdY powB+stdB]) 0])
    end
    if sub==1
        title('EEG Feature')
    end
    
    %% plot latency
    latMin = min(min(latency{subsToPlot(sub)}))-...
        max(max(latencySTD{subsToPlot(sub)}));
    latMax = max(max(latency{subsToPlot(sub)}))+...
        2*max(max(latencySTD{subsToPlot(sub)}));
    subplot(nSubsPlot,5,[5*(sub-1)+2 5*(sub-1)+3])
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
%     ylabel('latency (ms)')
    yticks([0 0.5 0.75 1 1.25 1.5])
    ytickangle(30)
    ylim([latMin, latMax])
    if sub==1
        title('Latency (s)')
    end
    
    %% plot max T
    maxTMin = max(min(min(maxT{subsToPlot(sub)}))-...
        max(max(maxTSTD{subsToPlot(sub)})),0);
    maxTMax = max(max(maxT{subsToPlot(sub)}))+...
        2*max(max(maxTSTD{subsToPlot(sub)}));
    subplot(nSubsPlot,5,[5*(sub-1)+4 5*(sub-1)+5])
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
%     ylabel('MCP torque')
    yticks([0 1])   
    ylim([0 1])
    if sub==1
        title('MCP Torque')
    end
end

function setType()
    xticks([1 2 3])
    xticklabels({'index','middle','both'})    
    xtickangle(30)      
end

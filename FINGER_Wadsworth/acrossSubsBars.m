% across subjects stats
% must run phase3_stats to populate workspace! 

pVals = [1 1 1]; % index middle both (yellow vs. blue) 

%% rearrange data
latData = NaN(3,2,8);               % initialize to finger x cond x sub
for i = 1:8
    latData(:,:,i) = latency{i};    % get data out of cell array -> array
end
latData = latData(:,:,[1 6 7 8]);   % subs of interest


%% get p values
for finger = index:both
    y = reshape(latData(finger,1,:),[1 4]);
    b = reshape(latData(finger,2,:),[1 4]);
    
    % blocking (dLatency - each subject) tests b-y instead of b vs. y    
    [~,pVals(finger)] = ttest(b-y);
end
fprintf('p-values (Y vs. B), index: %1.3f, middle %1.3f, both: %1.3f\n',...
    pVals(1),pVals(2),pVals(3));

%% get mean values for plotting
barMeans = mean(latData,3);
barStds = std(latData,0,3);        

%% plot results
% subsToPlot = 1:8;
nSubsPlot = length(subsToPlot);
set(figure,'Position',[100 20 700 500]);  
set(0,'defaultAxesFontSize',20)

% plot latency
for finger = index:both
    bar(finger-0.2,barMeans(finger,1)+barStds(1,1),0.05,'FaceColor', [0 0 0]);
    hold on       
    bar(finger-0.2,barMeans(finger,1),0.25,'FaceColor', [1 0.85 0]);
    bar(finger+0.2,barMeans(finger,2)+barStds(1,2),0.05,'FaceColor', [0 0 0]);
    bar(finger+0.2,barMeans(finger,2),0.25,'FaceColor', [0 0.4 0.65]);
    
    if pVals(finger) < 0.05
        textYPos = max(barMeans(finger,:))+max(barStds(finger,:))*1.2;
        text(finger-0.1,textYPos,'*','FontSize',45)
    end       
end

xticks([1 2 3])
xticklabels({'index','middle','both'})    
xtickangle(45)      
ylabel('latency (ms)')
yticks([0 500 750 1000 1250 1500])    
ylim([500 1500])

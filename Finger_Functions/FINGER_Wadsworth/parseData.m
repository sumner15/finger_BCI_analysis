%calls datToMat to parse data from BCI2000 Wadsworth BCI study
clear

subname = 'BRAA';
session = 'BRAA003';
runNames = {'1','2','3','4','5','6','7','8'};
runs = length(runNames);

try 
    if ispc
        cd 'C:\Users\Sumner\Dropbox\UCI RESEARCH\FINGER\FINGER_wadsworth\Data\'
    else
        cd '/Users/Sum/Dropbox/UCI RESEARCH/FINGER/FINGER_wadsworth/Data/'        
    end
    startDir = pwd;
    cd(subname)
    cd(session)
    data = datToMat(subname,runs);
    cd(startDir)
catch me
    error('Could not find data set or could not load')
end

for run = 1:runs
    %loading data into more usable format
    data.pos{run} = double([data.state{1,run}.FRobotPos1 ...
                            data.state{1,run}.FRobotPos2]);
    data.force{run} = double([data.state{1,run}.FRobotForceF1 ...                                                            
                              data.state{1,run}.FRobotForceF2]);                                     
                             
    %normalizing data for easier plotting
    data.pos{run}(data.pos{run}>2000) = 0;    
    data.posNorm{run} = data.pos{run}/max(data.pos{run}(:));
    data.forceNorm{run} = data.force{run}/max(data.force{run}(:));    
end

%% plot force traces and correlation coeffs for all runs
close all

set(figure,'Position',[50 0 300*runs 500])
for run = 1:runs   
    subplot(2,runs,run)
    sample = 1:size(data.force{run},1);
    hold on
%     plot(sample,data.pos{run}(:,1),'--',...
%          sample,data.pos{run}(:,2),'--','LineWidth',2);
    plot(sample,data.posNorm{run}(:,1),'--',...
         sample,data.posNorm{run}(:,2),'--','LineWidth',2);
%     plot(sample,data.force{run}(:,1),...                  
%          sample,data.force{run}(:,2),'LineWidth',3);  
    plot(sample,data.forceNorm{run}(:,1),...                  
         sample,data.forceNorm{run}(:,2),'LineWidth',3);  
    set(gca,'xtick',[]); 
    xlabel('time')
    ylabel('Force')
    legend('Pos1','Pos2','F1','F2','Location','SouthWest')
    title(['Run ' num2str(run) ': ' runNames{run}])

    subplot(2,runs,runs+run)
    imagesc(corrcoef([data.pos{run} data.force{run}]),[0 1])
    colorbar
    title('corr. coef. matrix')    
    xticks(1:4)
    yticks(1:4)
    xticklabels({'Pos1','Pos2','F1','F2'})
    yticklabels({'Pos1','Pos2','F1','F2'})    
    colormap autumn
end

%% plot first run data traces (raw and normalized)
run = 1;
sample = 1:size(data.force{run},1);

set(figure,'Position',[50 0 1600 700])
subplot(121)    
hold on
plot(sample,data.pos{run}(:,1),'--',...
     sample,data.pos{run}(:,2),'--','LineWidth',2);    
plot(sample,data.force{run}(:,1),...                  
     sample,data.force{run}(:,2),'LineWidth',3);  
 set(gca,'xtick',[]); 
xlabel('time')
ylabel('raw amplitude')
legend('Pos1','Pos2','F1','F2','Location','SouthWest')
title(['Run ' num2str(run) ': ' runNames{run}])
     
subplot(122)
hold on
plot(sample,data.posNorm{run}(:,1),'--',...
     sample,data.posNorm{run}(:,2),'--','LineWidth',2);
plot(sample,data.forceNorm{run}(:,1),...                  
     sample,data.forceNorm{run}(:,2),'LineWidth',3); 
     set(gca,'xtick',[]); 
xlabel('time')
ylabel('force & position (normalized)')
legend('Pos1','Pos2','F1','F2','Location','SouthWest')
title(['Run ' num2str(run) ': ' runNames{run}])

%% plot results separately
run = 1;
sample = 10:size(data.force{run},1);
time = sample/256;

set(figure,'Position',round((get(groot, 'Screensize' )+59)*0.833))
subplot(411)    
plot(time,data.pos{run}(10:end,1),'--','LineWidth',2);  
xlabel('time (s)')
ylabel('Pos 1')
subplot(412)    
plot(time,data.pos{run}(10:end,2),'--','LineWidth',2);   
xlabel('time (s)')
ylabel('Pos 2')
subplot(413)    
plot(time,data.force{run}(10:end,1),'LineWidth',3);  
xlabel('time (s)')
ylabel('Force 1')
subplot(414)    
plot(time,data.force{run}(10:end,2),'LineWidth',3); 
xlabel('time (s)') 
ylabel('Force 2')   
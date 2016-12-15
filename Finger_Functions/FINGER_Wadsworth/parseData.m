%calls datToMat to parse data from BCI2000 Wadsworth BCI study
clear
startDir = pwd;

subname = 'combForces';
runNames = {'move only','force only'};
runs = length(runNames);

try 
    if ispc
        cd 'C:\Users\Sumner\Dropbox\UCI RESEARCH\FINGER\FINGER_wadsworth\DenniShare\force_transducer_test_data\'
    else
        cd '/Users/Sum/Dropbox/UCI RESEARCH/FINGER/FINGER_wadsworth/DenniShare/force_transducer_test_data/'
    end
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
    data.forceNorm{run} = data.force{run}/max(data.force{run}(:));    
end

%% plot force traces
close all

set(figure,'Position',[100 50 400*runs 500])
for run = 1:runs   
    subplot(2,runs,run)
    sample = 1:size(data.force{run},1);
    hold on
    plot(sample,data.pos{run}(:,1),'--',...
         sample,data.pos{run}(:,2),'--','LineWidth',2);
    plot(sample,data.force{run}(:,1),...                  
         sample,data.force{run}(:,2),'LineWidth',3);                  
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

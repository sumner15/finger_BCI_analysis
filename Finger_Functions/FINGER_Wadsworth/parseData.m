%calls datToMat to parse data from BCI2000 Wadsworth BCI study
clear
startDir = pwd;

% subname = 'Distal';
% runNames = {'Flexion','Extension','Extension'};
% subname = 'Prox';
% runNames = {'Flexion','Extension'};
% subname = 'force_noMove';
% runNames = {'No Movement', 'Kp=0'};
subname = 'moveOnly';
runNames = {'move only (no force)','index only','middle only'};
runs = length(runNames);

try 
%     cd 'C:\Users\Sumner\Dropbox\UCI RESEARCH\FINGER\FINGER_wadsworth\Data'
    if ispc
        cd 'C:\Users\Sumner\Dropbox\UCI RESEARCH\FINGER\FINGER_wadsworth\DenniShare'
    else
        cd '/Users/Sum/Dropbox/UCI RESEARCH/FINGER/FINGER_wadsworth/DenniShare'
    end
    data = datToMat(subname,runs);
    cd(startDir)
catch me
    error('Could not find data set or could not load')
end

for run = 1:runs
    data.force{run} = double([data.state{1,run}.FRobotForceF1a ... 
                              data.state{1,run}.FRobotForceF1b ...
                              data.state{1,run}.FRobotForceF2a ...
                              data.state{1,run}.FRobotForceF2b]);
    data.forceEst{run} = double([data.state{1,run}.FRobotForce1 ... 
                                 data.state{1,run}.FRobotForce2]);                                
    data.forceEst{run}(data.forceEst{run}>100) = 0;
    data.forceNorm{run} = data.force{run}/max(data.force{run}(:));
    data.forceEstNorm{run} = data.forceEst{run}/max(data.forceEst{run}(:));
    data.forceEstNorm{run} = data.forceEstNorm{run}*max(data.force{run}(:));
end

%% plot force traces
close all

set(figure,'Position',[100 50 400*runs 500])
for run = 1:runs   
    subplot(2,runs,run)
    sample = 1:size(data.force{run},1);
    hold on
    plot(sample,data.force{run}(:,1),...
         sample,data.force{run}(:,2),...
         sample,data.force{run}(:,3),...
         sample,data.force{run}(:,4),'LineWidth',5);    
    plot(sample,data.forceEstNorm{run}(:,1),'--',...
         sample,data.forceEstNorm{run}(:,2),'--','LineWidth',1.6);
    set(gca,'xtick',[]); 
    xlabel('time')
    ylabel('Force')
    legend('F1a','F1b','F2a','F2b','F1 est','F2 est','Location','Best')
    title(['Run ' num2str(run) ': ' runNames{run}])

    subplot(2,runs,runs+run)
    imagesc(corrcoef(data.force{run}),[0 1])
    colorbar
    title('corr. coef. matrix')
    xticklabels({'F1a','F1b','F2a','F2b'});
    yticklabels({'F1a','F1b','F2a','F2b'});
    
end

function plotYvsB()
    %% load data
    disp('plotting all phase 3 movement data')    
    fprintf('progress ')
    
    if nargin==0
        startDir = dataDirectory();
        data = load('traces.mat');
        cd(startDir);      
    end
    
    %% call plotting functions
    plotAway(data.tracesYellow, data.tracesBlue, data)
    plotAway(data.tausYellow, data.tausBlue, data)

%% plot data
function plotAway(yellowData, blueData, data)
    disp('         ||||||||||||||||||||||||')
    set(figure,'Position',[100 20 2000 1100]);            
    for finger = 1:3        
        for sub = 1:data.nSubs
            % create time vector
            t = (1:size(yellowData{sub,finger},2))/256;
            
            % set subplot
            subplot(3,data.nSubs,data.nSubs*(finger-1)+sub)
            fprintf('|')
            
            % normalize data to max of 1
            yellowData{sub,finger} = ...
                yellowData{sub,finger}./max(yellowData{sub,finger}(:));
            blueData{sub,finger} = ...
                blueData{sub,finger}./max(blueData{sub,finger}(:));
            
            for i = 1:size(yellowData{sub,finger},1)
                % plot all yellow traces
                hY = plot(t,yellowData{sub,finger}(i,:)',...
                    'color', [1 0.85 0], 'linewidth', 1.5);
                hY.Color(:,4) = 0.3;
                hold on            
                % plot mean of yellow traces
                plot(t,mean(yellowData{sub,finger},1),...
                    'color', [1 0.85 0], 'linewidth', 2);
                % plot all blue traces
                hB = plot(t,blueData{sub,finger}(i,:)',...
                    'color', [0 0.4 0.65], 'linewidth', 1.5);
                hB.Color(:,4) = 0.3;
                % plot mean of blue traces
                plot(t,mean(blueData{sub,finger},1),...
                    'color', [0 0.4 0.65], 'linewidth', 2);
            end
            
            setType(t,sub,data.subjects,finger)
        end
    end    
    fprintf('\n')
end

%% function to set type
function setType(t,sub,subjects,finger)
    set(findall(gcf,'-property','FontSize'),'FontSize',14)
    fingerStrings = {'index','middle','both'};
    title(subjects{sub})          
    if sub==1
        ylabel(fingerStrings(finger))
    end
    
    xlim([0 t(end)])
    xticks([0 0.5 1.0 1.5])
    xticklabels({'0','0.5','1.0','1.5'})
    yticks([-0.95 0.00 0.95])
    yticklabels({'flexed','','extended'})
end

end
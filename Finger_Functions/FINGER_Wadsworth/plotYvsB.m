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
    plotAway(data.tracesYellow1, data.tracesBlue1,...
             data.tracesYellow2, data.tracesBlue2, data)
    plotAway(data.tausYellow1, data.tausBlue1, ...
             data.tausYellow2, data.tausBlue2, data)

%% plot data
function plotAway(yellowData, blueData, orangeData, purpleData, data)
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
            orangeData{sub,finger} = ...
                orangeData{sub,finger}./max(orangeData{sub,finger}(:));
            purpleData{sub,finger} = ...
                orangeData{sub,finger}./max(purpleData{sub,finger}(:));
            
            for i = 1:size(yellowData{sub,finger},1)
                % plot all yellow traces
                hY = plot(t,yellowData{sub,finger}(i,:)',...
                    'color', [1 0.85 0], 'linewidth', 1.5);
                hY.Color(:,4) = 0.3;
                hold on            
                % plot all orange traces (secondary finger)
                hO = plot(t,orangeData{sub,finger}(i,:)',...
                    'color', [0.85 0.3 1], 'lineWidth', 1.5);
                hO.Color(:,4) = 0.3;
                % plot all blue traces
                hB = plot(t,blueData{sub,finger}(i,:)',...
                    'color', [0 0.4 0.65], 'linewidth', 1.5);
                hB.Color(:,4) = 0.3;
                % plot all purple traces (secondary finger)
                hP = plot(t,purpleData{sub,finger}(i,:)',...
                    'color', [0.5 0.2 0.6], 'lineWidth', 1.5);
                hP.Color(:,4) = 0.3;
                
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
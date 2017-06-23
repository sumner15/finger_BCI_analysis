function plotYvsB()
    %% load data
    disp('plotting all phase 3 movement data')    
    fprintf('progress ||||||||||||||||||||||||\n')
    
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
    fprintf('         ')
    set(figure,'Position',[100 20 2000 1100]);            
    for finger = 1:3        
        for sub = 1:data.nSubs
            % create time vector
            t = (1:size(yellowData{sub,finger},2))/256;
            
            % set subplot
            subplot(3,data.nSubs,data.nSubs*(finger-1)+sub)
            fprintf('|')
            
            % normalize data to max of 1
            maxY = max(abs(yellowData{sub,finger}(:)));
            maxB = max(abs(blueData{sub,finger}(:)));
            maxO = max(abs(orangeData{sub,finger}(:)));
            maxP = max(abs(purpleData{sub,finger}(:)));
            maxVal = max([maxY maxB maxO maxP]);
            yellowData{sub,finger} = yellowData{sub,finger}./maxVal;
            blueData{sub,finger} = blueData{sub,finger}./maxVal;
            orangeData{sub,finger} = orangeData{sub,finger}./maxVal;
            purpleData{sub,finger} = purpleData{sub,finger}./maxVal;
            
            for i = 1:size(yellowData{sub,finger},1)
                % plot all yellow traces
                hY = plot(t,yellowData{sub,finger}(i,:)',...
                    'color', [1 0.85 0], 'linewidth', 1.5); 
                hY.Color(:,4) = 0.3;
                hold on            
               % plot all orange traces (secondary finger)
                hO = plot(t,orangeData{sub,finger}(i,:)',...
                    'color', [1 0.4 0.4], 'lineWidth', 1.5);                
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
            
            % set axis limits based on data 
            if min(yellowData{sub,finger}(:))<0
                axisLims = [0 t(end) -1 1];
            else
                axisLims = [0 t(end) 0 1];
            end
            
            % set axes type
            setType(sub,data.subjects,finger,axisLims)
        end
    end    
    fprintf('\n')
end

%% function to set type
function setType(sub,subjects,finger,axisLims)
    set(findall(gcf,'-property','FontSize'),'FontSize',14)
    fingerStrings = {'index','middle','both'};
    title(subjects{sub})          
    if sub==1
        ylabel(fingerStrings(finger))
    end
    
    axis(axisLims)
    xticks([0 0.5 1.0 1.5])
    xticklabels({'0','0.5','1.0','1.5'})
    yticks(axisLims(3:4))
    yticklabels({'flexed','extended'})
end

end
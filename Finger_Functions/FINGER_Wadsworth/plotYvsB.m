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
    % plot movement traces & torque traces for both fingers
    plotAway(data, data.tracesYellow1, data.tracesBlue1,...
                   data.tracesYellow2, data.tracesBlue2)
    plotAway(data, data.tausYellow1, data.tausBlue1, ...
                   data.tausYellow2, data.tausBlue2)
    % plot movement traces & torque traces for the target finger only
    plotAway(data, data.tracesYellow1, data.tracesBlue1)
    plotAway(data, data.tausYellow1, data.tausBlue1)
    % plot individuation traces 
    plotAway(data, data.posIndYellow, data.posIndBlue)
    plotAway(data, data.tauIndYellow, data.tauIndBlue)

%% plot data
function plotAway(data, yellowData, blueData, orangeData, purpleData)
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
            if exist('orangeData','var') && exist('purpleData','var')
                maxVal = getMaxVal(sub,yellowData,blueData,orangeData,purpleData);
                orangeData{sub,finger} = orangeData{sub,finger}./maxVal;
                purpleData{sub,finger} = purpleData{sub,finger}./maxVal;
            else
                maxVal = getMaxVal(sub,yellowData,blueData);
            end
            yellowData{sub,finger} = yellowData{sub,finger}./maxVal;
            blueData{sub,finger} = blueData{sub,finger}./maxVal;   
         
            
            % HERE COMES THE PLOTTING
            for i = 1:size(yellowData{sub,finger},1)
                % plot all yellow traces
                hY = plot(t,yellowData{sub,finger}(i,:)',...
                    'color', [1 0.85 0], 'linewidth', 1.5); 
                hY.Color(:,4) = 0.3;
                hold on            
                % plot all blue traces
                hB = plot(t,blueData{sub,finger}(i,:)',...
                    'color', [0 0.4 0.65], 'linewidth', 1.5);
                hB.Color(:,4) = 0.3;
                
                if exist('orangeData','var') && exist('purpleData','var')
                    % plot all orange traces (secondary finger)
                    hO = plot(t,orangeData{sub,finger}(i,:)',...
                        'color', [1 0.4 0.4], 'lineWidth', 1.5);                
                    hO.Color(:,4) = 0.3;
                    % plot all purple traces (secondary finger)
                    hP = plot(t,purpleData{sub,finger}(i,:)',...
                        'color', [0.5 0.2 0.6], 'lineWidth', 1.5);
                    hP.Color(:,4) = 0.3;                
                end
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

%% function to get the maximum data value for this subject, across fingers
function maxVal = getMaxVal(sub,yellowData,blueData,orangeData,purpleData)
    [maxVal,maxY,maxB,maxO,maxP] = deal(0);
    for finger = 1:3
        maxY = max([maxY; max(abs(yellowData{sub,finger}(:)))]);
        maxB = max([maxB; max(abs(blueData{sub,finger}(:)))]);
        if exist('orangeData','var') && exist('purpleData','var')
            maxO = max([maxO; max(abs(orangeData{sub,finger}(:)))]);
            maxP = max([maxP; max(abs(purpleData{sub,finger}(:)))]);
            maxVal = max([maxVal; max([maxY maxB maxO maxP])]);
        else
            maxVal = max([maxVal max([maxY maxB])]);
        end         
    end
end

end
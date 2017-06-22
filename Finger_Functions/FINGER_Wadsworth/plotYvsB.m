function plotYvsB(tracesYellow,tracesBlue)
    %% load data
    disp('plotting all phase 3 movement data')
    disp('         ||||||||||||||||||||||||')
    fprintf('progress ')
    if nargin==0
        startDir = dataDirectory();
        load traces.mat
        cd(startDir);
    end            

    %% plot data
    set(figure,'Position',[100 20 2000 1100]);            
    for finger = 1:3        
        for sub = 1:nSubs
            % create time vector
            t = (1:size(tracesYellow{sub,finger},2))/256;
            
            % set subplot
            subplot(3,nSubs,nSubs*(finger-1)+sub)
            fprintf('|')
            
            for i = 1:size(tracesYellow{sub,finger},1)
                % plot all yellow traces
                hY = plot(t,tracesYellow{sub,finger}(i,:)',...
                    'color', [1 0.85 0], 'linewidth', 1.5);
                hY.Color(:,4) = 0.3;
                hold on            
                % plot mean of yellow traces
                plot(t,mean(tracesYellow{sub,finger},1),...
                    'color', [1 0.85 0], 'linewidth', 2);
                % plot all blue traces
                hB = plot(t,tracesBlue{sub,finger}(i,:)',...
                    'color', [0 0.4 0.65], 'linewidth', 1.5);
                hB.Color(:,4) = 0.3;
                % plot mean of blue traces
                plot(t,mean(tracesBlue{sub,finger},1),...
                    'color', [0 0.4 0.65], 'linewidth', 2);
            end
            
            setType(t,sub,subjects,finger)
        end
    end    
    fprintf('\n')
end

function setType(t,sub,subjects,finger)
    set(findall(gcf,'-property','FontSize'),'FontSize',14)
    fingerStrings = {'index','middle','both'};
    title(subjects{sub})          
    if sub==1
        ylabel(fingerStrings(finger))
    end
    
    axis([0 t(end) 0 900])
    xticks([0 0.5 1.0 1.5])
    xticklabels({'0','0.5','1.0','1.5'})
    yticks([50 850])
    yticklabels({'flexed','extended'})
end
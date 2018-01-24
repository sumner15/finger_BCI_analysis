% testing for interaction effects on bar plots       
% YOU MUST RUN PHASE3_STATS TO POPULATE THE WORKSPACE!!! 
warning('did you run phase3_stats first?')
warning('did you comment one of the blocks out?')

fingerTitles = {'index','middle','both'};
targetTitles = {'yellow','blue'};
      
% maxTVerbose{sub,finger,target}
[data, gFinger, gTarget] = deal(cell(1,8));
for sub = 1:8
    data{sub} = [];
    gFinger{sub} = [];
    
    for finger = 1:3
        for target = 1:2
            %comment one of the following blocks out!!            
            
            % analyzing maximum torque
            data{sub} = [data{sub} ; maxTVerbose{sub,finger,target}];
            newDL = length(maxTVerbose{sub,finger,target});

            % analyzing latency
%             data{sub} = [data{sub} ; latencyVerbose{sub,finger,target}];
%             newDL = length(latencyVerbose{sub,finger,target});
            
            % leave this block alone
            newdata = repmat(fingerTitles(finger), [newDL 1]);
            gFinger{sub} = [gFinger{sub} ; newdata];
            newdata = repmat(targetTitles(target), [newDL 1]);
            gTarget{sub} = [gTarget{sub} ; newdata];
        end
    end
end

%% within subjects anova analysis
for sub = [1 6 7 8]
    subData = data{sub};
    subTarget = gTarget{sub}; %target labels
    subFinger = gFinger{sub}; %finger labels
    
    % interactions
    p = anovan(subData, {subTarget,subFinger},...
        'model','interaction','varnames',{'target','finger'});   
end

%% across subject analysis
allData = [];
[allTarget, allFinger] = deal({});

allSubs = [1 2 4 5 6 7 8];

for sub = allSubs
    allData = [allData ; data{sub}];
    allTarget = [allTarget ; gTarget{sub}];
    allFinger = [allFinger ; gFinger{sub}];
end
    
p = anovan(allData, {allTarget,allFinger},...
    'model','interaction','varnames',{'target','finger'});
    


                
                

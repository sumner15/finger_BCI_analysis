% testing for interaction effects on bar plots       
% YOU MUST RUN PHASE3_STATS TO POPULATE THE WORKSPACE!!! 
load 

fingerTitles = {'index','middle','both'};
targetTitles = {'yellow','blue'};
      
% maxTVerbose{sub,finger,target}
[data, gFinger, gTarget] = deal(cell(1,8));
for sub = 1:8
    data{sub} = [];
    gFinger{sub} = [];
    
    for finger = 1:3
        for target = 1:2
            data{sub} = [data{sub} ; maxTVerbose{sub,finger,target}];
            newDL = length(maxTVerbose{sub,finger,target});
            newdata = repmat(fingerTitles(finger), [newDL 1]);
            gFinger{sub} = [gFinger{sub} ; newdata];
            newdata = repmat(targetTitles(target), [newDL 1]);
            gTarget{sub} = [gTarget{sub} ; newdata];
        end
    end
end

% something like...
for sub = [1 6 7 8]
    subData = data{sub};
    subTarget = gTarget{sub};
    subFinger = gFinger{sub};   
    
    % interactions
    p = anovan(subData, {subTarget,subFinger},'model','interaction','varnames',{'target','finger'})    
end

            
                
                

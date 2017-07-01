%this script compiles semi-processed data into .csv format for Dennis

clear; clc; close all
subjects = {'MCCL','VANT','MAUA','HATA','PHIC','CHEA','RAZT','TRUL'};
nSubs = length(subjects);
startDir = pwd;

for sub = 1:nSubs
    subID = subjects{sub};
    disp(['Processing data for ' subID])    
    
    sessionTable = cell(1,3);
    for session = 1:3        
        sessionTable{session} = createTableFromSession(subID,session+9);
    end
    phase3Table = [sessionTable{1}; sessionTable{2}; sessionTable{3}];   
    
    phase3Table = reformat(phase3Table);
        
    dataDirectory();           
    writetable(phase3Table,['phase3_' subID '.csv'],'Delimiter',',')
    disp(['Saved as phase3_' subID '.csv'])
    
    save(['phase3_' subID],'phase3Table')  
    disp(['Saved as phase3_' subID '.mat'])
end


savePath = dataDirectory(true);
disp('=============== COMPLETE ===============')
disp(['data saved at ' savePath])

function tableOut = reformat(tableIn)  
    [nTrials, nMeasures] = size(tableIn);
    [latency, maxT, minT, latMaxT] = deal(NaN(nTrials,1));
    [finger, target] = deal(cell(nTrials,1));
    successfulTrial = 0;
    for trial = 1:nTrials
        % if there is data for this trial
        if sum(isnan(tableIn{trial,:})) < nMeasures
            successfulTrial = successfulTrial+1;
            % get finger & target code
            [~, measuredInds] = find(isnan(tableIn{trial,:})==0);
            codes = tableIn.Properties.VariableNames{measuredInds(1)}(end-1:end);
            % save out target
            if codes(1)=='Y'
                target{successfulTrial} = 'yellow';
            elseif codes(1)=='B'
                target{successfulTrial} = 'blue';
            end
            % save out finger
            if codes(2)=='I'
                finger{successfulTrial} = 'index';
            elseif codes(2)=='M'
                finger{successfulTrial} = 'middle';
            elseif codes(2)=='B'
                finger{successfulTrial} = 'both';
            end
            % save out movement measures            
            for i = 1:length(measuredInds)
                measureCode = tableIn.Properties.VariableNames{measuredInds(i)}(1:4);
                if strcmp(measureCode,'late')
                    latency(successfulTrial) = tableIn{trial,measuredInds(i)};
                elseif strcmp(measureCode,'maxT')
                    maxT(successfulTrial) = tableIn{trial,measuredInds(i)};
                elseif strcmp(measureCode,'minT')
                    minT(successfulTrial) = tableIn{trial,measuredInds(i)};
                elseif strcmp(measureCode,'latM')
                    latMaxT(successfulTrial) = tableIn{trial,measuredInds(i)};
                end
            end
        end
    end
    latency(isnan(latency)) = [];
    maxT(isnan(maxT)) = [];
    minT(isnan(minT)) = [];    
    latMaxT(isnan(latMaxT)) = [];
    finger = finger(~cellfun('isempty',target));
    target = target(~cellfun('isempty',target));
    tableOut = table(latency,maxT,minT,latMaxT,finger,target);
end
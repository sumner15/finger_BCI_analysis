%calls datToMat to parse data from BCI2000 Wadsworth BCI study and stores
%the results in a table 
%
% function dependencies:
% getERD(), getHitRate(), getMaxF()


clear; clc; close all 
subjects = {'CHEA','VANT','TRUL','RAZT','MCCL','PHIC','HATA','MAUA'};
subjects = {'CHEA'};   
nSubs = length(subjects);
startDir = pwd;

%% set up cell arrays for data
yellow = 1; blue = 2;
index = 1; middle = 2; both = 3;
[tracesYellow, tracesBlue, tausYellow, tausBlue] = deal(cell(nSubs,3));

%% for each subject 
for sub = 1:nSubs              
    %% create session and run strings
    disp(['Processing data for ' subjects{sub}])
    subID = subjects{sub};      
    
    for finger = index:both
        [tracesY, tracesB, tausY, tausB] =...
            deal(cell(1,3)); %reset on each finger
        
        for session = 10:12            
            %% load data into mat format
            sessionString = [subID '0' num2str(session)];
            dataDirectory();
            cd(sessionString);
            data = datToMat(subID);    

            %% extract movement data            
            tracesY{session-9} = getMoveTrace(data, session, yellow, finger);   
            tracesB{session-9} = getMoveTrace(data, session, blue, finger);   
            tausY{session-9} = getForceTrace(data, session, yellow, finger);
            tausB{session-9} = getForceTrace(data, session, blue, finger);           
            
        end
        tracesYellow{sub,finger} = [tracesY{1}; tracesY{2}; tracesY{3}];
        tracesBlue{sub,finger} = [tracesB{1}; tracesB{2}; tracesB{3}];        
        tausYellow{sub, finger} = [tausY{1}; tausY{2}; tausY{3}];
        tausBlue{sub, finger} = [tausB{1}; tausB{2}; tausB{3}];        
    end
end

%% save and plot results 
cd(startDir);

saveBool = input('Would you like to save the results? (y/n): ','s');
if strcmp(saveBool,'y')
    dataDirectory();
    disp('Saving to traces.mat')
    save('traces','tracesYellow','tracesBlue','tausYellow','tausBlue',...
        'subjects','nSubs');
    cd(startDir)
end

plotYvsB()




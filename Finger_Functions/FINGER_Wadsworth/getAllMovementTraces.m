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
[tracesYellow1, tracesBlue1, tracesYellow2, tracesBlue2, ...
    tausYellow1, tausBlue1, tausYellow2, tausBlue2] = ...
    deal(cell(nSubs,3));

%% for each subject 
for sub = 1:nSubs              
    %% create session and run strings
    disp(['Processing data for ' subjects{sub}])
    subID = subjects{sub};      
    
    for finger = index:both
        [tracesY1, tracesB1, tracesY2, tracesB2, ... 
            tausY1, tausB1, tausY2, tausB2] =...
            deal(cell(1,3)); 
        
        for session = 10:12            
            %% load data into mat format
            sessionString = [subID '0' num2str(session)];
            dataDirectory();
            cd(sessionString);
            data = datToMat(subID);    

            %% extract movement data            
            [tracesY1{session-9}, tracesY2{session-9}] = ...
                getMoveTrace(data, session, yellow, finger);   
            [tracesB1{session-9}, tracesB2{session-9}] = ...
                getMoveTrace(data, session, blue, finger);   
            
            [tausY1{session-9}, tausY2{session-9}] = ...
                getForceTrace(data, session, yellow, finger);
            [tausB1{session-9}, tausB2{session-9}] = ...
                getForceTrace(data, session, blue, finger);                                   
        end
        tracesYellow1{sub,finger} = [tracesY1{1}; tracesY1{2}; tracesY1{3}];
        tracesBlue1{sub,finger} = [tracesB1{1}; tracesB1{2}; tracesB1{3}];  
        tracesYellow2{sub,finger} = [tracesY2{1}; tracesY2{2}; tracesY2{3}];
        tracesBlue2{sub,finger} = [tracesB2{1}; tracesB2{2}; tracesB2{3}];
        
        tausYellow1{sub, finger} = [tausY1{1}; tausY1{2}; tausY1{3}];
        tausBlue1{sub, finger} = [tausB1{1}; tausB1{2}; tausB1{3}];        
        tausYellow2{sub, finger} = [tausY2{1}; tausY2{2}; tausY2{3}];
        tausBlue2{sub, finger} = [tausB2{1}; tausB2{2}; tausB2{3}];        
    end
end

%% save and plot results 
cd(startDir);

saveBool = input('Would you like to save the results? (y/n): ','s');
if strcmp(saveBool,'y')
    dataDirectory();
    disp('Saving to traces.mat')
    save('traces','tracesYellow1','tracesBlue1','tracesYellow2', 'tracesBlue2',...
        'tausYellow1','tausBlue1','tausYellow2','tausBlue2','subjects','nSubs');
    cd(startDir)
end

plotYvsB()




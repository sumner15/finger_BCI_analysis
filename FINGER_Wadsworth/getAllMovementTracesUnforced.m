%calls datToMat to parse data from BCI2000 Wadsworth BCI study and stores
%the results in a table 
%
% function dependencies:
% getERD(), getHitRate(), getMaxF()


clear; clc; close all 
subjects = {'CHEA','HATA','MAUA','MCCL','PHIC','RAZT','TRUL','VANT'};
% subjects = {'CHEA','RAZT','TRUL','VANT'};
nSubs = length(subjects);
startDir = pwd;

%% set up cell arrays for data
yellow = 1; blue = 2;
index = 1; middle = 2; both = 3;
[tracesYellow1, tracesYellow2, tausYellow1, tausYellow2, ...
    posIndYellow, tauIndYellow, tauIndBlue] = ...
    deal(cell(nSubs,3));

%% for each subject 
for sub = 1:nSubs              
    %% create session and run strings
    disp(['Processing data for ' subjects{sub}])
    subID = subjects{sub};      
    
    for finger = index:both
        [tracesY1, tracesB1, tracesY2, tracesB2, ... 
            tausY1, tausB1, tausY2, tausB2, ...
            posIndY, posIndB, tauIndY, tauIndB] =...
            deal(cell(1,3)); 
        
        %% data from sessions 10-12         
        for session = 10:12            
            % load data into mat format
            sessionString = [subID '1' num2str(session)];
            dataDirectory();
            cd(sessionString);
            data = datToMat(subID);    
            % load into traces 
            [tracesY1{session-9}, ~, posIndY{session-9}] = ...
                getMoveTrace(data, session, [], finger);   
            [tracesB1{session-9}, ~, posIndB{session-9}] = ...
                getMoveTrace(data, session, [], finger);   
            
            [tausY1{session-9}, ~, tauIndY{session-9}] = ...
                getForceTrace(data, session, [], finger);
            [tausB1{session-9}, ~, tauIndB{session-9}] = ...
                getForceTrace(data, session, [], finger);  
        end
        %% data from sessions 1-3 
        for session = 1:3
            % load data into mat format
            sessionString = [subID '10' num2str(session)];
            dataDirectory();
            cd(sessionString);
            data = datToMat(subID); 
            % load into traces 
            [tracesY2{session}, ~, ~] = ...
                getMoveTrace(data, session, [], finger);   
            [tracesB2{session}, ~, ~] = ...
                getMoveTrace(data, session, [], finger);   
            
            [tausY2{session}, ~, ~] = ...
                getForceTrace(data, session, [], finger);
            [tausB2{session}, ~, ~] = ...
                getForceTrace(data, session, [], finger);          
        end        
        
        %% all traces for sessions 10-12 
        tracesYellow1{sub,finger} = [tracesY1{1}; tracesY1{2}; tracesY1{3}];     
        tausYellow1{sub, finger} = [tausY1{1}; tausY1{2}; tausY1{3}];       
        % all traces for sessions 1-3
        tracesYellow2{sub,finger} = [tracesY2{1}; tracesY2{2}; tracesY2{3}];        
        tausYellow2{sub, finger} = [tausY2{1}; tausY2{2}; tausY2{3}];          
        
        % individuation traces for sessions 10-12 
        posIndYellow{sub, finger} = [posIndY{1}; posIndY{2}; posIndY{3}];                
        tauIndYellow{sub, finger} = [tauIndY{1}; tauIndY{2}; tauIndY{3}];   
        
        % all traces
        allTraces{sub,finger} = [tracesY2(1) tracesY2(2) tracesY2(3)...
                                 {[]} {[]} {[]} {[]} {[]} {[]} ...
                                 tracesY1(1) tracesY1(2) tracesY1(3)];
        allTaus{sub,finger} = [tausY2(1) tausY2(2) tausY2(3)...
                               {[]} {[]} {[]} {[]} {[]} {[]} ...
                               tausY1(1) tausY1(2) tausY1(3)];
    end
end
% non c'e "yellow vs. blue" results, but we'll duplicate to avoid errors
tracesBlue1 = tracesYellow1;
tracesBlue2 = tracesYellow2;
tausBlue1 = tausYellow1;
tausBlue2 = tausYellow2;
posIndBlue = posIndYellow;


%% save and plot results 
cd(startDir);

saveBool = input('Would you like to save the results? (y/n): ','s');
if strcmp(saveBool,'y')
    dataDirectory();
    if nSubs==8
        disp('Saving traces (grouped by day) to tracesForStats.mat')   
        save('tracesForStats','allTraces','allTaus','subjects')
    else
        disp('Saving traces (grouped by phase) to tracesUnforced.mat')
        save('tracesUnforced',...
            'tracesYellow1','tracesBlue1','tracesYellow2', 'tracesBlue2',...
            'tausYellow1','tausBlue1','tausYellow2','tausBlue2',...
            'posIndYellow','posIndBlue','tauIndYellow','tauIndBlue',...
            'subjects','nSubs');        
    end    
    cd(startDir)
end

plotYvsB('tracesUnforced.mat')



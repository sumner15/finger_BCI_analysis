% createAllSubjectTables calls on createSubjecTable function to create data
% structures for each participant and stores the results in a .mat file.

clear; clc; close all
subjects = {'CHEA','HATA','MAUA','MCCL','PHIC','RAZT','TRUL','VANT'};
nSubs = length(subjects);
startDir = pwd;

for sub = 1:nSubs
    disp(['Processing data for ' subjects{sub}])
    subData = createSubjectTable(subjects{sub});      
    dataDirectory();
    save(subjects{sub},'subData')
    disp(['Saved as ' subjects{sub} '.mat'])
end

savePath = pwd;
disp('=============== COMPLETE ===============')
disp(['data saved at ' savePath])

performancePlots()
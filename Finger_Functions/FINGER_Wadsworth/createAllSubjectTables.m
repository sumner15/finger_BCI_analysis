% createAllSubjectTables calls on createSubjecTable function to create data
% structures for each participant and stores the results in a .mat file.

clear; clc; close all
subjects = {'MCCL','VANT','MAUA','HATA','PHIC','CHEA','RAZT','TRUL'};
nSubs = length(subjects);
startDir = pwd;

for sub = 1:nSubs
    subData = createSubjectTable(subjects{sub});      
    dataDirectory()
    save(subjects{sub},'subData')
end
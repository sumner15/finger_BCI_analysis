%%                                             %%
% Main.m : Main Script                          %
%          Creates and populates structure.     %                              %
%                                               %
%                                               %
% Author: Camilo Aguilar                        %
%                                               %
% Modification History:                         %
% 01/13/15 CA Initial Version                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Main Script-Variables Definition
%%
clear;

%COMMENTS:
% excluded (missing marker): BECC (vid incomplete = 1)
% patients = {'DIAJ','NAVA','POTA','TRAT','TRAV'}

%GLOBAL VARIABLES
NEW_FS = 1000;
OLD_FS = 128;
nChans =14;
nTrials = 6;
PATIENTS = {'POTA','TRAT','DIAJ','NAVA','TRAV'};
VID_INCOMPLETE = [0 1 0 1 0];

addpath('C:\Users\Sumner\Desktop\Up_Sampling_Code');
for currentPatientNo = 1:length(PATIENTS)
    PATIENT = PATIENTS{currentPatientNo};
    DIRECTORY = ['D:\emotiv\' PATIENT '\raw_eeg_csv\'];
    cd(DIRECTORY);

    %CREATE STRUCT
    concatData.sr = NEW_FS;
    concatData.eeg = cell(1,6);
    concatData.vid = cell(1,6);

    %POPULATE STRUCT
    for trial = 1:(nTrials-VID_INCOMPLETE(currentPatientNo))
        file = [PATIENT '_' num2str(trial) '.CSV'];
        [concatData.eeg{trial} concatData.vid{trial}] = AddTrial(file, NEW_FS, OLD_FS,nChans);
    end

    if VID_INCOMPLETE(currentPatientNo) == 1
        [concatData.eeg{6} concatData.vid{6}] = AddTrial([PATIENT '_' num2str(5) '.CSV'], NEW_FS, OLD_FS,nChans);
    end

    disp('Saving concatData.mat...');
    cd .. 
    save([PATIENT '_concatData'], 'concatData');
    disp('DONE');
end
function channelSelectEnviro(username,subname)
% Manual selection of channels overlying left and right sensorimotor
% cortices. This step should be performed before wavelet analysis to speed
% wavelet computation time in large data sets.
%
% Input: 
% username = e.g. 'Sumner'
% subname = e.g. 'LASF' 
%
% uses subjects concatData file where concatData is a structure containing
% concatData.sr (sampling rate) and concatData.eeg (the signal) where:
% signal = array of signals as vectors (channel x samples)
%
%
% Outputs: 
% concatData is saved out again, now containing concatData.motorEEG where:
% motorEEG = (channel x sample) 2D array of time domain data of motor
% channels only.

%% loading data 
setPathEnviro(username,subname)

%Read in .mat file
filename = celldir([subname '*concatData.mat']);
if size(filename,1)>=2
    error('Too many concat data files!');
end 

filename{1} = filename{1}(1:end-4);
disp(['Loading ' filename{1} '...']);
load(filename{1});
disp('Done.');

%% identifying channels (based on EGI 256 saline net only!)
motorChannels = [1 2 3];

%% setting channels
concatData.motorEEG = concatData.eeg(motorChannels,:);

%% save concatenated data
disp('Saving concatenated data...');
save(strcat(subname,'_concatData'),'concatData');
disp('Done.');
end
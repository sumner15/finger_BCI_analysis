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
disp('Filtering channels for sensorimotor only');

%% loading data 
setPathEnviro(username,subname)

%Read in .mat file
filename = celldir([subname '*concatData.mat']);
filename{1} = filename{1}(1:end-4);

disp(['Loading ' filename{1} '...']);
load(filename{1});  
disp('Done.');

%% identifying channels (based on EGI 256 saline net only! - no HM applied)
motorChannels = [58 51 65 59 52 60 66 195 196 182 183 184 155 164];

%% setting channels
for i = 1:length(concatData.eeg)
    concatData.motorEEG{i} = concatData.eeg{i}(motorChannels,:);
end

%% subtracting DC offset and trend from channels
disp('Detrending Data...')
for song = 1:length(concatData.eeg)
   for channel = 1:size(concatData.eeg{song},1)
       concatData.eeg{song}(channel,:) = detrend(concatData.eeg{song}(channel,:));
   end
end
disp('Done.')

%% save concatenated data
disp('Saving topographically filtered data...');
save(strcat(subname,'_concatData'),'concatData');
disp('Done.');

end
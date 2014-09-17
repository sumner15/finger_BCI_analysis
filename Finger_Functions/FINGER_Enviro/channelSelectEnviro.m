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

fprintf(['Loading ' filename{1} '...']);
load(filename{1});  
fprintf('Done.\n');

%% identifying channels (based on EGI 256 saline net only! - no HM applied)
motorChannels = [58 51 65 59 52 60 66 195 196 182 183 184 155 164];
refChannels = [62 63 73 70 74 75 84];

%% setting channels and re-referencing
for i = 1:length(concatData.eeg)
    reference = repmat(squeeze(mean(concatData.eeg{i}(refChannels,:),1)),[length(motorChannels) 1]);
    concatData.motorEEG{i} = concatData.eeg{i}(motorChannels,:)-reference;
end

%% subtracting DC offset and trend from channels
fprintf('Detrending Data...')
for song = 1:length(concatData.eeg)
   for channel = 1:size(concatData.eeg{song},1)
       concatData.eeg{song}(channel,:) = detrend(concatData.eeg{song}(channel,:));
   end
   for channel = 1:size(concatData.motorEEG{song},1)       
       concatData.motorEEG{song}(channel,:) = detrend(concatData.motorEEG{song}(channel,:));
   end
end
fprintf('Done.\n')

%% Low pass filter
disp('Filtering Data...'); fprintf('Song Number...');
fCut = 50; %cutoff freq in Hz
for song = 1:length(concatData.eeg)
    fprintf('%i...',song);
    concatData.eeg{song} = lowPassFilter(concatData.eeg{song},fCut);
    concatData.motorEEG{song} = lowPassFilter(concatData.motorEEG{song},fCut);
end; fprintf('\n'); 

%% save concatenated data
fprintf('Saving topographically filtered data...');
save(strcat(subname,'_concatData'),'concatData');
fprintf('Done.\n');

end
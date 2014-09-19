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

%% re-referencing
refChannels = [62 63 73 70 74 75 84];
for i = 1:length(concatData.eeg)
    %reference = repmat(squeeze(mean(concatData.eeg{i}(refChannels,:),1)),[length(motorChannels) 1]);
    % common average reference... 
    reference = repmat(squeeze(mean(concatData.eeg{i}(:,:),1)),[size(concatData.eeg{i},1) 1]);
    concatData.eeg{i} = concatData.eeg{i} - reference;
end

%% subtracting DC offset and trend from channels
fprintf('Detrending Data...')
for song = 1:length(concatData.eeg)
   for channel = 1:size(concatData.eeg{song},1)
       concatData.eeg{song}(channel,:) = detrend(concatData.eeg{song}(channel,:));
   end
end
fprintf('Done.\n')

%% Low pass filter
disp('Filtering Data...'); fprintf('Song Number...');
fCut = 50; %cutoff freq in Hz
for song = 1:length(concatData.eeg)
    fprintf('%i...',song);
    concatData.eeg{song} = lowPassFilter(concatData.eeg{song},fCut);    
end; fprintf('\n'); 

%% LAPLACIAN FILTER
% load egihc256hm
% 
% % Save X, Y, Z locations of EEG channels
% X = EGIHC256.Electrode.CoordOnSphere(:,1);
% Y = EGIHC256.Electrode.CoordOnSphere(:,2);
% Z = EGIHC256.Electrode.CoordOnSphere(:,3);
% 
% % Apply surface Laplacian
% SL = concatData.eeg{1}; % easy preallocation
% [SL,G,H] = laplacian_perrinX(concatData.eeg{1},X,Y,Z,10,1e-5);
% 
% % Make a movie of original data next to SL result
% figure
% index = 1;
% for i=1:1024:20480 % 10 seconds, 1s increments
%     subplot(121); corttopo(concatData.eeg(:,i),EGIHC256);
%     %set(gca,'clim',[-100 100])
%     title('Raw data')
%     subplot(122); corttopo(SL(:,i),EGIHC256);
%     %set(gca,'clim',[-600 600])
%     title('Surface Laplacian')
%     pause(0.1)
%     mov(index) = getframe(gcf);
%     index = index + 1;
% end

%% saving motor channels separately
% identifying channels (based on EGI 256 saline net only! - no HM applied)
motorChannels = [58 51 65 59 52 60 66 195 196 182 183 184 155 164];
concatData.motorEEG{i} = concatData.eeg{i}(motorChannels,:);

%% save concatenated data
fprintf('Saving topographically filtered data...');
save(strcat(subname,'_concatData'),'concatData');
fprintf('Done.\n');

end
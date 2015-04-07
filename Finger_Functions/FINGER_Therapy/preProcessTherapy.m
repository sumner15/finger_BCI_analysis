function concatData = preProcessTherapy(username,subname)
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
setPathTherapy(username,subname)

%Read in .mat file
filename = celldir([subname '*concatData.mat']);
filename{1} = filename{1}(1:end-4);

fprintf(['Loading ' filename{1} '...']);
load(filename{1});  
fprintf('Done.\n');

%% common vars
nSongs = length(concatData.eeg);

%% re-referencing
% %refChannels = [62 63 73 70 74 75 84];
% for i = 1:length(concatData.eeg)
%     % T4 reference ...
%     %reference = repmat(squeeze(mean(concatData.eeg{i}(refChannels,:),1)),[length(motorChannels) 1]);
%     % common average reference... 
%     reference = repmat(squeeze(mean(concatData.eeg{i}(:,:),1)),[size(concatData.eeg{i},1) 1]);
%     concatData.eeg{i} = concatData.eeg{i} - reference;
% end

%% subtracting DC offset and trend from channels
fprintf('Detrending Data...')
for song = 1:nSongs
    %detrending channels
    for channel = 1:size(concatData.eeg{song},1)
       concatData.eeg{song}(channel,:) = detrend(concatData.eeg{song}(channel,:));
   end   
end
fprintf('Done.\n')

%% Low pass filter
disp('Filtering Data...'); fprintf('Song Number...');
fCut = 50; %cutoff freq in Hz
for song = 1:nSongs
    fprintf('%i...',song);
    concatData.eeg{song} = lowPassFilter(concatData.eeg{song},fCut);    
end; fprintf('\n'); 

%% LAPLACIAN FILTER
% fprintf('LaPlacian Filter...');
% load egihc256hm
% 
% % Save X, Y, Z locations of EEG channels
% X = EGIHC256.Electrode.CoordOnSphere(:,1);
% Y = EGIHC256.Electrode.CoordOnSphere(:,2);
% Z = EGIHC256.Electrode.CoordOnSphere(:,3);
% 
% % parameters
% lambda = 1e-6; %smoothing parameter (nominal 1e-5)
% m = 20;        %order of the Legendre Polynomial (higher is better, but costly)
% 
% % Apply surface Laplacian
% for song = 1:length(concatData)      
%     topoData = concatData.eeg{song}(1:256,:);
%     [SL,~,~] = laplacian_perrinX(topoData,X,Y,Z,m,lambda);
% 
% % %Make a movie of original data next to SL result
% % scrsz = get(0,'ScreenSize'); 
% % set(figure,'Position',scrsz)
% % for i=15000:100:16000%30000 % 5 seconds, .1s increments    
% %     subplot(121); corttopo(topoData(:,i),EGIHC256); 
% %     set(gca,'clim',[-6 6])           
% %     title(['Raw Data ( t = ' num2str(i/1000) ' )']);    
% %     
% %     subplot(122); corttopo(SL(:,i),EGIHC256); 
% %     set(gca,'clim',[-600 600])           
% %     title(['Surface LaPlacian ( m=' num2str(m) ', l=' num2str(lambda) ' )']); 
% %     
% %     pause(0.02);
% % end
%     
%     % Transfer Results
%     concatData.eeg{song} = SL;
% end
% fprintf('Done.\n');

%% saving motor channels & implementing head model (reducing channels)

% identifying channels (based on EGI 256 saline net only!)
%motorChannels = [58 51 65 59 52 60 66 195 196 182 183 184 155 164]; %HNL selection
if ~exist('concatData.motorChans','var')
    concatData.motorChans = [81 90  101 119 131 130 129 128 143 142];% CL & SMC correct!
end

load('egihc256redhm');
concatData.hm = EGIHC256RED; 

for song = 1:nSongs
    concatData.motorEEG{song} = concatData.eeg{song}(concatData.motorChans,:);
    concatData.eeg{song} = concatData.eeg{song}(concatData.hm.ChansUsed,:);
end

end
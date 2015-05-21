function channelSelectEnviro(username,subname,concatData)
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

%% setting default values
disp('Preprocessing Data');
concatData.params.reRef = false;
concatData.params.detrend = false;
concatData.params.lowPass = false;
concatData.params.laPlacian.bool = false;

%% loading data 
if nargin <= 2 % if we didn't give the func a concatData struct to use
    setPathEnviro(username,subname)

    %Read in .mat file
    filename = celldir([subname '*concatData.mat']);
    filename{1} = filename{1}(1:end-4);

    fprintf(['Loading ' filename{1} '...']);
    load(filename{1});  
    fprintf('Done.\n');
end

%% re-referencing
% %refChannels = [62 63 73 70 74 75 84];
% for i = 1:length(concatData.eeg)
%     % T4 reference ...
%     %reference = repmat(squeeze(mean(concatData.eeg{i}(refChannels,:),1)),[length(motorChannels) 1]);
%     % common average reference... 
%     reference = repmat(squeeze(mean(concatData.eeg{i},1)),[size(concatData.eeg{i},1) 1]);
%     concatData.eeg{i} = concatData.eeg{i} - reference;
% end
% concatData.params.reRef = true;

%% subtracting DC offset and trend from channels
fprintf('Detrending Data...')
for song = 1:length(concatData.eeg)
   for channel = 1:size(concatData.eeg{song},1)
       concatData.eeg{song}(channel,:) = detrend(concatData.eeg{song}(channel,:));
   end
end
concatData.params.detrend = true;
fprintf('Done.\n')

%% Low pass filter
% disp('Filtering Data...'); fprintf('Song Number...');
% fCut = 50; %cutoff freq in Hz
% for song = 1:length(concatData.eeg)
%     fprintf('%i...',song);
%     concatData.eeg{song} = lowPassFilter(concatData.eeg{song},fCut,1000);    
% end; fprintf('\n'); 
% concatData.params.lowPass = true;

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
% concatData.params.laPlacian.bool = true;
% concatData.params.laPlacian.lambda = lambda;
% concatData.params.laPlacian.m = m;
% fprintf('Done.\n');

%% saving motor channels separately
% identifying channels (based on EGI 256 saline net only! - no HM applied)
%motorChannels = [58 51 65 59 52 60 66 195 196 182 183 184 155 164]; %HNL selection
%motorChannels = [81 90  101 119 80  89  100 110 79  88];% based on topographical viewing (not contralateral...whoops)
motorChannels = [81 90  101 119 131 130 129 128 143 142];% CL & SMC correct!
%motorChannelsEmotiv = [9 10 12 13]; % Right side P8,T8,FC6,F4
motorChannelsEmotiv = 12; % Right side FC6

for song = 1:length(concatData.eeg)
    if size(concatData.eeg{song},1) >= 256      % if this is the geodesic cap
        concatData.motorChans = motorChannels;
        concatData.motorEEG{song} = concatData.eeg{song}(motorChannels,:);
    elseif size(concatData.eeg{song},1) <= 14   % if this is the emotiv
        concatData.motorChans = motorChannelsEmotiv;
%         concatData.motorEEG{song} = concatData.eeg{song}(motorChannelsEmotiv,:);
        concatData.motorEEG{song} = concatData.eeg{song}(:,:);
    else
        error('Capture hardware undefined');
    end
end

%% save concatenated data
fprintf('Saving pre-processed data...');
save(strcat(subname,'_concatData'),'concatData');
fprintf('Done.\n');

end
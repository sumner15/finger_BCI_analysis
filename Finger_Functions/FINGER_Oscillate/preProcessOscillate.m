function concatData = preProcessOscillate(subData)
%
% Input: 
% subData as subject data from output of 'datToMatOscillate
%
% uses subjects concatData file where concatData is a structure containing
% concatData.sr (sampling rate) and concatData.eeg (the signal) where:
% signal = array of signals as vectors (channel x samples)
%
% Output:
% 

%% common vars
concatData.eeg = subData.signal;
concatData.sr = 600;                %Hz - note: not proper from BCI2000 
                                    %parameters output, hard coded for now
nSongs = length(concatData.eeg);


%% re-referencing 
%refChannels = [4 8]; %T7 & T8
refChannels = [1:14 16]; %All except PO8 (too noisy)
for i = 1:length(concatData.eeg)    
    reference = repmat(squeeze(mean(concatData.eeg{i}(:,refChannels),2)),[1 size(concatData.eeg{i},2)]);
    concatData.eeg{i} = concatData.eeg{i} - reference;
end

%% subtracting DC offset and trend from channels
fprintf('Detrending Data...')
for song = 1:nSongs
    %correcting data orientation & type
    concatData.eeg{song} = double(concatData.eeg{song}');
    %detrending channels
    for channel = 1:size(concatData.eeg{song},1)
       concatData.eeg{song}(channel,:) = detrend(concatData.eeg{song}(channel,:));
   end   
end
fprintf('Done.\n')

%% Low pass filter
% disp('Filtering Data...'); fprintf('Song Number...');
% fCut = 50; %cutoff freq in Hz
% for song = 1:nSongs
%     fprintf('%i...',song);
%     concatData.eeg{song} = lowPassFilter(concatData.eeg{song},fCut,concatData.sr);    
% end; fprintf('\n'); 

%% LAPLACIAN FILTER (for Geodesic cap only)
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

%% implementing head model 
load('fake16hm'); %temporary 16-ch hm based on EGI coords. Will need to check this
concatData.hm = FAKE16; 

end
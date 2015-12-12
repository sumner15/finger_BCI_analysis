function data = passive_preProcess(subname,saveBool)
% Input: 
% subname = e.g. 'SLN'
% savebool = e.g. true or false
%
% Outputs: 
% * FIX ME *

%% loading data 
passive_setPath();
cd 'raw_data';
nRuns = 10;      
data = datToMat(subname,nRuns);
    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  common vars & OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SET these parameters (options) here: 
data.params.reReference   = false;
data.params.lowPass       = false;
data.params.highPass      = false;
data.params.bandPass      = false;
data.params.laPlacian     = false;
data.params.reOrdered     = false;

% used later (don't change these!)
data.params.screened      = false; 
data.params.ICA           = false;      
data.params.cleanedBy     = NaN;
data.params.wavelet       = false;
data.params.segmented     = false;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% implementing head model (reducing channels)
if isfield(data,'hm')
     % checks if head model exists already
    error('head model found; this data has already been processed');
else % apply the head model
    load('egihc256redhm');
    error('missing head model')
    data.hm = EGIHC256RED; 
    nChans = length(data.hm.ChansUsed);
    for run = 1:nSongs    
        data.eeg{run} = data.eeg{run}(data.hm.ChansUsed,:);    
    end
end

%% re-referencing
% if concatData.params.reReference    
%     for song = 1:nSongs
%         % (select channels reference...
%         % reference = repmat(squeeze(mean(concatData.eeg{song}(refChannels,:),1)),[length(motorChannels) 1]);
%         
%         % common average reference...         
%         reference = repmat(squeeze(mean(concatData.eeg{song},1)),[nChans 1]);
%         concatData.eeg{song} = concatData.eeg{song} - reference;
%     end
% end

%%%%%%%%%%%% 12/11/15, stopped here %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %% Filtering (butterworth 1-50 Hz, notch @ 60)
% if concatData.params.bandPass    
%     disp('Filtering Data...'); fprintf('Song Number...');    
%     for song = 1:nSongs
%         fprintf('%i...',song);
%         dataIn.eeg = concatData.eeg{song}';
%         dataIn.sr = concatData.sr;
%         dataOut = filtereeg(dataIn);
%         concatData.eeg{song} = dataOut.eeg';
%         clear dataIn dataOut
%     end; fprintf('\n');     
% end
% 
% %% LAPLACIAN FILTER
% if concatData.params.laPlacian
%     disp('LaPlacian Filter...');    
% 
%     % Save X, Y, Z locations of EEG channels
%     X = concatData.hm.Electrode.CoordOnSphere(:,1);
%     Y = concatData.hm.Electrode.CoordOnSphere(:,2);
%     Z = concatData.hm.Electrode.CoordOnSphere(:,3);
% 
%     % parameters
%     lambda = 1e-6; %smoothing parameter (nominal 1e-5)
%     m = 20;        %order of the Legendre Polynomial (higher is better, but costly)
% 
%     % Apply surface Laplacian
%     for song = 1:length(concatData)      
%         topoData = concatData.eeg{song}(1:256,:);
%         [SL,~,~] = laplacian_perrinX(topoData,X,Y,Z,m,lambda);
%         % Transfer Results
%         concatData.eeg{song} = SL;
%     end
%     fprintf('Done.\n');
% end
% 
% %% Reordering data according to run type
% if concatData.params.reOrdered 
%     setPathEnviro(username);
%     load runOrder.mat   %loading run orders
%     
%     subjects = {'BECC','NAVA','TRAT','POTA','TRAV','NAZM',...
%                 'TRAD','DIAJ','GUIR','DIMC','LURI','TRUS'};        
% 
%     subNum = ismember(subjects,subname);
%     concatData.runOrder = runOrder(subNum,:);
% 
%     newOrderEEG = cell(size(concatData.eeg));
%     newOrderVid = cell(size(concatData.vid));    
%     for song = 1:nSongs
%         newOrderEEG{concatData.runOrder(song)} = concatData.eeg{song};
%         newOrderVid{concatData.runOrder(song)} = concatData.vid{song};
%     end
%     concatData.eeg = newOrderEEG;
%     concatData.vid = newOrderVid;
% end
% 

%% saving results (overwrites file if it exists)
data.params.preProcess = true;
if saveBool
    fprintf('saving pre-processed data...');
    passive_setPath()
    save(strcat(subname,'_preProcessed'),'data','-v7.3');
    fprintf('Done.\n');
else
    disp('data not saved, must pass directly');
end

end
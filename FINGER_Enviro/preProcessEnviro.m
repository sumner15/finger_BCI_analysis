function concatData = preProcessEnviro(username,subname,saveBool,concatData)
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
if nargin >= 4 && exist('concatData','var')
    disp('Concatenated data passed directly; skipping load...');
else
    filename = celldir([subname '*concatData.mat']);
    filename{1} = filename{1}(1:end-4);

    fprintf(['Loading ' filename{1} '...']);
    load(filename{1});  
    fprintf('Done.\n');
end
    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  common vars & OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nSongs = length(concatData.eeg);

% SET these parameters (options) here: 
concatData.params.reReference   = true;
concatData.params.lowPass       = false;
concatData.params.highPass      = false;
concatData.params.bandPass      = true;
concatData.params.laPlacian     = false;
concatData.params.reOrdered     = true;

% used later (don't change these!)
concatData.params.screened = false; 
concatData.params.ICA = false;      
concatData.params.cleanedBy = NaN;
concatData.params.wavelet = false;
concatData.params.segmented = false;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% implementing head model (reducing channels)
if isfield(concatData,'hm')
     % checks if head model exists already
    error('This data has already been pre-processed; please re-concat from raw data');
else % apply the head model
    load('egihc256redhm');
    concatData.hm = EGIHC256RED; 
    nChans = length(concatData.hm.ChansUsed);
    for song = 1:nSongs    
        concatData.eeg{song} = concatData.eeg{song}(concatData.hm.ChansUsed,:);    
    end
end

%% re-referencing
if concatData.params.reReference    
    for song = 1:nSongs
        % (select channels reference...
        % reference = repmat(squeeze(mean(concatData.eeg{song}(refChannels,:),1)),[length(motorChannels) 1]);
        
        % common average reference...         
        reference = repmat(squeeze(mean(concatData.eeg{song},1)),[nChans 1]);
        concatData.eeg{song} = concatData.eeg{song} - reference;
    end
end

%% Filtering (butterworth 1-50 Hz, notch @ 60)
if concatData.params.bandPass    
    disp('Filtering Data...'); fprintf('Song Number...');    
    for song = 1:nSongs
        fprintf('%i...',song);
        dataIn.eeg = concatData.eeg{song}';
        dataIn.sr = concatData.sr;
        dataOut = filtereeg(dataIn);
        concatData.eeg{song} = dataOut.eeg';
        clear dataIn dataOut
    end; fprintf('\n');     
end

%% LAPLACIAN FILTER
if concatData.params.laPlacian
    disp('LaPlacian Filter...');    

    % Save X, Y, Z locations of EEG channels
    X = concatData.hm.Electrode.CoordOnSphere(:,1);
    Y = concatData.hm.Electrode.CoordOnSphere(:,2);
    Z = concatData.hm.Electrode.CoordOnSphere(:,3);

    % parameters
    lambda = 1e-6; %smoothing parameter (nominal 1e-5)
    m = 20;        %order of the Legendre Polynomial (higher is better, but costly)

    % Apply surface Laplacian
    for song = 1:length(concatData)      
        topoData = concatData.eeg{song}(1:256,:);
        [SL,~,~] = laplacian_perrinX(topoData,X,Y,Z,m,lambda);
        % Transfer Results
        concatData.eeg{song} = SL;
    end
    fprintf('Done.\n');
end

%% Reordering data according to run type
if concatData.params.reOrdered 
    setPathEnviro(username);
    load runOrder.mat   %loading run orders
    
    subjects = {'BECC','NAVA','TRAT','POTA','TRAV','NAZM',...
                'TRAD','DIAJ','GUIR','DIMC','LURI','TRUS'};        

    subNum = ismember(subjects,subname);
    concatData.runOrder = runOrder(subNum,:);

    newOrderEEG = cell(size(concatData.eeg));
    newOrderVid = cell(size(concatData.vid));    
    for song = 1:nSongs
        newOrderEEG{concatData.runOrder(song)} = concatData.eeg{song};
        newOrderVid{concatData.runOrder(song)} = concatData.vid{song};
    end
    concatData.eeg = newOrderEEG;
    concatData.vid = newOrderVid;
end

%% saving results (overwrites file if it exists)
concatData.params.preProcess = true;
if saveBool
    fprintf('Saving preProcessed data...');
    setPathEnviro(username,subname);
    save(strcat(subname,'_concatData'),'concatData','-v7.3');
    fprintf('Done.\n');
else
    disp('warning: data not saved, must pass directly');
end

end
function concatData = preProcessOscillate(subData,saveBool)
%
% Input: 
% subData as subject data from output of 'datToMatOscillate
%
% uses subjects concatData file where concatData is a structure containing
% concatData.sr (sampling rate) and concatData.eeg (the signal) where:
% signal = array of signals as vectors (channel x samples)
%
% Output: modified concatData with a parameter substructure
% 

%% common vars
concatData.eeg = subData.signal;
concatData.sr = 600;                %Hz - note: not proper from BCI2000 
                                    %parameters output, hard coded for now
% implementing head model 
load('fake16hm');                   %temporary 16-ch hm based on EGI 
                                    %coords. Will need to update.
concatData.hm = FAKE16; 

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
concatData.params.reOrdered     = false;

% used later (don't change these!)
concatData.params.screened = false; 
concatData.params.ICA = false;      
concatData.params.cleanedBy = NaN;
concatData.params.wavelet = false;
concatData.params.fourier = false;
concatData.params.segmented = false;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% re-referencing 
if concatData.params.reReference
    %refChannels = [4 8]; %T7 & T8
    refChannels = [1:14 16]; %All except PO8 (too noisy)
    for song = 1:nSongs
        reference = repmat(squeeze(mean(concatData.eeg{song}(:,refChannels),2)),[1 size(concatData.eeg{song},2)]);
        concatData.eeg{song} = concatData.eeg{song} - reference;
    end
    concatData.params.refChannels = refChannels;
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

%% saving results (overwrites file if it exists)
concatData.params.preProcess = true;
if saveBool
    fprintf('Saving preProcessed data...');
    setPathOscillate(username,subname);
    save(strcat(subname,'_concatData'),'concatData','-v7.3');
    fprintf('Done.\n');
else
    disp('warning: data not saved, must pass directly');
end

end
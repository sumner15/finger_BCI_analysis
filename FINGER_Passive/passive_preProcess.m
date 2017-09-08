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
data.sr = data.bciPrm.SamplingRate.NumericValue;
    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  common vars & OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SET these parameters (options) here: 
data.params.reReference   = true;
data.params.filtered      = true;
data.params.passband      = [9 12];    %[1 50];
data.params.stopband      = [8 13];     %[.25 60];
data.params.laPlacian     = false;
data.params.reOrdered     = true;

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
    load ECI16locs
    data.hm = ECI16locs; 
    nChans = size(ECI16locs,1);
end

%% re-referencing
if data.params.reReference    
    for run = 1:nRuns
        % (select channels reference...     
        % reference = repmat(squeeze(mean(...
        % data.eeg{run}(refChannels,:),1)),[length(motorChannels) 1]);
        
        % common average reference...         
        reference = repmat(squeeze(mean(data.eeg{run},1)),[nChans 1]);
        data.eeg{run} = data.eeg{run} - reference;
    end
end

%% Filtering (butterworth 1-50 Hz, notch @ 60)
if data.params.filtered  
    disp('Filtering Data...'); 
    fprintf('Run Number...');    
    for run = 1:nRuns
        fprintf('%i...',run);
        dataIn.eeg = data.eeg{run}';
        dataIn.sr = data.sr;
        dataOut = filtereeg(dataIn,data.sr,...
                            data.params.passband,data.params.stopband);
        data.eeg{run} = dataOut.eeg';
        clear dataIn dataOut
    end; fprintf('\n');     
end

%% LAPLACIAN FILTER
if data.params.laPlacian
    disp('LaPlacian Filter...');    

    % Save X, Y, Z locations of EEG channels
    X = data.hm.Electrode.CoordOnSphere(:,1);
    Y = data.hm.Electrode.CoordOnSphere(:,2);
    Z = data.hm.Electrode.CoordOnSphere(:,3);

    % parameters
    lambda = 1e-6; %smoothing parameter (nominal 1e-5)
    m = 20; %order of the Legendre Polynomial (higher=better, but costly)

    % Apply surface Laplacian
    for run = 1:length(data)      
        topoData = data.eeg{run}(1:nChans,:);
        [SL,~,~] = laplacian_perrinX(topoData,X,Y,Z,m,lambda);
        % Transfer Results
        data.eeg{run} = SL;
    end
    fprintf('Done.\n');
end

%% saving data according to run type
% this 're-ordering' actually concatenates like-condition trials into one
% large matrix. I am selecting the EEG and robot position matrices to carry
% over. 
if data.params.reOrdered   
    % 1 = assisted, 2 = unassisted, 3 = passive
    data.runOrder = [1 1 2 2 1 1 2 2 3 3];    
    data.runOrderLabels = {'assisted','unassisted','passive'};      
    
    nConds = length(unique(data.runOrder));
    newEEG = cell(1,nConds);
    robot1 = cell(1,nConds);
    robot2 = cell(1,nConds);
    target = cell(1,nConds);
    for condition = 1:nConds
        condInds = find(data.runOrder == condition);
        for run = 1:length(condInds)
            newEEG{condition} = ...
                [newEEG{condition} data.eeg{condInds(run)}];
            robot1{condition} = ...
                [robot1{condition} data.state{condInds(run)}.FRobotPos1'];
            robot2{condition} = ...
                [robot2{condition} data.state{condInds(run)}.FRobotPos2'];
            target{condition} = ...
               [target{condition} data.state{condInds(run)}.CursorColors'];
        end        
    end
    data.eeg = newEEG;
    data.robot1 = robot1;
    data.robot2 = robot2;
    data.target = target;
    clear newEEG robot1 robot2 target
end

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
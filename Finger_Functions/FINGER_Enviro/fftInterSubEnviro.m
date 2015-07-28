function fftInterSubEnviro(subjects)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fftInterSubEnviro reads in the clean 'concatData' structure from the
% subjects folder. These files are created using the screenTherapy function
% by screening the data, and optionally using ICA to clean the data. This
% script uses a basic FFT time-freq decomposition to transform the data to
% freq domain. It then arranges the data for all subjects and conditions
% into a structure of the shape: 
%
% trialPOWER: sub x condition x window(time) x freqBins x channels
% 
% A similar structure is created using a 10*log10(power-baseline/baseline)
% decibel normalization (Cohen X) and is named 'trialPowerDB'. These 
% structures and all relative processing information needed for later 
% plotting or processing is then SAVED (after prompting the user, if 
% wanted) to a file called 'cleanFFTPower.mat'. 
% 
% Finally, these data are then used to plot several measures including
% time-frequency maps and spectra across subjects for all conditions and
% selected-frequency time series decibel normalized power at a
% topographical region of choice. 
%
% All of these plotting tools can be used without re-processing the data by
% loading the saved 'cleanFFTPower.mat' dataset into the matlab workspace
% and running the plotting cell for the figure you want to creat. 
% 
% Author: Sumner Norman (slnorman@uci.edu)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Movement Anticipation and EEG: Implications for BCI-robot therapy
tic
if ~exist('subjects','var')
    subjects = {'BECC','TRUS','DIMC','GUIR','LURI','NAVA',...
                'NAZM','TRAT','TRAV','POTA','DIAJ','TRAD'};               
    disp('no subject list passed... assuming all subjects')
end
nSubs = length(subjects);       % number of subjects analyzed 

%% options %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trialLength = 3;                % trial length (in sec)
windowLength = 200;             % Sample length 
baseInd = 1:2;                  % baseline period (in int multiples of 
                                % windowLength ms) for use in dB change 
fs = 1000;                      % sampling frequency (Hz)
fVec = linspace(0,fs/2,windowLength/2+1);  % frequency vector resolved by fft
nFreqs = length(fVec);          % number of independent freqs resolved
nWins = floor(fs*3/windowLength); % number of windows per epoch (3 sec)
t = linspace(-trialLength/2,trialLength/2,nWins); %time vector (saved2file)

nConds = 6;                     % number of conditions 
nTrials = 62;
condTitles = {'AV Only','Robot+Motor','Motor','AV Only','Robot','AV Only'};
nChans = 194;                   % using EGI HC 256 RED Head Model!

%% setting marker indices
%markerInds is an integer array of marker indices (for all trials)   
%*marker train of 3s epoch + 1s zero-pad for nTrials    
markerInds = 1:(fs*(trialLength+1)):nTrials*(fs*(trialLength+1));    

%% loading data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n'); disp('head model, CAR, ordering, and segmenting...');
for currentSub = 1:nSubs
    clear concatData
    subname = subjects{currentSub};
    setPathEnviro('LAB',subname);
    filename = celldir([subname '*_concatData.mat']);
    filename = filename{1}(1:end-4);
    disp(['Loading ' filename '...']);
    load(filename);  
    
    %% check that data has correct head model and parameters
    load('egihc256redhm');   hm = EGIHC256RED; clear EGIHC256RED
    for cond = 1:nConds
        if size(concatData.eeg{cond},1) ~= length(hm.ChansUsed)
            error('head model not applied')
        elseif ~concatData.params.ICA || ~concatData.params.reOrdered 
            error('data not fully cleaned or processed; check params')
        end
    end 
    
    %% segmenting data        
    for cond = 1:nConds        
        for trial = 1:nTrials
            trialInds = markerInds(trial):(markerInds(trial)+fs*trialLength-1);
            % screenEEG{sub,cond}(trialTime,chan,trial)
            currentData = concatData.eeg{cond}(:,trialInds); % chan x trialTime
            screenEEG{currentSub,cond}(:,:,trial) = currentData';
        end
    end
    
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('processing subject data (FFT)');
% input:   screenEEG {sub,condition}(trialTime x chan x trial)
% outcome: trialPOWER(sub x condition x window(time) x freqBin x channel x trial)
trialPOWER = NaN(nSubs,nConds,nWins,nFreqs,nChans,nTrials);
dimensionLabels = {'nSubs','nConds','nWins','nFreqs','nChans','nTrials'};    

for currentSub = 1:nSubs
    fprintf('.');
    for currentCond = 1:nConds
        for currentChan = 1:nChans
            % compute FFT for currentSub & condition (nFreqs x nWins x nChans x nTrials)
            for window = 1:nWins                         
               % create sample window indices
               sampleWin = (window-1)*windowLength+1:window*windowLength;
               % cut out current data window for analysis (sample x trial)
               currentData = squeeze(screenEEG{currentSub,currentCond}(sampleWin,currentChan,:));
               % find power and clip FFT for negative frequencies (freq x trial)
               currentFFT  = abs(fft(currentData));  currentFFT = currentFFT(1:end/2+1,:);    
               % average across trials
               trialPOWER(currentSub,currentCond,window,:,currentChan,:) = currentFFT;
            end
        end
    end
end
fprintf('\n\n');

%% we need to free memory at this point
clearvars -except baseInd nWins nSubs trialPOWER dimensionLabels ...
                  windowLength subjects condTitles fVec hm t

%% compute decibel power 
disp('computing decibel power');
baseline = repmat(mean(trialPOWER(:,:,baseInd,:,:,:),3),[1 1 nWins 1 1 1]);
trialPowerDB = 10*log10(trialPOWER./baseline);
fprintf('\n');

%% save results for later
fprintf('Elapsed time (min): %2.1f \nElapased time per subject %2.1f \n', toc/60,toc/60/nSubs);
savebool = input('Would you like to save the fft power results? (y or n): ','s');
if savebool == 'y'
    setPathEnviro('LAB');    
    % save single trial data (does not save raw power to save space!)
    save('singleTrialFFT','trialPowerDB','dimensionLabels',...
        'windowLength','subjects','condTitles','fVec','hm','t','-v7.3'); 
    
    % average across trials for analysis across trials (topo analysis etc)
    trialPOWER = squeeze(mean(trialPOWER,6));
    trialPowerDB = squeeze(mean(trialPowerDB,6));
    dimensionLabels = {'nSubs','nConds','nWins','nFreqs','nChans'}; 
    
    % save power across trials
    save('cleanFFTPower','trialPOWER','trialPowerDB','dimensionLabels',...
        'windowLength','subjects','condTitles','fVec','hm','t','-v7.3');  
end
disp('done');

end
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
 subjects = {{'BECC'},{'TRUS'},{'DIMC'},{'GUIR'},{'LURI'},{'NAVA'},...
             {'NAZM'},{'TRAT'},{'TRAV'},{'POTA'},{'DIAJ'},{'TRAD'}};
% subjects = {{'TRUS'}}; % for testing purposes
nSubs = length(subjects);       % number of subjects analyzed 

%% options %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trialLength = 3;                % trial length (in sec)
windowLength = 200;             % Sample length 
baseInd = 1:2;                  % baseline period (in int multiples of 
                                % windowLength ms) for use in dB change 
fs = 1000;                      % sampling frequency (Hz)
% Hz (desired center freq used for topography)
fVec = linspace(0,fs/2,windowLength/2+1);  % frequency vector resolved by fft
nFreqs = length(fVec);          % number of independent freqs resolved
nWins = floor(fs*3/windowLength); % number of windows per epoch (3 sec)
t = linspace(-trialLength/2,trialLength/2,nWins); %time vector
freqInd = NaN(1,nSubs);         % initializing frequency index vector
freqUsed = NaN(1,nSubs);        % initializing frequency used vector

nConds = 6;                     % number of conditions 
condTitles = {'AV Only','Robot+Motor','Motor','AV Only','Robot','AV Only'};
nChans = 194;                   % using EGI HC 256 RED Head Model!

%% loading run order data
setPathEnviro('LAB');
load runOrder.mat   %identifying run order
subRuns  = {'BECC','NAVA','TRAT','POTA','TRAV','NAZM',...
            'TRAD','DIAJ','GUIR','DIMC','LURI','TRUS'};       
condStr = {'AV','motor','motor+robot','AV','robot','AV'};


%% loading data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for currentSub = 1:nSubs
    clear concatData
    subname = subjects{currentSub}{1};
    setPathEnviro('LAB',subname);
    filename = celldir([subname '*_concatData.mat']);
    filename = filename{1}(1:end-4);
    disp(['Loading ' filename '...']);
    load(filename);  
    
    %% applying head model
    if isfield(concatData,'hm')==1 && length(concatData.hm.ChansUsed) ~= 194
        hm = load('egihc256redhm');    
        for cond = 1:nConds
            concatData.eeg = concatData.eeg{cond}(hm.ChansUsed,:);  
        end
    else
        load('egihc256redhm');   hm = EGIHC256RED; clear EGIHC256RED
    end
    
    %% Reordering data according to run type
    subNum = find(ismember(subRuns,subname));
    runOrderInds = runOrder(subNum,:);
    for cond = 1:nConds
       orderedEEG{cond} = concatData.eeg{runOrderInds(cond)}; 
    end  
    concatData.eeg = orderedEEG; clear orderedEEG;
        
    %% segmenting data
    setPathEnviro('LAB');
    load('note_timing_Blackbird') %creates var Blackbird   <nNotes x 1 double>      
    nTrials = length(blackBird);
    
    for cond = 1:nConds
        %start index of time sample marking beginning of trial (from labjack)
        startInd = find(abs(concatData.vid{cond})>2000, 1 );
        %markerInds is an integer vector of marker indices (rounded to 100ms)
        markerInds = startInd+round(blackBird);
        for trial = 1:nTrials
            trialInds = markerInds(trial)-1500:markerInds(trial)+1499;
            % screenEEG{sub,cond}(trialTime,chan,trial)
            currentData = concatData.eeg{cond}(:,trialInds); % chan x trialTime
            screenEEG{currentSub,cond}(:,:,trial) = currentData';
        end
    end
    
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% processing subject data (FFT)
% input:   screenEEG {sub,condition}(trialTime x chan x trial)
% outcome: trialPOWER(sub x condition x window(time) x freqBins x channels)
trialPOWER = NaN(nSubs,nConds,nWins,nFreqs,nChans);

for currentSub = 1:nSubs
    for currentCond = 1:nConds
        for currentChan = 1:nChans
            % compute FFT for currentSub & condition (nFreqs x nWins x nChans x nTrials)
            for window = 1:nWins                         
               % create sample window indices
               sampleWin = (window-1)*windowLength+1:window*windowLength;
               % cut out current data window for analysis
               currentData = squeeze(screenEEG{currentSub,currentCond}(sampleWin,currentChan,:));
               % find power and clip FFT for negative frequencies
               currentFFT  = abs(fft(currentData));  currentFFT = currentFFT(1:end/2+1,:);    
               % average across trials
               trialPOWER(currentSub,currentCond,window,:,currentChan) = squeeze(mean(currentFFT,2));
            end
        end
    end
end
clear sampleWin currentData currentFFT


%% compute decibel power 
trialPowerDB = NaN(size(trialPOWER));
for currentSub = 1:nSubs
for currentCond = 1:nConds
for currentFreq = 1:nFreqs
for currentChan = 1:nChans
baseline = mean(trialPOWER(currentSub,currentCond,baseInd,currentFreq,currentChan),3);
trialPowerDB(currentSub,currentCond,:,currentFreq,currentChan) = ...
10*log10(trialPOWER(currentSub,currentCond,:,currentFreq,currentChan)./baseline);
end
end
end
end

%% save results for later
savebool = input('Would you like to save the fft power results? (y or n): ','s');
if savebool == 'y'
    setPathEnviro('LAB');    
    dimensionLabels = ['nSubs','nConds','nWins','nFreqs','nChans'];    
    save('cleanFFTPower','trialPOWER','trialPowerDB','dimensionLabels',...
        'windowLength','subjects','condTitles','fVec','hm','t','-v7.3');  
end



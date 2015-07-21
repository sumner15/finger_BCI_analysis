function fftInterSubTherapy(subjects)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fftInterSubTherapy reads in the 'waveletData' structure from the
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

%% options %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fs = 1000;                          % sampling frequency
windowLength = 200;                 % 200 ms sample window for FFT 
trialLength = 3;                    % trial length (in sec)

fVec = linspace(0,fs/2,windowLength/2+1);  % frequency vector resolved by fft
nSamples = trialLength*fs;          % data samples in a trial

nWins = floor(nSamples/windowLength);   % number of windows per epoch (3 sec)
t = linspace(-trialLength/2,trialLength/2,nWins); %time vector
nFreqs = length(fVec);              % number of frequencies resolved by FFT
nChans = 194;                       % red head model

%% setting subject list and common vars
if ~exist('subjects','var')
    subjects = {'AGUJ','ARRS','BROR','CHIB','CORJ','CROD','ESCH','FLOA',...
            'GONA','HAAN','JOHG','KILB','LAMK','LEUW','LOUW','MALJ',...
            'MCCL','MILS','NGUT','POOJ','PRIJ','RITJ','SARS','VANT',...
            'WHIL','WILJ','WRIJ','YAMK'};            
    disp('no subject list passed... assuming all subjects')
end
nSubs = length(subjects);

% experimental conditions
condTitles = {'PRE-song','PRE-speed','POST-song','POST-speed'};
nConds = length(condTitles);

% username check
if (~exist('username','var'))
   username = input('Username: ','s'); 
end

%% loading data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
currentSub = 1;
while currentSub <= nSubs
    try
        subname = subjects{currentSub}; % subname = subname{1};
        setPathTherapy('LAB',subname);
        filename = celldir([subname '*segWavData.mat']);
        filename = filename{1}(1:end-4);
        disp(['Loading ' filename '...']);
        load(filename);  
        if ~waveletData.params.screened ||~waveletData.params.ICA
            error('Data not clean');
        else % data is clean... load it it
            if currentSub == 1
                screenEEG = waveletData.segEEG;
            else
                screenEEG = [screenEEG ; waveletData.segEEG];
            end    
        end
        currentSub = currentSub+1;
    catch me
        disp(['Could not load data for ' subname]);
        subjects(:,currentSub) = [];       
        nSubs = nSubs-1;
    end
end

%setting head model
if ~exist('waveletData','var')
    error('no data loaded :(');
else
    hm = waveletData.hm; clear waveletData
end

%% TRIAL POWER AS A SINGLE ARRAY USED FOR ALL RESULTS! %%%
trialPOWER = NaN(nSubs,nConds,nWins,nFreqs,nChans);

%% performing FFT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for currentSub = 1:nSubs
    for currentCond = 1:nConds
        screenEEG{currentSub,currentCond} = permute(screenEEG{currentSub,currentCond},[3 2 1]);
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
baseline = trialPOWER(currentSub,currentCond,1,currentFreq,currentChan);
trialPowerDB(currentSub,currentCond,:,currentFreq,currentChan) = ...
10*log10(trialPOWER(currentSub,currentCond,:,currentFreq,currentChan)./baseline);
end
end
end
end

%% save results for later
savebool = input('Would you like to save the fft power results? (y or n): ','s');
if savebool == 'y'
    setPathTherapy('LAB');    
    dimensionLabels = {'nSubs','nConds','nWins','nFreqs','nChans'};   
    % data file name: cleanFFTPower
    save('cleanFFTPower','trialPOWER','trialPowerDB','dimensionLabels',...
        'windowLength','subjects','condTitles','fVec','hm','t','-v7.3');  
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  plot intersubject results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% trialPOWER size: (subject x condition x time-window x freq-bin x channel)
% trialPowerDB size: ( ''       ''            ''            ''         '' )
if ~exist('nSubs','var') || ~exist('nConds','var')
    [nSubs nConds nWins nFreqs nChans] = size(trialPOWER);
end
scrsz = [ 1 1 1306 677]+50; 
opengl software
% R SMC (long lateral)
% chansInterest = [79 87 120 121 131 140 148 161 162 163 164 165 166 ...
%                  171 172 173 123 174 175 176 179 180 181 182 183 8 ];

% bilateral HNL channels plus central parietal 
% chansInterest = [59 51 52 43 44 9 166 165 175 164 174 163 66 60 53 ...
%                  45 121 131 140 148 78 79 120 87];
             
% bilateral HNL channels 
chansInterest = [59 51 52 43 44 165 175 164 174 163 66 60 53 131 140 148];

% CAR
% trialPOWER = trialPOWER - repmat(mean(trialPOWER,5),[1 1 1 1 nChans]);
% trialPowerDB = trialPowerDB - repmat(mean(trialPowerDB,5),[1 1 1 1 nChans]);

%% interSub time-freq maps (raw power)
% average across subjects
timeFreqMap = squeeze(mean(trialPOWER,1)); % (cond,window,freqBin,chan)
% average across channels of interest
timeFreqMap = squeeze(mean(timeFreqMap(:,:,:,chansInterest),4)); % (cond,window,freqBin)

set(figure,'Position',scrsz); suptitle('Raw Power');
tfPositions = [2 3 6 7];
spectraPositions = [1 4 5 8];
for currentCond = 1:nConds
    subplot(2,4,tfPositions(currentCond));
    % t-f for current condition, all windows, freq indices for 5:40 Hz
    freqInds = 2:9; freqUsed = fVec(freqInds);
    currentTFMap = squeeze(timeFreqMap(currentCond,:,freqInds))'; % (window, freqBin)
    imagesc(-1.5:1.5,freqUsed,currentTFMap);  %,[-3 3]
    %colorbar; 
    set(gca,'YDir','normal')
    xlabel('time (s)'); ylabel('freq (Hz)');
    title(condTitles{currentCond});
    
    subplot(2,4,spectraPositions(currentCond));
    currentSpectra = squeeze(mean(currentTFMap,2));     
    plot(currentSpectra,freqUsed);    
    ylabel('freq (Hz)'); xlabel('average power');
end

%% individual time-freq maps (raw power)
condInterest = 3;
subInterest = 1:nSubs;
% select a condition
timeFreqMap = squeeze(trialPOWER(:,condInterest,:,:,:)); % (sub,window,freqBin,chan)
% average across channels of interest
timeFreqMap = squeeze(mean(timeFreqMap(:,:,:,chansInterest),4)); % (sub,window,freqBin)

set(figure,'Position',scrsz); suptitle(['Raw Power, ' condTitles{condInterest}]);
for currentSubInd = 1:length(subInterest)
    currentSub = subInterest(currentSubInd);
    subplot(4,5,currentSubInd);
    % t-f for current subject, all windows, freq indices for 5:40 Hz
    freqInds = 2:9; freqUsed = fVec(freqInds);
    currentTFMap = squeeze(timeFreqMap(currentSub,:,freqInds))'; % (window, freqBin)
    imagesc(-1.5:1.5,freqUsed,currentTFMap,[50 300]);
    %colorbar; 
    set(gca,'YDir','normal')
    xlabel('time (s)'); ylabel('freq (Hz)');
    title(subjects{currentSub}); 
end
subplot(2,3,6);
title('topography weighting');
topoWeight = zeros(1,nChans); topoWeight(chansInterest) = 1;
corttopo(topoWeight,hm,'drawElectrodes',0);

%% interSub Power @frequency of interest
freqInds = 3:7; freqUsed = fVec(freqInds);
subInterest = 1:nSubs;

% average across channels of interest
muPower = squeeze(mean(trialPowerDB(:,:,:,:,chansInterest),5)); % (sub,cond,window,freqBin)
% average in freq range of interest
muPower = squeeze(mean(muPower(:,:,:,freqInds),4)); % (sub,cond,window)

set(figure,'Position',scrsz); suptitle([num2str(freqUsed) ' Hz Power (dB)']);
positions = [1 2 4 5];
for currentCond = 1:nConds
    subplot(2,3,positions(currentCond)); hold on
    for currentSubInd = 1:length(subInterest)
        currentSub = subInterest(currentSubInd);
        currentMuPower = squeeze(muPower(currentSub,currentCond,:));
        plot(t,currentMuPower,'b'); clear currentMuPower
    end
    meanMuPower = squeeze(mean(muPower(:,currentCond,:),1)); 
    plot(t,meanMuPower,'r','LineWidth',4)
    axis([-1.5 1.5 -1.5 1.5])
    xlabel ('time (s)'); ylabel('power change (dB)');
    title(condTitles{currentCond});
end
subplot(2,3,3)
title('topography weighting');
topoWeight = zeros(1,nChans); topoWeight(chansInterest) = 1;
corttopo(topoWeight,hm);
subplot(2,3,6)
title('frequency weighting');
spectralWeight = zeros(1,nFreqs); spectralWeight(freqInds) = 1;
plot(fVec,spectralWeight,'-ok');
xlabel('Freq (Hz)'); ylabel('Weighting'); axis([0 50 -.5 1.5]);

freqInds = 3; freqUsed = fVec(freqInds);

%% change in specific Power before/after training
freqInds = 3:7; freqUsed = fVec(freqInds);

% average across channels of interest
muPower = squeeze(mean(trialPowerDB(:,:,:,:,chansInterest),5)); % (sub,cond,window,freqBin)
% average in freq range of interest
muPower = squeeze(mean(muPower(:,:,:,freqInds),4)); % (sub,cond,window)
% change in mu power
dMuPower(:,1,:) = muPower(:,3,:)-muPower(:,1,:);
dMuPower(:,2,:) = muPower(:,4,:)-muPower(:,2,:);

set(figure,'Position',scrsz); 
suptitle(['change in Power (dB)']);
for currentCond = 1:2
    subplot(2,2,currentCond+2); hold on
    for currentSub = 1:nSubs
        currentMuPower = squeeze(dMuPower(currentSub,currentCond,:));
        plot(t,currentMuPower,'b'); clear currentMuPower
    end
    meanMuPower = squeeze(mean(dMuPower(:,currentCond,:),1)); 
    plot(t,meanMuPower,'r','LineWidth',4)
    axis([-1.5 1.5 -2 2])
    xlabel ('time (s)'); ylabel('power change (dB)');
    title([condTitles{currentCond+2} ' - ' condTitles{currentCond}]);
end
subplot(2,2,1)
title('topography weighting');
topoWeight = zeros(1,nChans); topoWeight(chansInterest) = 1;
corttopo(topoWeight,hm);
subplot(2,2,2)
title('frequency weighting');
spectralWeight = zeros(1,nFreqs); spectralWeight(freqInds) = 1;
plot(fVec,spectralWeight,'-ok');
xlabel('Freq (Hz)'); ylabel('Weighting'); axis([0 50 -.5 1.5]);

%% topography: subject @ cond @ t=0 @ freq
condInterest = 3; windInterest = 8; freqInterest = 3:7; % t=0, f=10
% trialPowerDB size: (subject x condition x time-window x freq-bin x channel)
set(figure,'Position',scrsz); suptitle([condTitles{condInterest} ',t=0,f=' num2str(fVec(freqInterest))]);
% average across condition/time/freq
topoData = squeeze(mean(trialPowerDB(:,condInterest,windInterest,freqInterest,:),4)); % (sub,chan)
for currentSub = 1:nSubs  
   subplot(5,5,currentSub);
   currentTopo = squeeze(topoData(currentSub,:));
   corttopo(currentTopo,hm,'drawElectrodes',0);
%    set(gca,'clim',[-4 8]);

   title(subjects{currentSub});          
end
subplot(5,5,25)
title('frequency weighting');
spectralWeight = zeros(1,nFreqs); spectralWeight(freqInterest) = 1;
plot(fVec,spectralWeight,'-ok');
xlabel('Freq (Hz)'); ylabel('Weighting'); axis([0 50 -.5 1.5]);

%% topography: time x freq (across subjects @condition)
condInterest = 3; subInterest = 1:nSubs;
%subInterest = [2 11 12 14 16 18];
%subInterest = [2 3 5 6 7 9 10 11 12 13 14 16 18];
% trialPowerDB size: (subject x condition x time-window x freq-bin x channel)
set(figure,'Position',scrsz); suptitle([condTitles(condInterest) ' across subjects']);
% average across subjects and selects condition 3
topoData = squeeze(mean(trialPowerDB(subInterest,condInterest,:,:,:),1)); % (window,freqBin,chan)
winsUsed = 2:2:nWins; nWinsUsed = length(winsUsed);
freqUsed = 3:2:9;     nFreqUsed = length(freqUsed);
for winInd = 1:nWinsUsed
   
   for freqInd = 1:nFreqUsed      
       currentWindow = winsUsed(winInd);
       currentFreq = freqUsed(freqInd);
       
       subplot(nFreqUsed,nWinsUsed,winInd+(freqInd-1)*nWinsUsed)
       currentTopo = squeeze(topoData(currentWindow,currentFreq,:));
       corttopo(currentTopo,hm,'drawElectrodes',0);
       set(gca,'clim',[-.7 .7]);
       
       title([num2str(t(winsUsed(winInd))) ' s, ' num2str(fVec(currentFreq)) ' Hz']);        
   end
end

end
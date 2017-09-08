% function fftInterSubTherapy(subjects, username)
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
tic; clearvars -except username subjects; % need to clear memory!
if ~exist('subjects','var')
    subjects = {'AGUJ','ARRS','BROR','CHIB','CORJ','CROD','ESCH','FLOA',...
            'GONA','HAAN','JOHG','KILB','LAMK','LEUW','LOUW','MALJ',...
            'MCCL','MILS','NGUT','POOJ','PRIJ','RITJ','SARS','VANT',...
            'WHIL','WILJ','WRIJ','YAMK'};             
    disp('no subject list passed... assuming all subjects')
end
nSubs = length(subjects);       % number of subjects analyzed 
if ~exist('username','var')
    username = 'LAB';
    disp('Username set to ''LAB''');
end

%% options %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trialLength = 3;                % trial length (in sec)
windowLength = 200;             % Sample length 
baseInd = 1:2;                  % baseline period (in int multiples of 
                                % windowLength ms) for use in dB change 
fs = 1000;                      % sampling frequency (Hz)
fVec = linspace(0,fs/2,windowLength/2+1);  % frequency vector resolved by fft
nFreqs = find(fVec==50);          % number of independent freqs resolved (capped at 50Hz)
nWins = floor(fs*3/windowLength); % number of windows per epoch (3 sec)
t = linspace(-trialLength/2,trialLength/2,nWins); %time vector (saved2file)

nConds = 4;                     % number of conditions
nTrials = [43 24 43 24];        % number of trials for each song
condTitles = {'PRE-song','PRE-speed','POST-song','POST-speed'};
nChans = 194;                   % using EGI HC 256 RED Head Model!

%% setting marker indices
%markerInds is an integer array of marker indices (for all trials)   
%*marker train of 3s epoch + 1s zero-pad for nTrials    
markerInds = 1:(fs*(trialLength+1)):max(nTrials)*(fs*(trialLength+1));  

%% loading data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Loading data...');
load('egihc256redhm');   hm = EGIHC256RED; clear EGIHC256RED

currentSub = 1;
while currentSub <= nSubs
    try
        %% concatData file is loaded here
		clear concatData
        subname = subjects{currentSub}; 
        setPathTherapy('LAB',subname);
        filename = celldir([subname '*_concatData.mat']);
        filename = filename{1}(1:end-4);
        disp(['Loading ' filename '...']);
        load(filename);  
		
		%% check that data has correct head model and parameters			
		if ~concatData.params.preProcess || ~concatData.params.ICA 
			error('data not fully cleaned or processed; check params')
		end		
		
		%% segmenting data        
		for cond = 1:nConds        
			for trial = 1:nTrials(cond)
				trialInds = markerInds(trial):(markerInds(trial)+fs*trialLength-1);
				% screenEEG{sub,cond}(trialTime,chan,trial)
				currentData = concatData.eeg{cond}(:,trialInds); % chan x trialTime
				screenEEG{currentSub,cond}(:,:,trial) = currentData';
			end			
        end
        currentSub = currentSub+1;
	
    catch me
        disp(['Could not load data for ' subname]);
        subjects(:,currentSub) = [];       
        nSubs = nSubs-1;
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% input:   screenEEG {sub,condition}(trialTime x chan x trial)
% outcome: trialPOWER(sub x condition x window(time) x freqBin x channel x trial)
trialPOWER = NaN(nSubs,nConds,nWins,nFreqs,nChans,max(nTrials));
dimensionLabels = {'nSubs','nConds','nWins','nFreqs','nChans','nTrials'};    

for sub = 1:nSubs
    fprintf('.');
    for cond = 1:nConds
        for chan = 1:nChans
            for trial = 1:nTrials(cond)
                for window = 1:nWins                         
                   % create sample window indices
                   sampleWin = (window-1)*windowLength+1:window*windowLength;
                   % cut out current data window for analysis (sample x trial)
                   currentData = squeeze(screenEEG{sub,cond}(sampleWin,chan,trial));
                   % find power and clip FFT for negative frequencies (freq x trial)
                   currentFFT  = abs(fft(currentData));  
                   currentFFT = currentFFT(1:nFreqs);  
                   % if we have a zero-d window, ignore 
                   if ~sum(currentFFT==0)
                       % fill in trialPOWER array
                       trialPOWER(sub,cond,window,:,chan,trial) = squeeze(currentFFT);                   
                   end
                end
            end
        end
    end
end
fVec = fVec(1:nFreqs);
fprintf('\n');


%% we need to free memory at this point 
clearvars -except trialPOWER baseInd nWins nSubs dimensionLabels ...
                  windowLength subjects condTitles fVec hm t username;

%% compute decibel power 
disp('computing decibel power');
baseline = nanmean(trialPOWER(:,:,baseInd,:,:,:),3);
baseline = repmat(baseline,[1 1 nWins 1 1 1]);
trialPowerDB = 10*log10(trialPOWER./baseline);
% % set NaN values to 0s for future computation
% trialPOWER(isnan(trialPOWER)) = 0;
% trialPowerDB(isnan(trialPowerDB)) = 0;

%% save results
fprintf('Elapsed time (min): %2.1f \nElapased time per subject %2.1f \n', toc/60,toc/60/nSubs);
savebool = input('Would you like to save the data? Input y or n: ','s');
if savebool == 'y'
    % save single trial results
    setPathTherapy(username);              
    save('singleTrialFFT','trialPOWER','trialPowerDB','dimensionLabels',...
         'windowLength','subjects','condTitles','fVec','hm','t','-v7.3');
     
     % average across trials (overwrite trialPOWER 6D --> 5D)
    trialPOWER = squeeze(nanmean(trialPOWER,6));
    baseline = mean(trialPOWER(:,:,baseInd,:,:),3);
    baseline = repmat(baseline,[1 1 nWins 1 1]);
    trialPowerDB = 10*log10(trialPOWER./baseline);    
    dimensionLabels = {'nSubs','nConds','nWins','nFreqs','nChans'}; 
     
    % save power across trials
    save('cleanFFTPower','trialPOWER','trialPowerDB','dimensionLabels',...
        'windowLength','subjects','condTitles','fVec','hm','t','-v7.3');  
end
fprintf('Elapsed time (min): %2.1f \nElapased time per subject %2.1f \n', toc/60,toc/60/nSubs);

% end
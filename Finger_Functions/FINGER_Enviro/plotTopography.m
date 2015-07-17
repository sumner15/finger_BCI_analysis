%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  plot intersubject results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
setPathEnviro('LAB');
load('cleanFFTPower.mat');

% trialPOWER size: (subject x condition x time-window x freq-bin x channel)
% trialPowerDB size: ( ''       ''            ''            ''         '' )
scrsz = [ 1 1 1306 677]+50; 
opengl software
[nSubs nConds nWins nFreqs nChans] = size(trialPOWER);
% R SMC (long lateral)
% chansInterest = [79 87 120 121 131 140 148 161 162 163 164 165 166 ...
%                  171 172 173 123 174 175 176 179 180 181 182 183 8 ];

% bilateral HNL channels plus central parietal 
% chansInterest = [59 51 52 43 44 9 166 165 175 164 174 163 66 60 53 ...
%                  45 121 131 140 148 78 79 120 87];
             
% bilateral HNL channels 
chansInterest = [59 51 52 43 44 165 175 164 174 163 66 60 53 131 140 148];

% emotiv channels
% chansInterest = [12 13]; % Right side P8,T8,FC6,F4

%% COMMON AVERAGE REFERENCE 
% trialPOWER = trialPOWER - repmat(mean(trialPOWER,5),[1 1 1 1 nChans]);
% trialPowerDB = trialPowerDB - repmat(mean(trialPowerDB,5),[1 1 1 1 nChans]);

%% Picking 4 conditions of interest
if size(trialPOWER,2) == 6
    trialPOWER = trialPOWER(:,2:5,:,:,:);
    trialPowerDB = trialPowerDB(:,2:5,:,:,:);
    nConds = 4;
    condTitles = {'Robot+Motor','Motor','AV Only','Robot'};
end

%% interSub time-freq maps (raw power)
% average across subjects
timeFreqMap = squeeze(mean(trialPOWER,1)); % (cond,window,freqBin,chan)
% average across channels of interest
timeFreqmap = squeeze(mean(timeFreqMap(:,:,:,chansInterest),4)); % (cond,window,freqBin)

set(figure,'Position',scrsz); suptitle('Raw Power');
tfPositions = [2 3 6 7];
spectraPositions = [1 4 5 8];
for currentCond = 1:nConds
    subplot(2,4,tfPositions(currentCond));
    % t-f for current condition, all windows, freq indices for 5:40 Hz
    freqInds = 2:9; freqUsed = fVec(freqInds);
    currentTFMap = squeeze(timeFreqMap(currentCond,:,freqInds))'; % (window, freqBin)
    imagesc(-1.5:1.5,freqUsed,currentTFMap);  %,[-3 3]
    colorbar; set(gca,'YDir','normal')
    xlabel('time (s)'); ylabel('freq (Hz)');
    title(condTitles{currentCond});
    
    subplot(2,4,spectraPositions(currentCond));
    currentSpectra = squeeze(mean(currentTFMap,2));     
    plot(currentSpectra,freqUsed);    
    ylabel('freq (Hz)'); xlabel('average power');
end

%% interSub Power @frequency of interest 
freqInds = 3; freqUsed = fVec(freqInds);
% subInterest = [2 11 12 14 16 18];
subInterest = 1:nSubs;

% average across channels of interest
muPower = squeeze(mean(trialPowerDB(:,:,:,:,chansInterest),5)); % (sub,cond,window,freqBin)
% average in freq range of interest
muPower = squeeze(mean(muPower(:,:,:,freqInds),4)); % (sub,cond,window)

set(figure,'Position',scrsz); suptitle([num2str(freqUsed) ' Hz Power']);
positions = [1 2 4 5];
for currentCond = 1:nConds
    subplot(2,3,positions(currentCond)); hold on
    for currentSubInd = 1:length(subInterest)
        currentSub = subInterest(currentSubInd);
        currentMuPower = squeeze(muPower(currentSub,currentCond,:));
        plot(t,currentMuPower,'b'); hold on; clear currentMuPower
    end
    meanMuPower = squeeze(mean(muPower(subInterest,currentCond,:),1)); 
    plot(t,meanMuPower,'r','LineWidth',4)
    %axis([-1.5 1.5 -5 5])
    xlabel ('time (s)'); ylabel('power');
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

%% topography: subject max desync (IMPORTANT!) for single condition
% for freqInterest = 1:9; %1:9
condInterest = 2; timeInterest = 4:6; %-1.3:-.2 sec
% freqInterest = [4 4 4 5 9 2 2 5 7 5 6 3]; %best freqs for uncleaned enviro study
freqInterest = 3; freqInterest = ones(1,nSubs)*freqInterest;

set(figure,'Position',scrsz); 
suptitle(['Max ERD, ' condTitles{condInterest}]);%', ' num2str(fVec(freqInterest(1))) ' Hz']);

% trialPowerDB size: (subject x condition x time-window x freq-bin x channel)
% select condition & average across time of interest
topoData = squeeze(mean(trialPOWER(:,condInterest,timeInterest,:,:),3)); 
%(sub,freq,chan)

for currentSub = 1:nSubs   
    subTopoData = squeeze(topoData(currentSub,freqInterest(currentSub),:));
    % topoData(sub,freq,chan)  ==>  subTopoData(chan)
    
   subplot(2,3,currentSub);   
   corttopo(-subTopoData,hm,'drawElectrodes',1);
%    set(gca,'clim',[-2 2]);

   title(subjects{currentSub}{1});          
end
% end

%% topography: intersubject max desync across conditions (4 topos)
timeInterest = 4:6; freqInterest = [4 4 4 5 9 2 2 5 7 5 6 3];
% trialPowerDB size: (subject x condition x time-window x freq-bin x channel)
topoData = NaN(nSubs,nConds,nWins,nChans);
for sub = 1:nSubs % select freq of interest for each sub and squeeze
    topoData(sub,:,:,:) = squeeze(trialPowerDB(sub,:,:,freqInterest(sub),:));
    % topoData(sub x cond x time x chan)
end
% average across subjects
topoData = squeeze(mean(topoData,1)); % (cond,time,chan)
% average across time window of interest
topoData = squeeze(mean(topoData(:,timeInterest,:),2)); %(cond,chan)
set(figure,'Position',scrsz); 
suptitle('InterSubject Max ERD (dB)');
for cond = 1:4
    subplot(2,2,cond); 
    corttopo(squeeze(-topoData(cond,:)'),hm,'drawElectrodes',1);
    set(gca,'clim',[-0.5 1.3]);
    title(condTitles{cond})
end

%% topography: time x freq (7 x 4 topos) across subjects @condition
condInterest = 2; 
subInterest = 1:nSubs;
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
       %set(gca,'clim',[-0.8 1.2]);
       
       title([num2str(t(winsUsed(winInd))) ' s, ' num2str(fVec(currentFreq)) ' Hz']);        
   end
end

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

% end
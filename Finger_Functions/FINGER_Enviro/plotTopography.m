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

% COMMON AVERAGE REFERENCE 
% trialPOWER = trialPOWER - repmat(mean(trialPOWER,5),[1 1 1 1 nChans]);
% trialPowerDB = trialPowerDB - repmat(mean(trialPowerDB,5),[1 1 1 1 nChans]);

% Picking 4 conditions of interest
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

set(figure,'Position',scrsz); suptitle([num2str(freqUsed) ' Hz Power (dB)']);
positions = [1 2 4 5];
for currentCond = 1:nConds
    subplot(2,3,positions(currentCond)); hold on
    for currentSubInd = 1:length(subInterest)
        currentSub = subInterest(currentSubInd);
        currentMuPower = squeeze(muPower(currentSub,currentCond,:));
        plot(t,currentMuPower,'b'); clear currentMuPower
    end
    meanMuPower = squeeze(mean(muPower(subInterest,currentCond,:),1)); 
    plot(t,meanMuPower,'r','LineWidth',4)
    axis([-1.5 1.5 -5 5])
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

%% topography: subject max desync (IMPORTANT!) for single condition
% condInterest = 1; windInterest = 8; freqInterest = 3; % t=0, f=10
% % trialPowerDB size: (subject x condition x time-window x freq-bin x channel)
% set(figure,'Position',scrsz); 
% suptitle([condTitles{condInterest} ',t=' num2str(t(windInterest)) ',f=' num2str(fVec(freqInterest))]);
% 
% % average across condition/time/freq
% topoData = squeeze(trialPowerDB(:,condInterest,windInterest,freqInterest,:)); % (sub,chan)
% for currentSub = 1:nSubs  
%    subplot(3,4,currentSub);
%    currentTopo = squeeze(topoData(currentSub,:));
%    corttopo(currentTopo,hm,'drawElectrodes',0);
% %    set(gca,'clim',[-4 8]);
% 
%    title(subjects{currentSub}{1});          
% end

%% topography: intersubject max desync across conditions (4 topos)

%% topography: time x freq (across subjects @condition)
condInterest = 1; 
subInterest = [2 3 5 6 7 9 10 11 12 13 14 16 18];
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
       set(gca,'clim',[-1.2 1.5]);
       
       title([num2str(t(winsUsed(winInd))) ' s, ' num2str(fVec(currentFreq)) ' Hz']);        
   end
end


% %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% plotting inter-subject topography data (max desync value)
% subFreqs = [15 10 25 20 20 10 15 20 5 15 35 20];
% 
% scrsz = [25 75 1600 850]; set(figure,'Position',scrsz); 
% suptitle(['ERD (dB), Condition ' num2str(condition) ', ' condStr{condition}]);
% dBPower = cell(1,nSubs);
% allSubPower = zeros(nSubs,nChans);
% 
% for currentSub = 1:nSubs        
%     baseline = repmat(mean(trialPower{currentSub}(:,baseInd),2),[1 nWins]);
%     dBPower{currentSub}  = 10*log10(trialPower{currentSub}./baseline);
% %     [~, minimizeMuIndex] = min(squeeze(mean(dBPower{currentSub}(motorChans,:),1)));
%     minimizeMuIndex = 4:6; % .8-1.2 seconds into trial
%     
% 
%     subplot(floor(sqrt(nSubs)),ceil(sqrt(nSubs)),currentSub)
%     subname = subjects{currentSub};   
%     subname = subname{1};    
%     title([subname ': ' num2str(freqUsed(currentSub)) ' Hz'])
%     
%     powerTopo = squeeze(mean(-dBPower{currentSub}(:,minimizeMuIndex),2));
%     corttopo(powerTopo,hm,'drawelectrodes',0)       
%     allSubPower(currentSub,:) = powerTopo;
%     %set(gca,'clim',[-0.5 1.5])
%     colorbar
% 
% end
% 
% figure; 
% suptitle(['MEAN ERD (dB), Condition ' num2str(condition) ', ' condStr{condition}]);
% meanPower = squeeze(mean(allSubPower([1],:),1));
% corttopo(meanPower,hm,'drawelectrodes',0);
% % set(gca,'clim',[0 0.7])
% colorbar

%% time series result (fft preview)
% 
% set(figure,'Position',scrsz); hold on
% suptitle(['ERD (' num2str(curFreq) ' dB), Condition ' num2str(condition) ', ' condStr{condition}]);
% meanSmcPower = zeros(1,nWins);
% meanAvgPower = zeros(1,nWins);
% for currentSub = 1:nSubs
%     smcPower = squeeze(mean(dBPower{currentSub}(motorChans,:),1));
%     avgPower = squeeze(mean(dBPower{currentSub}(:,:),1));
%     t = N*(1:length(smcPower))/fs;
%     plot(t,smcPower,'r'); plot(t,avgPower);    
%     meanSmcPower = meanSmcPower+smcPower;
%     meanAvgPower = meanAvgPower+avgPower;
% end
% meanSmcPower = meanSmcPower./nSubs;
% meanAvgPower = meanAvgPower./nSubs;
% plot(t,meanSmcPower,'r','LineWidth',5);
% plot(t,meanAvgPower,'LineWidth',5);
% legend('SMC','AllChans','Location','Best');
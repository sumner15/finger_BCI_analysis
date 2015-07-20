%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% interSub reads in the trial power data for all participants from file
%
% trialPOWER: {song} (freq x time) 
% trialPowerDB: {song} (freq x time)
% baseSamples
% 
% Author: Sumner Norman (slnorman@uci.edu)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Movement Anticipation and EEG: Implications for BCI-robot therapy
 subjects = {'BECC','TRUS','DIMC','GUIR','LURI','NAVA',...
            'NAZM','TRAT','TRAV','POTA','DIAJ','TRAD'};      
        
%% common vars
fSize = [ 10 50 1400 750];
nSubs = length(subjects);       
nSongs = 6;
nFreqs = 36;
nTime = 3000;
fInterestInd = 3; %index of frequencies of interest

%% set username
if ~exist('username','var')
    username = input('Username: ','s');
end

%% loading FFT (all channel) power data
SetPathEnviro(username);
load('cleanFFTPower.mat');

%% interSubject trial power (dB) PCs
% average across subs
interSubPower = squeeze(mean(trialPowerDB,1)); %now (song,time,freq,chan)
% flatten at frequency of interest
interSubPower = squeeze(mean(interSubPower(:,:,fInterestInd,:),3)); %(song,time,chan)

set(figure,'Position',fSize); iPlot = 1;
suptitle(['PCA, Across Subjects, ' num2str(fVec(fInterestInd)) ' Hz'])
for song = [2 3 5]
    % flatten at current song
    dataIn = squeeze(interSubPower(song,:,:))'; %(chan x time)
    % compute primary components
    PC = eegPCA(dataIn);
        
    for pcNum = 1:3
        subplot(3,6,iPlot); iPlot = iPlot+1;
        title(['PC #' num2str(pcNum) ' Channel Weighting'],'FontSize',14);
        corttopo(PC.component(:,pcNum),hm,'drawElectrodes',false);        
        
        subplot(3,6,iPlot); iPlot = iPlot+1;        
        plot(t,PC.time(pcNum,:),'r','LineWidth',4);
        title(['Power (PC var = ' num2str(round(PC.evals(pcNum))) '%)'],'FontSize',14);
        xlabel('time (s)','FontSize',14); 
        ylabel(condTitles{song},'FontSize',18);
    end
end

%% loading (wavelet) subject trial power data
% sub = 1;
% while sub <= nSubs
%     try
%         subname = subjects{sub};       
%         clear trialPower trialPowerDB
%         setPathEnviro(username,subname)
%         filename = celldir([subname '*trialPower.mat']);
%         filename{1} = filename{1}(1:end-4);
%         disp(['Loading ' filename{1} '...'])    
%         eval([subname ' = load(filename{1});']);        
%         sub = sub+1;
%     catch me
%         disp(['Could not load data for ' subname]);
%         subjects(:,sub) = [];        
%         nSubs = nSubs-1;
%     end
% end
%
% %% restructuring (wavelet, motor only) data from 
% % subj_trialPower{song}(freq x time)   to...
% % *** trialPower(subj x song x freq x time) ***
% trialPower = zeros(nSubs,nSongs,nFreqs,nTime);
% trialPowerDB = zeros(nSubs,nSongs,nFreqs,nTime);
% 
% for sub = 1:nSubs
%     subname = subjects{sub};
%     subData = eval(subname);
%     for song = 1:nSongs
%         trialPower(sub,song,:,:) = subData.trialPower{song};
%         trialPowerDB(sub,song,:,:) = subData.trialPowerDB{song};
%     end
% end
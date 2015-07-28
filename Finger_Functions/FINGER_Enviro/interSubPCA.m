%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% interSub reads in the trial power data for all participants from file
%
% trialPOWER: {song} (subs x condition x t-windows x freq x channel)
% trialPowerDB: {song} (subs x condition x t-windows x freq x channel)
% condtitles: {song} string of condition titles
% fVec: (1 x nFreqs) vector of frequencies resolved by fft
% hm: head model
% subjects: {nSubs} 4-letter string of sub identifier (e.g. 'AAAA')
% 
% Author: Sumner Norman (slnorman@uci.edu)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Movement Anticipation and EEG: Implications for BCI-robot therapy
 subjects = {'BECC','TRUS','DIMC','GUIR','LURI','NAVA',...
            'NAZM','TRAT','TRAV','POTA','DIAJ','TRAD'};      
        
%% common vars
figSize = [ 10 50 1400 750];
nSubs = length(subjects);       
nSongs = 6;
nFreqs = 36;
nTime = 3000;

fInterestInd = 7;           %index of frequencies of interest
nPCs = 2;                   %number of Primary Components to plot
songsInterest = [3 5];    %songs of interest to plot
nSongsInt = length(songsInterest);

%% set username
if ~exist('username','var')
    username = input('Username: ','s');
end

%% loading FFT (all channel) power data
setPathEnviro(username);
load('cleanFFTPower.mat');
% check that all subjects are accounted for
if size(trialPowerDB,1)~= nSubs
    error('subject mismatch');
end

%% interSubject trial power (dB) PCs
% average across subs
interSubPower = squeeze(mean(trialPowerDB,1)); %now (song,time,freq,chan)
% flatten at frequency of interest
interSubPower = squeeze(mean(interSubPower(:,:,fInterestInd,:),3)); %(song,time,chan)

set(figure,'Position',figSize); iPlot = 1;
suptitle(['PCA, Across Subjects, ' num2str(fVec(fInterestInd)) ' Hz'])
for song = songsInterest
    % flatten at current song
    dataIn = squeeze(interSubPower(song,:,:))'; %(chan x time)
    % compute primary components
    PC = eegPCA(dataIn);
        
    for pcNum = 1:nPCs
        subplot(nSongsInt,2*nPCs,iPlot); iPlot = iPlot+1;
        title(['PC #' num2str(pcNum) ' Channel Weighting'],'FontSize',14);
        corttopo(PC.component(:,pcNum),hm,'drawElectrodes',false);        
        
        subplot(nSongsInt,2*nPCs,iPlot); iPlot = iPlot+1;        
        plot(t,PC.time(pcNum,:),'r','LineWidth',4);
        title(['Power (PC var = ' num2str(round(PC.evals(pcNum))) '%)'],'FontSize',14);
        xlabel('time (s)','FontSize',14); 
        ylabel(condTitles{song},'FontSize',18);
    end
end

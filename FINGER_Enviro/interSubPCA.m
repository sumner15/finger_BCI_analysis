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

fInterestInd = 3;           %index of frequencies of interest
nPCs = 2;                   %number of Primary Components to plot
songsInterest = [2 4];      %songs of interest to plot
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
subPlotInds = [3 4 7 8 1 2 5 6];
% suptitle(['PCA, Across Subjects, ' num2str(fVec(fInterestInd)) ' Hz'])
for song = songsInterest
    % flatten at current song
    dataIn = squeeze(interSubPower(song,:,:))'; %(chan x time)
    % compute primary components
    PC = eegPCA(dataIn);
        
    for pcNum = 1:nPCs
        % plot topography
        subplot(nSongsInt,2*nPCs,subPlotInds(iPlot)); iPlot = iPlot+1;
%         title(['PC #' num2str(pcNum) ' (Weight = ' ...
%                num2str(round(PC.evals(pcNum))) '%)'],'FontSize',20);
           title(['weight = ' num2str(round(PC.evals(pcNum))) '%'],'FontWeight','normal','FontSize',30);
        corttopo(PC.component(:,pcNum),hm,'drawElectrodes',false);               
        
        % plot time series (after weighting)
        subplot(nSongsInt,2*nPCs,subPlotInds(iPlot)); iPlot = iPlot+1;        
        plot(t,PC.time(pcNum,:),'r','LineWidth',3);
%         title('Weighted Power','FontSize',20);
        xlabel('time relative to target (s)','FontSize',30); 
%         ylabel(condTitles{song},'FontSize',18);
        ylabel('power (dB)','FontSize',30);
        axis([-1.5 1.5 -6 6]);
        ax = gca;
        ax.XTick = -1:1;
        ax.YTick = -6:3:6;
        set(gca,'FontSize',26)
    end
end

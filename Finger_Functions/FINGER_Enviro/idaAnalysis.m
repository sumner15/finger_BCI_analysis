%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% idaAnalysis is a wrapper function for the IDA analysis functions in the
% CBSMPC repository. This function reorganizes data from the FINGER
% environmental data set for use in IDA.
%
% interSub reads in the trial power data for all participants from file
% and organizes that data for use in ida_feature_extraction_matrix.m.
%
% note: the ida format...
% %[Tida, Muida] = ida_feature_extraction_matrix(m,Train,Group,Method, ...
%                                Tol,MaxIter,InitCondition,Nruns)
%
% LOADED FROM FILE: 
% trialPOWER: {song} (subs x condition x t-windows x freq x channel)
% trialPowerDB: {song} (subs x condition x t-windows x freq x channel)
% condtitles: {song} string of condition titles
% fVec: (1 x nFreqs) vector of frequencies resolved by fft
% hm: head model
% subjects: {nSubs} 4-letter string of sub identifier (e.g. 'AAAA')
% 
% Author: Sumner Norman (slnorman@uci.edu)
% Jul 27 2015
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Movement Anticipation and EEG: Implications for BCI-robot therapy
clear
%% loading data
startDir = pwd;
setPathEnviro('LAB')
load singleTrialFFT.mat
cd(startDir)

%% common vars
figSize = [ 10 50 1600 900];
[nSubs, nSongs, nWins, nFreqs, nChans, nTrials] = size(trialPowerDB);
C = 2;  %number of classes

%% chosen vars
fInterestInd = 3;           %index of frequencies of interest 
songsInterest = [2 3];      %songs of interest to plot
subsInterest = 3;     %subs of interest (averaged)
m = 1;                      %m: size of feature space 

fprintf('freq of interest: %iHz\n',fVec(fInterestInd));
if length(condTitles)==6; condTitles = condTitles(2:5); end
disp(['conditions: ' condTitles{songsInterest(1)} ' vs. ' condTitles{songsInterest(2)}]);

%% Averaging/Selecting across dimensions (reduction)
% average across subs
interSubPower = squeeze(nanmean(trialPowerDB(subsInterest,:,:,:,:,:),1)); %now (cond,win,freq,chan,trial)
% flatten at frequency of interest
interSubPower = squeeze(nanmean(interSubPower(:,:,fInterestInd,:,:),3)); %(cond,win,chan,trial)
% select conditions (classes) we want to classify
interSubPower = interSubPower(songsInterest,:,:,:); %(cond,win,chan,trial)

%% organize into correct size (nTrials*nClasses x nChans*nWins)
% this is a tall matrix of flattened windows/trials/classes of width channels
Train = NaN(C*nTrials , nChans*nWins);
Group = NaN(C*nTrials , 1);
for class = 1:C
   for trial = 1:nTrials
       verticalIndex = (class-1)*nTrials + trial;
       % vertical vector of class labels corresponding to 'Train'
       Group(verticalIndex) = class-1;
       for window = 1:nWins
           horizontalIndex = (window-1)*nChans+1:(window-1)*nChans+nChans;
           % Training data 
           Train(verticalIndex,horizontalIndex) = ...
               squeeze(interSubPower(class,window,:,trial));
       end
   end
end
%remove NaN rows
nanInds = max(isnan(Train),[],2);
Train(nanInds,:) = [];
Group(nanInds) = [];

%% choosing analysis based on data size
ida = size(Train,2)*10 < size(Train,1);
cpca = ~ida;

%% running CPCA analysis
if cpca   
    methodString = 'CPCA & AIDA';
    DRmatC = dataproc_func_cpca(Train,Group,m,'empirical',{'mean'},'aida');
    % find feature space
    FeatureTrain = Train*DRmatC{1};  %(C*nTrials x m)
    M = max([abs(DRmatC{1}); abs(DRmatC{2})]); %normalizes to +-1
    T = reshape(DRmatC{1},nChans,nWins)/M;       
end

%% running ida analysis
if ida       
    methodString = 'IDA';
    Method = 'tr';    
    Tol = 10^(-8)*[1 1];    
    MaxIter = 2000;    
    InitCond = 'lda';    
    Nruns = 10;
    
    [T, Mu] =  ida_feature_extraction_matrix(m,Train,Group, ...
              Method,Tol,MaxIter,InitCond,Nruns);   
    
    % find feature space      
    FeatureTrain = Train*T';  %(C*nTrials x 1)
end

%% computing resulting time series
classPower = zeros(C,nWins);
chanPower = squeeze(mean(interSubPower,4)); %avg trials (cond,win,chan)
for class = 1:C
    for window = 1:nWins
        classPower(class,window) = squeeze(chanPower(class,window,:))'*T(:,window);
    end
end

%% plotting channel weighting & feature space
set(figure,'Position',figSize); 
suptitle([methodString ' topography :: ' condTitles{songsInterest(1)}...
    ' vs. ' condTitles{songsInterest(2)} ', ' num2str(fVec(fInterestInd))... 
    ' Hz, ' num2str(length(subsInterest)) ' subject(s)']);
for window = 1:5
    subplot(3,5,window)
    fftWins = (window-1)*3+1:(window*3);
    corttopo(mean(T(:,fftWins),2),hm,'drawElectrodes',0)
    caxis([-1 1]); 
end

% class power
subplot(3,5,6:10)
plot(t,classPower','LineWidth',4)
legend(condTitles{songsInterest(1)},condTitles{songsInterest(2)});
title('time series representation by class')
xlabel('time(sec relative to target time)'); ylabel('Power (dB)')

% feature space
subplot(3,5,11:15)
for class = 1:C   
    ph = plot(FeatureTrain(Group==class-1,1),zeros(size(FeatureTrain(Group==class-1,1))),'o');      
    hold on
end
title([methodString ' feature space']);
legend(condTitles{songsInterest(1)},condTitles{songsInterest(2)});
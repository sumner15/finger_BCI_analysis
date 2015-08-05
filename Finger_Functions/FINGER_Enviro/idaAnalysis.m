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
figSize = [ 10 50 1400 750];
[nSubs nSongs nWins nFreqs nChans nTrials] = size(trialPowerDB);

fInterestInd = 7;           %index of frequencies of interest 
fprintf('freq of interest: %iHz\n',fVec(fInterestInd));
songsInterest = [2 4];      %songs of interest to plot
nSongsInt = length(songsInterest);
if length(condTitles)==6
    condTitles = condTitles(2:5);
end
disp(['conditions: ' condTitles{songsInterest(1)} ' vs. ' condTitles{songsInterest(2)}]);

%% organizing data for use in ida_feature_extraction_matrix.m:
% average across subs
interSubPower = squeeze(nanmean(trialPowerDB,1)); %now (cond,win,freq,chan,trial)
% flatten at frequency of interest
interSubPower = squeeze(nanmean(interSubPower(:,:,fInterestInd,:,:),3)); %(cond,win,chan,trial)
% get rid of conditions we don't care about
interSubPower = interSubPower(songsInterest,:,:,:); %(cond,win,chan,trial)
% organize into correct size (nWins*nTrials*nClasses x nChans)
% this is a tall matrix of flattened windows/trials/classes of width channels
Train = NaN(nSongsInt*nTrials*nWins , nChans);
Group = NaN(nSongsInt*nTrials*nWins , 1);
for class = 1:nSongsInt
   for trial = 1:nTrials
       for window = 1:nWins
           verticalIndex = (class-1)*(nTrials*nWins)+(trial-1)*nWins+window;
           % Training data (lotsOfReplicates x channel)
           Train(verticalIndex,:) = squeeze(interSubPower(class,window,:,trial));
           % vertical vector of class labels corresponding to 'Train'
           Group(verticalIndex) = class-1;
       end
   end
end
%remove NaN 
nanInds = max(isnan(Train),[],2);
Train(nanInds,:) = [];
Group(nanInds) = [];

%% running ida analysis!
%m: size of feature space 
m = 2;                     
%Train: (Nt x n) is the statistical data of interest
%Group: vector of class labels corresponding to Train
%Method: is a string: 'tr' trust-region, 'cg' conjugate gradient 
Method = 'tr';
%Tol: (1 x 2) vector of tolerances:
Tol = 10^(-8)*[1 1];
%MaxIter - (1 x 1) maximum number of iterations
MaxIter = 2000;
%InitCondition - is a string: 'random' random initial feature extraction matrix
%                             'lda' linear discriminant analysis matrix
%                             'che' the matrix proposed by Loog & Duin
InitCond = 'lda';
%Nruns - (1 x 1) the number of optimization runs.
Nruns = 10;

% IDA ANALYSIS RUNS HERE
[T Mu] =  ida_feature_extraction_matrix(m,Train,Group, ...
          Method,Tol,MaxIter,InitCond,Nruns);
      
% find feature space
FeatureTrain = Train*T';                             

%% plotting channel weighting
set(figure,'Position',figSize); 
suptitle(['IDA Feature Space (T) topography (m=' num2str(m)...
    ') :: ' condTitles{songsInterest(1)} ' vs. ' condTitles{songsInterest(2)}...
    ' (' num2str(nSongsInt) ' classes) ' num2str(fVec(fInterestInd)) ' Hz']);
for feature = 1:m
    subplot(floor(sqrt(m)),ceil(sqrt(m)),feature)
    corttopo(T(feature,:),hm,'drawElectrodes','false')
end

%% plotting feature space
set(figure,'Position',[10 50 700 700]); 
for feature = 1:m    
    ph = plot(FeatureTrain(Group==feature-1,1),FeatureTrain(Group==feature-1,2),'o');   
    hold on
end
set(gca,'DataAspectRatio',[1 1 1])
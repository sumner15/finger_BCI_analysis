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
clearvars -except condTitles dimensionLables fVec hm subjects t ...
                  trialPOWER trialPowerDB windowLength
%% loading data
startDir = pwd;
if ~exist('trialPOWER','var') || ~exist('trialPowerDB','var')    
    setPathEnviro('LAB')
    fprintf('Loading singleTrialFFT.mat...');
    load singleTrialFFT.mat
    fprintf('done.\n');
    cd(startDir)
else
    disp('Single Trial FFT data already loaded');
end

%% common vars
figSize = [ 10 50 1600 900];
% trialPowerDB is (subject, song, window, freq, chan, trial)
[nSubs, nSongs, ~, ~, nChans, nTrials] = size(trialPowerDB);

%% chosen vars
tInterestInd = 4:9;         %index of time of interest [1,15]
fInterestInd = 2:9;         %index of frequencies of interest 
songsInterest = [1 4];      %songs of interest to plot
C = length(songsInterest);  %number of classes
subsInterest = 1:nSubs;     %subs of interest (averaged)
m = 1;                      %m: size of feature space 

%print selections
nFreqs = length(fInterestInd);
if length(fVec)~=nFreqs; fVec = fVec(fInterestInd); end
disp(['freq of interest: ' num2str(fVec)]);

if length(condTitles)==6; condTitles = condTitles(2:5); end
disp(['conditions: ' condTitles{songsInterest(1)} ' vs. ' ...
                     condTitles{songsInterest(2)}]);

nSubs = length(subsInterest);
disp(['N = ' num2str(length(subsInterest)) ' subjects analyzed']);
disp(['m = ' num2str(m)]);
nWins = length(tInterestInd);
disp(['t = ' num2str(t(tInterestInd(1))) ' to ' ...
             num2str(t(tInterestInd(end))) ' sec']);

%% Averaging/Selecting across dimensions (reduction)
% selecting subjects/freq/conditions of interest 
%(sub,cond,win,freq,chan,trial)
reshapedPower =trialPowerDB(subsInterest,songsInterest,tInterestInd,fInterestInd,:,:);

%% organize into correct size (nTrials*nClasses x nChans*nWins)
% this is a tall matrix of flattened subs*class*trial*win of width
% channels*freqs
fprintf('Organizing training data set');
Train = NaN(nSubs*C*nTrials , nChans*nFreqs);
Group = NaN(nSubs*C*nTrials , 1);
subNum = NaN(nSubs*C*nTrials , 1);
for sub = 1:nSubs
    fprintf('.');
    for class = 1:C
       for trial = 1:nTrials
           for win = 1:nWins
               verticalIndex = (sub-1)*(C*nTrials*nWins)+...
                   (class-1)*(nTrials*nWins) + trial*(nWins)+ win;
               % vertical vector of class labels corresponding to 'Train'
               Group(verticalIndex) = class-1;
               subNum(verticalIndex) = sub;
               for freq = 1:nFreqs
                   horizontalIndex = (freq-1)*nChans+1:(freq-1)*nChans+nChans;
                   % Training data 
                   Train(verticalIndex,horizontalIndex) = ...
                       squeeze(reshapedPower(sub,class,win,freq,:,trial));
               end
           end
       end
    end
end
%remove NaN rows
nanInds = max(isnan(Train),[],2);
Train(nanInds,:) = [];
Group(nanInds) = [];
subNum(nanInds) = [];
fprintf('\n');

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
    T = reshape(DRmatC{1},nChans,nFreqs)/M;      
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

%% computing resulting freq spectra
classPower = zeros(C,nFreqs);
chanPower = squeeze(nanmean(reshapedPower,1));  %avg subs
chanPower = squeeze(nanmean(chanPower,5));      %avg trials
chanPower = squeeze(nanmean(chanPower,2));      %avg time
for class = 1:C
    for freq = 1:nFreqs
        classPower(class,freq) = squeeze(chanPower(class,freq,:))'*...
            T(:,freq);
    end
end

%% plotting channel weighting & feature space
set(figure,'Position',figSize); 
suptitle([methodString ' topography :: ' condTitles{songsInterest(1)}...
    ' vs. ' condTitles{songsInterest(2)} ', ' ...
    num2str(fVec(1)) '-' num2str(fVec(end)) ' Hz, ' ...
    num2str(length(subsInterest)) ' subject(s)'...
    ', t = ' num2str(t(tInterestInd)) 'sec']);
for freq = 1:nFreqs
    subplot(3,nFreqs,freq)    
    corttopo(T(:,freq),hm,'drawElectrodes',0)
    caxis([-1 1]); 
    title([num2str(fVec(freq)) ' Hz']);
end

% class power spectra
subplot(3,nFreqs,nFreqs+1:nFreqs*2)
plot(fVec,classPower','LineWidth',4)
legend(condTitles{songsInterest(1)},condTitles{songsInterest(2)});
title('power spectra representation by class')
xlabel('freq (Hz)'); ylabel('Power (dB)')

% feature space
subplot(3,nFreqs,nFreqs*2+1:nFreqs*3)
for class = 1:C   
    ph = plot(FeatureTrain(Group==class-1,1),...
        zeros(size(FeatureTrain(Group==class-1,1))),'o');      
    hold on
end
title([methodString ' feature space']);
legend(condTitles{songsInterest(1)},condTitles{songsInterest(2)});

%% commence classification testing
testClassify = input('Would you like to classify? (type y or n): ','s');

if strcmp(testClassify,'y') && cpca     
    fprintf('Classifying ');   
    percCorrect = NaN(1,nSubs);
    for sub = 1:nSubs
        subTrain = Train(subNum == sub,:);
        subGroup = Group(subNum == sub);
        nReps = size(subTrain,1);
        correct = zeros(1,nReps);        
        for rep = 1:nReps 
            if mod(rep,3)==0; fprintf('.'); end

            % leave one out index
            leaveOut = rep;

            % create training set for validation (leaves one out)
            trainValid = subTrain; 
            trainValid(leaveOut,:)=[];
            trainValidGroup = subGroup;
            trainValidGroup(leaveOut) = [];
            % create validation set (the one left out)        
            valid = subTrain(leaveOut,:);
            validGroup = subGroup(leaveOut,:);

            % Use CPCA/IDA to create train the set
            DRmatC = dataproc_func_cpca(trainValid,trainValidGroup,m,...
                'empirical',{'mean'},'aida');

            % find feature space points
            FeatureTrain = (trainValid * DRmatC{1});
            FeatureValid = (valid * DRmatC{1});        

            % classify our left out trial
            classPredicted = classify(FeatureValid,FeatureTrain,....
                trainValidGroup,'linear','empirical');               

            % count how many we got right        
            correct(rep) = classPredicted == subGroup(rep);        
        end        
        percCorrect(sub) = mean(correct)*100;
        fprintf('\nSub %i classification accuracy: %i/%i = %3.2f%% \n',...
                sub,sum(correct),nReps,percCorrect(sub));    
    end   
    fprintf(['-----------------------------------------------\n',...
        'Overall Accuracy: %3.2f%% (50%% chance)\n'],mean(percCorrect));
end

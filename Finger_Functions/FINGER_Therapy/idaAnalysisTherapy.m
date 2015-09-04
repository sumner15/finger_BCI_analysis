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
% Aug 06, 2015
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
%% loading data
startDir = pwd;
setPathTherapy('LAB')
disp('loading single trial FFT & clinical data')
load singleTrialFFT.mat
load therapyData.mat 
cd(startDir)

%% common vars
figSize = [ 10 50 1600 900];
% trialPowerDB is (subject, song, window, freq, chan, trial)
[nSubs, ~, nWins, ~, nChans, nTrials] = size(trialPowerDB);
 
C = 2;  %number of classes

%% chosen vars
% tInterestInd = 4:7;         %index of time of interest [1,15]
fInterestInd = 2:9;         %index of frequencies of interest 
songsInterest = [1 2];      %songs included in training set (NOT classified)
m = 1;                      %m: size of feature space 
outcome = 'MG';             %choose from MG,BB,FM
plotBool = true;            %to plot or not to plot.. that is the ?

% print selections
nFreqs = length(fInterestInd);
if length(fVec)~=nFreqs; fVec = fVec(fInterestInd); end
disp(['freq of interest: ' num2str(fVec)]);

disp(['clinical outcome of interest: ' outcome]);
nSongs = length(songsInterest); 

disp(['N = ' num2str(nSubs) ' subjects analyzed']);
disp(['m = ' num2str(m)]);

%% creating high/low groups
switch outcome
    case 'MG'
        dataHead{1} = 'PercHitSD[1]';
        dataHead{2} = 'PercHitSD[2]';  
        cutoff = 0;        
    case 'BB'
        dataHead{1} = 'B&B (Affected) Test [1]';
        dataHead{2} = 'B&B (Affected) Test [2]';
        cutoff = 1;
    case 'FM'
        dataHead{1} = 'FMAMA Total [1]';
        dataHead{2} = 'FMAMA Total [3]';
        cutoff = 4;
end
% outcomes: 'FMAMA Total [#]','B&B (Affected) Test [#]','PercHitSD[#]'
condTitles = {['low delta ' outcome],['high delta ' outcome]};
disp(['reset conditions to ' condTitles{1} ' & ' condTitles{2}]);
tableSubs = therapyTextData(:,1);         % column of subject id's
groupIndex1 = ismember(therapyTextData(1,:),dataHead{1}); %finds group column
groupIndex2 = ismember(therapyTextData(1,:),dataHead{2}); %finds group column
tableGroup1 = therapyData(:,groupIndex1); % stores group numbers
tableGroup2 = therapyData(:,groupIndex2); % stores group numbers
tableGroup = tableGroup2-tableGroup1;     % e.g. delta-B&B

% plot histogram of outcome 
if plotBool
    set(figure,'Position',[10 50 300 200]); 
    hist(tableGroup)
    xlabel(['delta ' outcome]);
end

% separate high and low subs
lowSubs = []; highSubs = [];         % array of indices for hi/lo subs
for currentSub = 1:nSubs
    subname = subjects{currentSub};      
    tableSubInd = ismember(tableSubs,subname); %index of sub in table
    group = tableGroup(tableSubInd); %current sub's group level    
    if group < cutoff
        lowSubs = [lowSubs currentSub];    
    elseif group >= cutoff
        highSubs = [highSubs currentSub];
    else 
        warning([subname ': group level is not properly defined']);
    end
end

% create array of subject classes 
allSubClass = NaN(nSubs,1);      
allSubClass(lowSubs) = 0; 
allSubClass(highSubs) = 1;

% rearrange for NaN subjects
nSubs = length(lowSubs)+length(highSubs); %update nSubs to exclude NaNs
subClass = allSubClass(~isnan(allSubClass));  % throws out NaN subjects 
if size(trialPowerDB,1)~=nSubs
    trialPowerDB(isnan(allSubClass),:,:,:,:,:) = [];
end


%% looking at one time window at a time (this is a big loop!)
accuracy = NaN(1,nWins);
for tInterestInd = 1:15
nWins = length(tInterestInd);
disp(['t = ' num2str(t(tInterestInd(1))) ' to ' ...
             num2str(t(tInterestInd(end))) ' sec']);
         
%% Resisizing data for classification
disp('resizing data for classification...')
% take a subset of songs into account (combining them into many trials)
nTrials = size(trialPowerDB,6);
reshapedPower = squeeze(NaN([nSubs nWins nFreqs nChans nTrials*nSongs]));
for song = songsInterest
    ind = (song-1)*nTrials+1:song*nTrials;
    % (sub,win,freq,chan,trial*cond)   
    reshapedPower(:,:,:,ind) = ...
        squeeze(trialPowerDB(:,song,tInterestInd,fInterestInd,:,:));
                          % (sub,song,win,freq,chan,trial)
end
nTrials = nTrials*nSongs;

% average over windows (if there are multiple)
if nWins~=1 
    reshapedPower = squeeze(mean(reshapedPower,2)); % (sub,freq,chan,trial)
end

%% organize into correct size (nTrials*nClasses x nChans*nWins)
% this is a tall matrix of flattened windows/trials/classes of width channels
Train = NaN(nTrials*nSubs , nChans*nFreqs);  %training data set
Group = NaN(nTrials*nSubs , 1);             %corresponding class vector
subNum = NaN(nTrials*nSubs, 1);
for subject = 1:nSubs  
   for trial = 1:nTrials
       verticalIndex = (subject-1)*nTrials + trial;
       subNum(verticalIndex) = subject;
       % vertical vector of class labels corresponding to 'Train'
       Group(verticalIndex) = subClass(subject);
       for freq = 1:nFreqs
           horizontalIndex = (freq-1)*nChans+1:(freq-1)*nChans+nChans;
           % Training data 
           Train(verticalIndex,horizontalIndex) = ...
               squeeze(reshapedPower(subject,freq,:,trial));
       end
   end
end
%remove NaN rows
nanInds = max(isnan(Train),[],2);
Train(nanInds,:) = [];
Group(nanInds) = [];
subNum(nanInds) = [];

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

%% computing resulting spectra
classPower = zeros(C,nFreqs);
chanPower = squeeze(nanmean(reshapedPower,4)); %avg trials (cond,freq,chan)
for class = 1:C
    for freq = 1:nFreqs
        classPower(class,freq) = squeeze(chanPower(class,freq,:))'*T(:,freq);
    end
end

%% plotting channel weighting & feature space
if plotBool
    set(figure, 'Position',figSize); 
    suptitle([methodString ' topography :: ' condTitles{1}...
        ' vs. ' condTitles{2} ', ' num2str(fVec(1))... 
        num2str(fVec(end)) ' Hz, '...
        num2str([length(lowSubs) length(highSubs)]) ' subjects']);
    for freq = 1:nFreqs
        subplot(3,nFreqs/2,freq)        
        corttopo(mean(T(:,freq),2),hm,'drawElectrodes',0)
        caxis([-1 1]); 
    end

%     % class power
%     subplot(3,5,6:10)
%     plot(t,classPower','LineWidth',4)
%     legend(condTitles{1},condTitles{2});
%     title('time series representation by class')
%     xlabel('time(sec relative to target time)'); ylabel('Power (dB)')

    % feature space
    subplot(3,nFreqs,nFreqs*2+1:nFreqs*3)
    for class = 1:C   
        ph = plot(FeatureTrain(Group==class-1,1),zeros(size(FeatureTrain(Group==class-1,1))),'o');      
        hold on
    end
    title([methodString ' feature space']);
    legend(condTitles{1},condTitles{2});
end

%% commence classification testing
% testClassify = input('Would you like to classify? (type y or n): ','s');
testClassify = 'y';

if strcmp(testClassify,'y') && cpca     
    fprintf('Classifying ');
    correct = zeros(1,nSubs);
    confidence = zeros(1,nSubs);
    for subject = 1:nSubs
        fprintf(',');
        leaveOut = find(subNum==subject);

        % create training set for validation (leaves one out)
        trainValid = Train; 
        trainValid(leaveOut,:)=[];
        trainValidGroup = Group;
        trainValidGroup(leaveOut) = [];
        % create validation set (the one left out)        
        valid = Train(leaveOut,:);
        validGroup = Group(leaveOut,:);

        % Use CPCA/IDA to create train the set
        DRmatC = dataproc_func_cpca(trainValid,trainValidGroup,m,...
                                    'empirical',{'mean'},'aida');

        % find feature space points
        FeatureTrain = (trainValid * DRmatC{1});
        FeatureValid = (valid * DRmatC{1});        

        % classify our left out trial
        classPredicted = classify(FeatureValid,FeatureTrain,...
                                  trainValidGroup,'linear','empirical');
        subClassPredicted = mean(classPredicted);
        fprintf('%i',round(subClassPredicted))

        % count how many we got right
        if round(subClassPredicted) == subClass(subject)            
            correct(subject) = 1;
        end
        confidence(subject) = (1-abs(subClassPredicted-round(subClassPredicted)))*100;
    end
    percCorrect = mean(correct)*100;
    fprintf('\nClassifaction Accuracy: %i/%i = %3.2f%% \n',sum(correct),nSubs,percCorrect);    
end
accuracy(tInterestInd) = percCorrect;
end

%% plot accuracy as a function of time for each subject
set(figure,'Position',figSize*.5+150); 
hold on

hChance = plot(t,zeros(1,15)+50,'b','lineWidth',4);
hMean = plot(t,accuracy,'-xr','lineWidth',2);

axis([-1.5 1.5 0 100])
xlabel('time (s)')
ylabel('classification accuracy (%)')
title([methodString ' :: ' condTitles{1} ' vs. ' condTitles{2} ', ' ...
       num2str(fVec(1)) '-' num2str(fVec(end)) ' Hz, ' ...
       num2str(nSubs) ' subject(s)']);
legend([hChance hMean],{'chance level','mean classification accuracy'},...
    'Location','best');

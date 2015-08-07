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
[nSubs, nSongs, nWins, nFreqs, nChans, nTrials] = size(trialPowerDB);
C = 2;  %number of classes

%% chosen vars
fInterestInd = 3;           %index of frequencies of interest 
songsInterest = [1 2];      %songs included in training set (NOT classified)
nSongs = length(songsInterest); 
m = 1;                      %m: size of feature space 

fprintf('freq of interest: %iHz\n',fVec(fInterestInd));

%% creating high/low groups
% outcomes: 'FMAMA Total [#]','B&B (Affected) Test [#]','PercHitSD[#]'
condTitles = {'low delta FM','high delta FM'};
disp(['reset conditions to ' condTitles{1} ' & ' condTitles{2}]);
tableSubs = therapyTextData(:,1);         % column of subject id's
groupIndex1 = ismember(therapyTextData(1,:),'FMAMA Total [1]'); %finds group column
groupIndex2 = ismember(therapyTextData(1,:),'FMAMA Total [2]'); %finds group column
tableGroup1 = therapyData(:,groupIndex1); % stores group numbers
tableGroup2 = therapyData(:,groupIndex2); % stores group numbers
tableGroup = tableGroup2-tableGroup1;     % e.g. delta-B&B

lowSubs = []; highSubs = [];          % array of indices for hi/lo subs
for currentSub = 1:nSubs
    subname = subjects{currentSub};      
    tableSubInd = ismember(tableSubs,subname); %index of sub in table
    group = tableGroup(tableSubInd); %current sub's group level
    if group < nanmean(tableGroup(2:end-3))
%     if group <= 10
        lowSubs = [lowSubs currentSub];
    elseif group > nanmean(tableGroup(2:end-3))
%     elseif group > 10
        highSubs = [highSubs currentSub];
    else 
        warning([subname ': group level is not properly defined']);
    end
end

%% Averaging/Selecting across dimensions (reduction)
disp('resizing data for classification...')
% take a subset of songs into account 
reshapedPower = NaN([nSubs nWins nFreqs nChans nTrials*nSongs]);
for song = songsInterest
    ind = (song-1)*nTrials+1:song*nTrials;
    % (sub,win,freq,chan,trial*cond)
    reshapedPower(:,:,:,:,ind) = squeeze(trialPowerDB(:,song,:,:,:,:));
end
% average across subs by class (making the subs our condition!)
interSubPower(1,:,:,:,:) = nanmean(reshapedPower(lowSubs ,:,:,:,:),1); 
interSubPower(2,:,:,:,:) = nanmean(reshapedPower(highSubs,:,:,:,:),1); %now (cond,win,freq,chan,trial)
% flatten at frequency of interest
interSubPower = squeeze(nanmean(interSubPower(:,:,fInterestInd,:,:),3)); %(cond,win,chan,trial)

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
chanPower = squeeze(nanmean(interSubPower,4)); %avg trials (cond,win,chan)
for class = 1:C
    for window = 1:nWins
        classPower(class,window) = squeeze(chanPower(class,window,:))'*T(:,window);
    end
end

%% plotting channel weighting & feature space
% set(figure,'Position',figSize); 
% suptitle([methodString ' topography :: ' condTitles{1}...
%     ' vs. ' condTitles{2} ', ' num2str(fVec(fInterestInd))... 
%     ' Hz, ' num2str([length(lowSubs) length(highSubs)]) ' subject(s)']);
% for window = 1:5
%     subplot(3,5,window)
%     fftWins = (window-1)*3+1:(window*3);
%     corttopo(mean(T(:,fftWins),2),hm,'drawElectrodes',0)
%     caxis([-1 1]); 
% end
% 
% % class power
% subplot(3,5,6:10)
% plot(t,classPower','LineWidth',4)
% legend(condTitles{1},condTitles{2});
% title('time series representation by class')
% xlabel('time(sec relative to target time)'); ylabel('Power (dB)')
% 
% % feature space
% subplot(3,5,11:15)
% for class = 1:C   
%     ph = plot(FeatureTrain(Group==class-1,1),zeros(size(FeatureTrain(Group==class-1,1))),'o');      
%     hold on
% end
% title([methodString ' feature space']);
% legend(condTitles{1},condTitles{2});

%% commence classification testing
testClassify = input('Would you like to classify? (type y or n): ','s');
nSubs = length(lowSubs)+length(highSubs);

if strcmp(testClassify,'y') && cpca                
    nCorrect = 0;
    for trial = 1:length(Group)        
        leaveOut = trial;

        % create training set (leaves one out)
        trainValid = Train; 
        trainValid(leaveOut,:)=[];
        trainValidGroup = Group;
        trainValidGroup(leaveOut) = [];
        % create validate point(the one left out)        
        valid = Train(leaveOut,:);
        validGroup = Group(leaveOut,:);

        % Use CPCA/IDA to create train the set
        DRmatC = dataproc_func_cpca(trainValid,trainValidGroup,m,'empirical',{'mean'},'aida');

        % find feature space points
        FeatureTrain = (trainValid * DRmatC{1});
        FeatureValid = (valid * DRmatC{1});        

        % classify our left out trial
        classPredicted = classify(FeatureValid,FeatureTrain,trainValidGroup,'linear', ...
                 'empirical');

        % count how many we got right
        if classPredicted == validGroup
            nCorrect = nCorrect+1;
        end
    end
    percCorrect = nCorrect/length(Group)*100;
    fprintf('Classifaction Accuracy: %3.2f \n',percCorrect);    
end
function passive_IDA(subname,validate,prepOrMove,condsInterest)
% IDA wrapper for passive/active discrimination in impaired phase 1 data
% set taken 12/2015 for BCI 2016 conference (n=3 stroke).
% For now, I am going to look at ERP's after the movement cue (preparation)
% and around the actual movement period. This function will call a
% segmentation function directly, rather than loading that data in. 
%
% inputs: subname as string (e.g. 'SLN')*
%         *the sub must have pre-processed data (e.g. SLN_preProcessed.mat)
%
%         condsInterest as indices of conditions of interest where
%         % 1 = assisted, 2 = unassisted, 3 = passive
%         % (e.g. condsInterest = [ 1 3 ] to compare assisted/passive
%
% function: wrapper function for the CBMSPC Information Discriminant
% Analysis Functions (AIDA/CPCA, etc). This function will organize the data
% into a labeled 2D training set. Cross validation is also performed here.

%% loading data
passive_setPath();    
load([subname '_preProcessed.mat']); 
segData = passive_segment(data);

%% setting IDA parameters
if nargin ~= 4     
    error('Not enough input arguments.')    
end

C = length(condsInterest);  %number of classes
m = 1;                      %m: size of feature space

% printing IDA parameter selection
disp(['conditions: ' data.runOrderLabels{condsInterest(1)} ' vs. ' ...
                     data.runOrderLabels{condsInterest(2)}]);
disp(['m = ' num2str(m)]);

%% resizing training sets

% training set is ( trial x condition, channel x time/sample)
[nChans,nSamples,nTrials(1)] = size(segData.prep{condsInterest(1)});
nTrials(2) = size(segData.prep{condsInterest(2)},3);

condOne = NaN(nTrials(1),nSamples*nChans);
condTwo = NaN(nTrials(2),nSamples*nChans);
for trial = 1:nTrials(1)
    for chan = 1:nChans     
        colInds = (chan-1)*nSamples+1:chan*nSamples;
        condOne(trial,colInds) = ...
            segData.prep{condsInterest(1)}(chan,:,trial);
    end
end
for trial = 1:nTrials(2)
    for chan = 1:nChans
        colInds = (chan-1)*nSamples+1:chan*nSamples;
        condTwo(trial,colInds) = ...
            segData.prep{condsInterest(2)}(chan,:,trial);
    end
end
trainPrep = [condOne; condTwo];
labelPrep = ones(size(trainPrep,1),1);
labelPrep(1:nTrials(1)) = 0;
nTrialsPrep = sum(nTrials);
nSamplesPrep = nSamples;

% training set for movement phase
nSamples = size(segData.move{condsInterest(1)},2);

condOne = NaN(nTrials(1),nSamples*nChans);
condTwo = NaN(nTrials(2),nSamples*nChans);
for trial = 1:nTrials(1)
    for chan = 1:nChans     
        colInds = (chan-1)*nSamples+1:chan*nSamples;
        condOne(trial,colInds) = ...
            segData.move{condsInterest(1)}(chan,:,trial);
    end
end
for trial = 1:nTrials(2)
    for chan = 1:nChans
        colInds = (chan-1)*nSamples+1:chan*nSamples;
        condTwo(trial,colInds) = ...
            segData.move{condsInterest(2)}(chan,:,trial);
    end
end
trainMove = [condOne; condTwo];
labelMove = ones(size(trainMove,1),1);
labelMove(1:nTrials(1)) = 0;
nTrialsMove = sum(nTrials);
nSamplesMove = nSamples;


%% selecting preparation or movement phase
if strcmp(prepOrMove,'prep')
   Train = trainPrep;
   Group = labelPrep;
   nTrials = nTrialsPrep;
   trialLength = size(segData.prep{condsInterest(1)},2); 
   nSamples = nSamplesPrep;
else
   Train = trainMove;
   Group = labelMove;   
   nTrials = nTrialsMove;
   trialLength = size(segData.move{condsInterest(1)},2);
   nSamples = nSamplesMove;
end

%% choosing analysis based on data size
ida = size(Train,2)*10 < size(Train,1);
cpca = ~ida;

%% running CPCA analysis
if cpca   
    methodString = 'CPCA & AIDA';
    DRmatC = dataproc_func_cpca(Train,Group,m,'empirical',{'mean'},'aida');
    % find feature space
    FeatureSpace = Train*DRmatC{1};  %(C*nTrials x m)
    M = max([abs(DRmatC{1}); abs(DRmatC{2})]); %normalizes to +-1        
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
    FeatureSpace = Train*T';  %(C*repetitions x 1)
end

%% reshaping T for plotting
Tplot = NaN(nChans,nSamples);
for chan = 1:nChans
    vertInds = (chan-1)*nSamples+1 : chan*nSamples;
    Tplot(chan,:) = DRmatC{1}(vertInds,1);
end

%% commence classification testing
if ~exist('validate','var')
    warning('setting validate to true by default (no input received)')
    validate = true;
end
    
if validate          
    fprintf('Classifying ');       
          
    correct = NaN(1,nTrials);       % correct boolean of trial
    trialFeature = NaN(1,nTrials);  % feature space representation of trial
    trialGroup = NaN(1,nTrials);    % class/group of trial
    for trial = 1:nTrials
        fprintf('.');

        % leave one out indices (for trial)        
        leaveOut = trial;    
        % create training set for validation (leaves one out)
        trainValid = Train; 
        trainValid(leaveOut,:)=[];
        trainValidGroup = Group;
        trainValidGroup(leaveOut) = [];
        % create validation set (the one left out)        
        valid = Train(leaveOut,:);
        validGroup = Group(leaveOut,:);
        
        
        % Use CPCA/IDA to train the set        
        if ida
            [T, Mu] =  ida_feature_extraction_matrix(m,trainValid,...
                trainValidGroup,Method,Tol,MaxIter,InitCond,Nruns);      
            % find feature space      
            FeatureTrain = trainValid*T';  %(C*repetitions x 1)
            FeatureValid = valid*T';
        else
            DRmatC = dataproc_func_cpca(trainValid,trainValidGroup,m,...
                'empirical',{'mean'},'aida');
            % find feature space points
            FeatureTrain = (trainValid * DRmatC{1});
            FeatureValid = (valid * DRmatC{1});        
        end
        % this is saved for plotting the feature space later
        trialFeature(trial) = mean(FeatureValid);
        trialGroup(trial) = mode(validGroup);
        
        % classify our left out trial
        classPredicted = classify(FeatureValid,FeatureTrain,....
            trainValidGroup,'linear');%,'empirical');               
        % count how many we got right              
        correct(trial) = mode(classPredicted) == mode(validGroup);
        correct(isnan(correct)) = []; %clearing NaNs if necessary
    end   
    percCorrect = mean(correct)*100;
    fprintf('\n\n ::: Classification accuracy: %i/%i = %3.2f%% :::\n\n',...
            sum(correct),nTrials,percCorrect);      
end

%% plotting channel weighting & feature space
% figSize = [ 10 50 1600 900];
% set(figure,'Position',figSize); 
% if validate
%     suptitle([subname ' :: ' methodString ' :: ' ...
%         data.runOrderLabels{condsInterest(1)} ' vs. ' ...
%         data.runOrderLabels{condsInterest(2)} ...
%         ' :: CLASSIFICATION ACCURACY: ' num2str(percCorrect) '% :: ' ...
%         prepOrMove ' period']);
% else
%     suptitle([subname ' :: ' methodString ' :: ' ...
%         data.runOrderLabels{condsInterest(1)} ' vs. ' ...
%         data.runOrderLabels{condsInterest(2)} ' :: ' ...
%         prepOrMove ' period']);
% end
% % channel weighting
% subplot(3,3,1:6)    
% topoplot(mean(Tplot,2),data.hm);
% % feature space 
% if validate
%     subplot(3,3,7:9)
%     for class = 1:C   
%         plot(trialFeature(trialGroup==class-1),...
%              zeros(size(trialFeature(trialGroup==class-1))),'o');      
%         hold on
%     end
%     nClass1 = length(trialFeature(trialGroup==0));
%     nClass2 = length(trialFeature(trialGroup==1));
%     legend([data.runOrderLabels{condsInterest(1)} ', n = ' num2str(nClass1)],...
%            [data.runOrderLabels{condsInterest(2)} ', n = ' num2str(nClass2)]);
% end
   
%% plotting channel weighting over time
figSize = [ 10 50 1600 900];
set(figure,'Position',figSize); 

suptitle([subname ' :: ' methodString ' :: ' ...
data.runOrderLabels{condsInterest(1)} ' vs. ' ...
data.runOrderLabels{condsInterest(2)} ' :: ' ...
prepOrMove ' period' ...
' :: CLASSIFICATION ACCURACY: ' num2str(round(percCorrect)) '% :: ']);

for i = 1:15
    subplot(3,5,i)
    tWin = (i-1)*17+1 : i*17;
    tSec = round(tWin*1000/data.sr);
    topoData = mean(Tplot(:,tWin),2); % average across a time window
    minLim = mean(Tplot(:))-2*std(Tplot(:)); 
    maxLim = mean(Tplot(:))+2*std(Tplot(:));
    topoplot(topoData,data.hm,'maplimits',[minLim maxLim]);
    colorbar
    title(['t=' num2str(tSec(1)) '-' num2str(tSec(end)) ' ms']);
end

% save figure
fileName = [subname '_' num2str(condsInterest) '_' ...
            num2str(round(percCorrect))];
cd('C:\Users\Sumner\Desktop');        
set(gcf,'PaperPositionMode','auto')
print(fileName,'-dpng','-r0');


end
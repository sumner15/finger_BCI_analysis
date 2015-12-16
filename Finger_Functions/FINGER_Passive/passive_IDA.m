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
tmp = load([subname '_preProcessed.mat']); 
data = tmp.data;
segData = passive_segment(data);

%% setting IDA parameters
if nargin == 1
    % 1 = assisted, 2 = unassisted, 3 = passive
    condsInterest = [1 3];  %conditions of interest    
end
C = length(condsInterest);  %number of classes
m = 1;                      %m: size of feature space

% printing IDA parameter selection
disp(['conditions: ' data.runOrderLabels{condsInterest(1)} ' vs. ' ...
                     data.runOrderLabels{condsInterest(2)}]);
disp(['m = ' num2str(m)]);

%% resizing training sets
% Right now, I am only interested in a channel weighting representation,
% where both trials and time points are considered repetitions. 
% training set is ( trial,time,condition X channel)
nChans = data.bciPrm.SourceCh.NumericValue;
nTrialsPrep = size(segData.prep{condsInterest(1)},3)+...
              size(segData.prep{condsInterest(2)},3);
condOne = segData.prep{condsInterest(1)};
condTwo = segData.prep{condsInterest(2)};
condOne = reshape(condOne,nChans,size(condOne,2)*size(condOne,3))';
condTwo = reshape(condTwo,nChans,size(condTwo,2)*size(condTwo,3))';
trainPrep = [condOne;condTwo];
labelPrep = ones(size(trainPrep,1),1);
labelPrep(1:size(condOne,1),1) = 0;

nTrialsMove = size(segData.move{condsInterest(1)},3)+...
              size(segData.move{condsInterest(2)},3);
condOne = segData.move{condsInterest(1)};
condTwo = segData.move{condsInterest(2)};
condOne = reshape(condOne,nChans,size(condOne,2)*size(condOne,3))';
condTwo = reshape(condTwo,nChans,size(condTwo,2)*size(condTwo,3))';
trainMove = [condOne;condTwo];
labelMove = ones(size(trainMove,1),1);
labelMove(1:size(condOne,1),1) = 0;

if ~exist('prepOrMove','var')
   warning('Selecting ''move'' condition by default')
   prepOrMove = 'move';
end
if strcmp(prepOrMove,'prep')
   Train = trainPrep;
   Group = labelPrep;
   nTrials = nTrialsPrep;
   trialLength = size(segData.prep{condsInterest(1)},2);   
else
   Train = trainMove;
   Group = labelMove;   
   nTrials = nTrialsMove;
   trialLength = size(segData.move{condsInterest(1)},2);
end

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
    warning('T is probably calculated incorrectly here. Check function.')
    T = reshape(DRmatC{1},nChans)/M; % This is probably wrong! 
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
    FeatureTrain = Train*T';  %(C*repetitions x 1)
end

   
%% commence classification testing
if ~exist('validate','var')
    warning('setting validate to true by default (no input received)')
    validate = true;
end
    
if validate          
    fprintf('Classifying ');       
          
    correct = NaN(1,nTrials);        
    for trial = 1:nTrials
        fprintf('.');

        % leave one out indices (for trial)        
        leaveOut = (trial-1)*trialLength+1 : trial*trialLength;           
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

        
        % classify our left out trial
        classPredicted = classify(FeatureValid,FeatureTrain,....
            trainValidGroup,'linear','empirical');               
        % count how many we got right              
        correct(trial) = mode(classPredicted) == validGroup(1);                
        correct(isnan(correct)) = []; %clearing NaNs if necessary
    end   
    percCorrect = mean(correct)*100;
    fprintf('\n\n ::: Classification accuracy: %i/%i = %3.2f%% :::\n\n',...
            sum(correct),nTrials,percCorrect);  
    displayFun(true)
else
    displayFun(false)
end

%% plotting channel weighting & feature space
function displayFun(print_accuracy)
    figSize = [ 10 50 1600 900];
    set(figure,'Position',figSize); 
    if print_accuracy
        suptitle([subname ' :: ' methodString ' :: ' ...
            data.runOrderLabels{condsInterest(1)} ' vs. ' ...
            data.runOrderLabels{condsInterest(2)} ...
            'CLASSIFICATION ACCURACY: ' num2str(percCorrect) '%']);
    else
        suptitle([subname ' :: ' methodString ' :: ' ...
            data.runOrderLabels{condsInterest(1)} ' vs. ' ...
            data.runOrderLabels{condsInterest(2)}]);
    end
    subplot(3,3,1:6)
    corttopo(T,data.hm)
    subplot(3,3,7:9)
    for class = 1:C   
        ph = plot(FeatureTrain(Group==class-1,1),...
            zeros(size(FeatureTrain(Group==class-1,1))),'o');      
        hold on
    end
    legend(data.runOrderLabels{condsInterest(1)},...
           data.runOrderLabels{condsInterest(2)});
end
end
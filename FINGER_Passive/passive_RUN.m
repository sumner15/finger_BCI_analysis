clc; clear; close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------- %
% Sensorimotor Rhythms During Preparation for Robot-Assisted Movement
subjects = {'TNC','TVT','WBL'};
chansInterest = 1:16;
% --------------------------------------------------------------------- %


%% processing options (prompting)
preProcessBool = input('Would you like to Concatenate & Pre-Process? Type y or n: ','s');
waveletBool = input('Would you like to process using wavelet? Type y or n: ','s');
idaBool = input('Would you like to run Discriminant analysis? Type y or n: ','s');
tic; successBool = true;

%% concatenate & pre-process data 
if preProcessBool == 'y'
    for currentSub = 1:length(subjects)       
        subname = subjects{currentSub};           

        disp('-------------------------------------');
        disp(['Pre-Processing data for ' subname]);
        disp('-------------------------------------');
        
        try 
            data = passive_preProcess(subname,true);                              
            %note: saves file (e.g. SLN_preProcessed.mat)            
        catch me
            disp(['Preprocessing failed: ' subname]);
            disp(me.message);
            successBool = false;
        end
        clear data
    end
end

%% time -> freq domain (wavelet)
if waveletBool == 'y'
    disp(['Channels of interest: ' num2str(chansInterest)]);
    for currentSub = 1:length(subjects)
        subname = subjects{currentSub};   
        

        disp('-------------------------------------');
        disp(['Beginning wavelet processing for ' subname]);
        disp('-------------------------------------');
        
        try
            freqData = passive_wavelet(subname,chansInterest,true);   
%             freqData = passive_segment(subname,true,freqData);            
            %note: saves file (e.g. ???)
%             passive_processSubject(username,subname,true,freqData); 
            %note: saves file (e.g. SLN_trialPower.mat)
        catch me 
            disp(['Wavelet Processing failed: ' subname]);
            disp(me.message);
            successBool = false;
        end
        clear freqData
    end
end

%% IDA analysis
if idaBool == 'y'
    for currentSub = 1:length(subjects)
        subname = subjects{currentSub};
        
        disp('-------------------------------------');
        disp(['Beginning IDA analysis for ' subname]);
        disp('-------------------------------------');
                
        try
            validate = true;
            prepOrMove = {'prep','move'};
            condsInterest = {[1 2],[1 3],[2 3]};
            for i = 1:2
                for j = 1:3
                    passive_IDA(subname, validate, prepOrMove{i}, condsInterest{j});
                end
            end
%             passive_IDA(subname,validate,prepOrMove,condsInterest)
        catch me
            disp(['Discriminant Analysis failed: ' subname]);
            disp(me.message);
            successBool = false;
        end
    end
end

%% finish up
timeElapsed = round(toc/60); 
disp(['Elapsed time: ' num2str(timeElapsed) ' min']);
try
    sendEmail(successBool);
catch me
    warning('e-mail failed: check authentication.')
end


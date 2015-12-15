clc; clear; close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------- %
% Sensorimotor Rhythms During Preparation for Robot-Assisted Movement
subjects = {'TNC','TVT','WBL'};
chansInterest = 1:16;
% --------------------------------------------------------------------- %


%% processing options (prompting)
preProcessBool = input('Would you like to Concatenate & Pre-Process? Type y or n: ','s');
cleanDataBool = input('Would you like to begin cleaning data? Type y or n: ','s');
waveletBool = input('Would you like to process using wavelet? Type y or n: ','s');
fftBool = input('Would you like to process using fft (topography)? Type y or n: ','s');
subPlotBool = input('Would you like to view ALL single-subject result plots? Type y or n: ','s');
plotBool = input('Would you like to view intersubject result plots? Type y or n: ','s');
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

%% cleaning data
if cleanDataBool == 'y'    
    for currentSub = 1:length(subjects)
        subname = subjects{currentSub};
        
        disp('-------------------------------------');
        disp(['Cleaning ' subname '''s data']);
        disp('-------------------------------------');
        
        try
            passive_screenData(subname)
            %note: overwrites file (e.g. SLN_preProcessed.mat)
        catch me
            disp(['Screening failed: ' subname]);
            disp(me.message);
            successBool = false;
        end        
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
            freqData = passive_wavelet(subname,chansInterest);   
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

%% time -> freq domain (fft)
if fftBool == 'y'    
    try        
        passive_fft;
    catch me 
        disp(['FFT Processing failed: ' subname]);
        disp(me.message);
        successBool = false; 
    end
end

%% subject plotting 
if subPlotBool == 'y'
   for currentSub = 1:length(subjects)
       subname = subjects{currentSub};
       try
        passive_plotSub(subname);
       catch me
           disp(['Subject Plotting failed: ' subname]);
           disp(me.message);
           successBool = false;
       end
   end
end

%% intersubject plotting
if plotBool == 'y'
    disp('Plotting inter-subject results');
    try
        passive_plot(subname);
    catch me 
        disp('Inter-Subject Plotting failed');
        disp(me.message);
        successBool = false;
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


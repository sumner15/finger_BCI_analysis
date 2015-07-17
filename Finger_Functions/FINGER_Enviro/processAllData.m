clc; clear; close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------- %
% Movement Anticipation and EEG: Implications for BCI-robot therapy
subjects = {'BECC','TRUS','DIMC','GUIR','LURI','NAVA',...
            'NAZM','TRAT','TRAV','POTA','DIAJ','TRAD'};                 
% --------------------------------------------------------------------- %
%  Emotiv study:
% subjects = {{'BECC'},{'POTA'},{'TRAT'},{'DIAJ'},{'NAVA'},{'TRAV'}};
% subjects = {{'POTA'},{'TRAT'},{'DIAJ'},{'NAVA'},{'TRAV'}};
% --------------------------------------------------------------------- %        
% define motor channels (used in wavelet) here! (in terms of 194Ch HM)
%                       bilateral HNL channels 
chansInterest = [59 51 52 43 44 165 175 164 174 163 66 60 53 131 140 148];
% --------------------------------------------------------------------- %


%% processing options (prompting)
if (~exist('username','var'))
   username = input('Username: ','s'); 
end
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
            data = concatEnviro(username,subname,false);                  
            preProcessEnviro(username,subname,true,data);                  
            %note: saves file (e.g. AAAA_concatData.mat)            
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
            screenDataEnviro(username,subname)
            %note: overwrites file (e.g. AAAA_concatData.mat)
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
            freqData = waveletEnviro(username,subname,chansInterest);   
            freqData = SegFingerEnviro(username,subname,true,freqData);
            %note: saves file (e.g. AAAA_segWavData.mat)
            intraSubject(username,subname,true,freqData); 
            %note: saves file (e.g. AAAA_trialPower.mat)
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
    warning('FFT scripting needs revising (see Hg revision on 7/6/2015)');
    try
        fftInterSubEnviro;
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
        plotSub(username,subname);
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
        plotSub(username,subname);
    catch me 
        disp('Inter-Subject Plotting failed');
        disp(me.message);
        successBool = false;
    end
end

%% finish up
timeElapsed = round(toc/60); 
disp(['Elapsed time: ' num2str(timeElapsed) ' min']);
sendEmail(successBool);


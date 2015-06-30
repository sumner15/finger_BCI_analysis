clc; clear concatData; 

% SUBJECTS EXCLUDED (02/23/2014) -------------------------------------- %
% EXCLUDED
% {'MILS'} (corn-rows)
% --------------------------------------------------------------------- %
subjects = {'AGUJ','ARRS','BROR','CHIB','CORJ','CROD','ESCH','FLOA',...
            'GONA','HAAN','JOHG','KILB','LAMK','LEUW','LOUW','MALJ',...
            'MCCL','MILS','NGUT','POOJ','PRIJ','RITJ','SARS','VANT',...
            'WHIL','WILJ','WRIJ','YAMK'};        
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
            data = concatTherapy(username,subname,false);                  
            data = preProcessTherapy(username,subname,true,data);  
            %note: saves file (e.g. AAAA_concatData.mat)            
        catch me
            disp(['Preprocessing failed: ' subname]);
            disp(me.message);
            successBool = false;
        end
        
    end
end

%% cleaning data
if cleanDataBool == 'y'    
    % note: check that data is pre-processed in cleaning script
    % make this check params and continue where you left off cleaning last.
    % need to re-write cleaning script
    for currentSub = 1:length(subjects)
        subname = subjects{currentSub};
        
        disp('-------------------------------------');
        disp(['Cleaning ' subname '''s data']);
        disp('-------------------------------------');
        
        try
            screenTherapy(username,subname)
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
            freqData = waveletTherapy(username,subname,chansInterest);   
            freqData = SegFingerTherapy(username,subname,true,freqData);
            %note: saves file (e.g. AAAA_segWavData.mat)
            intraSubjectTherapy(username,subname,freqData,true); 
            %note: saves file (e.g. AAAA_trialPower.mat)
        catch me 
            disp(['Wavelet Processing failed: ' subname]);
            disp(me.message);
            successBool = false;
        end
    end
end

%% time -> freq domain (fft)
if fftBool == 'y'
    error('not yet set up');
end

%% subject plotting (cell must be ran manually)
if false
   for currentSub = 1:length(subjects)
       subname = subjects{currentSub};
       plotSubTherapy(username,subname);
   end
end

%% intersubject plotting
if plotBool == 'y'
    disp('Plotting inter-subject results');
   plotInterSubTherapy 
end

%% finish up
timeElapsed = round(toc/60); 
disp(['Elapsed time: ' num2str(timeElapsed) ' min']);
sendEmail(successBool);

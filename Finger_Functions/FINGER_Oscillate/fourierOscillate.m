function data = fourierOscillate(data,saveBool,username,subname)

disp('--- computing POWER ---');

%% info regarding the experimental setup
nExams = length(data.segEEG);        % number of recordings
sr = data.sr;                        % sampling rate
nChans = size(data.segEEG{1},2);     % number of active channels

%% Find Fourier coeff & power across frequency bands for each trial
for exam = 1:nExams
   fprintf('Exam Number %i / %i \n',examNo,nExams);  
   % initializing power arrays: {exam}(trial,chan,fcoeffs,epochs)
   data.power{exam}      = zeros(data.nTrials,nChans,sr/2,data.trialLength);
   data.breakPower{exam} = zeros(data.nTrials,nChans,sr/2,data.breakLength);
   
   for trial = 1:data.nTrials 
       fprintf('- %2i ',trialNo);
       for chan = 1:nChans
           
           % fourier coefficient vector for exam/trial/channel
           % fCoeffs (frequencies, epochs in a trial)
           fCoeffs = zeros(sr,data.trialLength); 
           for second = 1:data.trialLength
                % fourier coefficient vector summed each second 
                timeSpan = ((second-1)*data.sr+1):(second*data.sr); %1-sec in trial
                fCoeffs(:,second) = fft(squeeze(data.segEEG{exam}(trial,chan,timeSpan)));
           end           
           
           % computing fcoeff vector for breaks (resting data)
           % fCoeffs (frequencies, epochs in a trial)
           fCoeffsBreak = zeros(sr,data.breakLength);
           for second = 1:data.breakLength
               % fourier coefficient vector summed each second
               timeSpan = ((second-1)*data.sr+1):(second*data.sr); %1-sec in trial
               fCoeffsBreak(:,second) = fft(squeeze(data.segEEGBreak{exam}(trial,chan,timeSpan)));
           end           
           
           % cutting off negative freq components, computing power, and
           % filling power and break power arrays with data
           fCoeffs      =      fCoeffs(1:sr/2,:);
           fCoeffsBreak = fCoeffsBreak(1:sr/2,:);      
           for freq = 1:sr/2
            data.power{exam}(trial,chan,freq,:)      = abs(fCoeffs(freq,:));
            data.breakPower{exam}(trial,chan,freq,:) = abs(fCoeffsBreak(freq,:));
           end % freq
       end % channel
   end % trial
   fprintf('\n');
end % exam
data.params.fourier = true;

%% if you want to average over exams, enable this area
meanPower = data.power{1};
meanBreak = data.breakPower{1};
for exam = 2:nExams
    meanPower = meanPower + data.power{exam};
    meanBreak = meanBreak + data.breakPower{exam};
end
meanPower = meanPower./nExams;
meanBreak = meanBreak./nExams;

clear data.power data.breakPower
data.power = cell(1,1);
data.breakPower = cell(1,1);
data.power{1} = meanPower;
data.breakPower{1} = meanBreak;

%% saving data if requested
if saveBool
    clear data.eeg data.vid data.artifact
    powerData = data; clear data
    fprintf('Saving power data...');
    setPathOscillate(username,subname);
    save(strcat(subname,'_powerData'),'powerData','-v7.3');
    fprintf('Done.\n');
    data = powerData; clear powerData
else
    disp('warning: data not saved, must pass directly');
end
        
    

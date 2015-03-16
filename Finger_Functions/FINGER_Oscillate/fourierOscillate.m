function subData = fourierOscillate(subData)

%% info regarding the experimental setup
nExams = length(subData.segEEG);        % number of recordings
sr = subData.sr;                        % sampling rate
nChans = size(subData.segEEG{1},2);     % number of active channels

%% Find Fourier coeff & power across frequency bands for each trial
for exam = 1:nExams
   % initializing power arrays: {exam}(trial,chan,fcoeffs,epochs)
   subData.power{exam}      = zeros(subData.nTrials,nChans,sr/2,subData.trialLength);
   subData.breakPower{exam} = zeros(subData.nTrials,nChans,sr/2,subData.breakLength);
   
   for trial = 1:subData.nTrials 
       for chan = 1:nChans
           
           % fourier coefficient vector for exam/trial/channel
           % fCoeffs (frequencies, epochs in a trial)
           fCoeffs = zeros(sr,subData.trialLength); 
           for second = 1:subData.trialLength
                % fourier coefficient vector summed each second 
                timeSpan = ((second-1)*subData.sr+1):(second*subData.sr); %1-sec in trial
                fCoeffs(:,second) = fft(squeeze(subData.segEEG{exam}(trial,chan,timeSpan)));
           end           
           
           % computing fcoeff vector for breaks (resting data)
           % fCoeffs (frequencies, epochs in a trial)
           fCoeffsBreak = zeros(sr,subData.breakLength);
           for second = 1:subData.breakLength
               % fourier coefficient vector summed each second
               timeSpan = ((second-1)*subData.sr+1):(second*subData.sr); %1-sec in trial
               fCoeffsBreak(:,second) = fft(squeeze(subData.segEEGBreak{exam}(trial,chan,timeSpan)));
           end           
           
           % cutting off negative freq components, computing power, and
           % filling power and break power arrays with data
           fCoeffs      =      fCoeffs(1:sr/2,:);
           fCoeffsBreak = fCoeffsBreak(1:sr/2,:);      
           for freq = 1:sr/2
            subData.power{exam}(trial,chan,freq,:)      = abs(fCoeffs(freq,:));
            subData.breakPower{exam}(trial,chan,freq,:) = abs(fCoeffsBreak(freq,:));
           end % freq
       end % channel
   end % trial
end % exam

%% if you want to average over exams, enable this area
meanPower = subData.power{1};
meanBreak = subData.breakPower{1};
for exam = 2:nExams
    meanPower = meanPower + subData.power{exam};
    meanBreak = meanBreak + subData.breakPower{exam};
end
meanPower = meanPower./nExams;
meanBreak = meanBreak./nExams;

clear subData.power subData.breakPower
subData.power = cell(1,1);
subData.breakPower = cell(1,1);
subData.power{1} = meanPower;
subData.breakPower{1} = meanBreak;
        
    

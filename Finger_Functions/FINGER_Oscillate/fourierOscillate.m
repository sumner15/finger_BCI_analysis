function subData = fourierOscillate(subData)

%% info regarding the experimental setup
nExams = length(subData.segEEG);        % number of recordings
sr = subData.sr;                        % sampling rate
nChans = size(subData.segEEG{1},2);     % number of active channels

%% Find Fourier coeff & power across frequency bands for each trial
subData.power = cell(size(subData.segEEG));
for exam = 1:nExams
   % initializing power array {exam}(trial,chan,fcoeffs)
   subData.power{exam} = zeros(subData.nTrials,nChans,sr/2);
   for trial = 1:subData.nTrials 
       for chan = 1:nChans
           % fourier coefficient vector for exam/trial/channel
           fCoeffs = zeros(256,1); 
           for second = 1:subData.trialLength
                % fourier coefficient vector summed each second 
                timeSpan = ((second-1)*subData.sr+1):(second*subData.sr);
                fCoeffs = fCoeffs+fft(squeeze(subData.segEEG{exam}(trial,chan,timeSpan)));
           end
           % computing power, and cutting off negative freq components
           fCoeffs = fCoeffs./subData.trialLength;
           subData.power{exam}(trial,chan,:) = abs(fCoeffs(1:(end/2)));
       end
   end
end


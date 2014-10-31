function topography(username,subname)
% options
N = 200;                        % Sample length 
fs = 1000;                      % sampling frequency (Hz)
fVec = linspace(0,fs/2,N/2+1);  % frequency vector resolved by fft
nWins = floor(fs*3/N);          % number of windows per epoch (3 sec)

freq = 11;      % Hz (desired center freq used for topography)
[c freqInd] = min(abs(fVec-freq)); % freq converted to an index
freqUsed = fVec(freqInd); % Finds closest freq in resolved freq vector

condition = 3;  % note that this is using the motor only condition

%% loading in the data and head model
setPathEnviro(username,subname)
load(strcat(subname,'_concatData.mat'))
data = concatData.eeg{condition}(1:256,:);  

load egihc256hm; hm = EGIHC256;

%% computing FFT
% data = samples x channels
nSamples = size(data,2); nChans = size(data,1); % common vars
fdata = NaN(nChans,floor(nSamples/N));          %preparing data structure

for window = 1:floor(nSamples/N)   % moving along in 100ms windows   
   sampleWin = (window-1)*N+1:window*N;         % preparing sample window
   feeg = fft(data(:,sampleWin)')';             % taking fft of data
   feeg = squeeze(mean(abs(feeg(:,freqInd)),2));% computing power in f band
   fdata(:,window) = feeg';                     % filling in data structure
   % fdata = channels x 100msWindowNumber 
end


%% segmenting data
cd .. ; 
load('note_timing_Blackbird') %creates var Blackbird   <nNotes x 1 double>
clear data note_timing_Blackbird sunshineDay
cd(subname);

 %start index of time sample marking beginning of trial (from labjack)
 startInd = min(find(abs(concatData.vid{condition})>2000));
 %markerInds is an integer vector of marker indices (rounded to 100ms)
 markerInds = round((startInd+round(blackBird))/N);

 for trial = 1:length(markerInds)
    if trial==1; sumTrials=zeros(nChans,nWins); end;    
    trialData = fdata(:,markerInds(trial)-floor(nWins/2):markerInds(trial)+floor(nWins/2));
    sumTrials = sumTrials+trialData;
 end
 % trialPower = channels x 100msTrialWindowNumber(31 total)
 trialPower = sumTrials./length(markerInds);
 
 
%% plotting data
scrsz = get(0,'ScreenSize'); scrsz = [1 1 1000 800];
set(figure,'Position',scrsz)
for i = 1:nWins
    subplot(3,5,i);
    corttopo(trialPower(:,i),hm,'drawelectrodes');    
    title(['trialTime = ' num2str(i*N/fs) ' sec']);
    set(gca,'clim',[-200 200]) 
    
    if i==1; pause(1); end;
    pause(0.010);
end

function topography(username,subname)
% options
freq = 8:13;    % Hz (This band will be averaged)
condition = 2;  % note that this is using the motor only condition

%% loading in the data and head model
setPathEnviro(username,subname)
load(strcat(subname,'_concatData.mat'))
data = concatData.eeg{condition}(1:256,:);  

load egihc256hm; hm = EGIHC256;

%% computing FFT
% data = samples x channels
nSamples = size(data,2); nChans = size(data,1); % common vars
fdata = NaN(nChans,floor(nSamples/100));         %preparing data structure

for window = 1:floor(nSamples/100)   % moving along in 100ms windows   
   sampleWin = (window-1)*100+1:window*100;     % preparing sample window
   feeg = fft(data(:,sampleWin));               % taking fft of data
   feeg = squeeze(mean(abs(feeg(:,freq)),2));   % computing power in f band
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
 markerInds = round((startInd+round(blackBird))/100);

 for trial = 1:length(markerInds)
    if trial==1; sumTrials=zeros(nChans,31); end;
    trialData = fdata(:,markerInds(trial)-15:markerInds(trial)+15);
    sumTrials = sumTrials+trialData;
 end
 % trialPower = channels x 100msTrialWindowNumber(31 total)
 trialPower = sumTrials./length(markerInds);
 
 
%% plotting data
trialPower(1,:) = trialPower(2,:);
for i = 1:31
    corttopo(trialPower(:,i),hm);    
    title(['trialTime = ' num2str(i/10) ' sec']);
    if i==1; pause(5); end;
    pause(0.001);
end

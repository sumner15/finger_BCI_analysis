subjects = {{'BECC'},{'NAVA'},{'TRAT'},{'POTA'},{'TRAV'},{'NAZM'},...
            {'TRAD'},{'DIAJ'},{'GUIR'},{'DIMC'},{'LURI'},{'TRUS'}};
subjects = {{'NAZM'}};        
nSubs = length(subjects);
for subNum = 1:nSubs
% function filterRawData(username,subname)
username = 'LAB';
subname = subjects{subNum};   
subname = subname{1};   

cond = 3; % condition/song number 

% Creating test sine waves at varying frequencies for filter implementation
% freq1 = 60; freq2 = 13;
% t = .001:.001:1;
% signal = sin(freq1*2*pi*t)+sin(freq2*2*pi*t);
% idealSig = sin(freq2*2*pi*t);

% Lowpass filter to exclude 60 Hz noise
% Since Nyquist is 500Hz, 50 Hz is .1 times the Nyquist freq (our cutoff)
n = 331;            % filter order
f = [0 .01 .02 .09 .11 1];  % frequency (as divisor of Nyquest freq, i.e. 0=0 & 1=Nyquist f)
a = [0  0   1  1   0  0];  % 
b = firls(n,f,a);

% Computing filtered result 
%resultSig = filtfilt(b,a,signal);

% Calculate frequency response of filter
[h,w] = freqz(b,1,n,2);
% Plot filter kernel + frequency response of actual and ideal filter
% figure; subplot(1,2,1); plot(b); title('Filter kernel')
% subplot(1,2,2); plot(w,abs(h))
% hold on; plot(f,a,'r.-'); title('Frequency response of filter')
% legend('Actual', 'Ideal')

%% Plotting test signal, ideal result, and actual result
% figure; 
% subplot(3,1,1); plot(t,signal,'k'); axis([0 1 -1.5 1.5])
% xlabel('time (sec)'); title('Sample signal');
% subplot(3,1,2); plot(t,idealSig,'b'); axis([0 1 -1.5 1.5])
% xlabel('time (sec)'); title('Ideal resulting signal');
% subplot(3,1,3); plot(t,resultSig,'r'); axis([0 1 -1.5 1.5])
% xlabel('time (sec)'); title('filtered Signal');

%% loading in the data 
setPathEnviro(username,subname)
load(strcat(subname,'_concatData.mat'))
data = concatData.eeg{cond}(1:256,:);

%% Using filter on raw SMC EEG data
motorData = concatData.motorEEG{cond}(:,:); % R-SMC hemisphere
t = 0:1/concatData.sr:size(motorData,2)/concatData.sr;
filteredMotorEEG = NaN(size(motorData));
for channel = 1:size(motorData,1)   
   currentSig = motorData(channel,:);
   filteredMotorEEG(channel,:) = filtfilt(b,a,currentSig) - 8*channel;   
end

% %% Using filter on raw frontal electrodes
% frontalChans = [46 38 37 33 32 26 25 19 18 11 10];
% frontalData = concatData.eeg{cond}(frontalChans,:);
% filteredFrontEEG = NaN(size(frontalData));
% for channel = 1:size(frontalData,1)   
%    currentSig = frontalData(channel,:);
%    filteredFrontEEG(channel,:) = filtfilt(b,a,currentSig) - 8*channel;   
% end

%% creating spike train of markers
cd .. ; 
load('note_timing_Blackbird') %creates var Blackbird   <nNotes x 1 double>
clear data note_timing_Blackbird sunshineDay
cd(subname);

%start index of time sample marking beginning of trial (from labjack)
startInd = min(find(abs(concatData.vid{cond})>2000));
%markerInds is an integer vector of marker indices (rounded to 100ms)
markerInds = round((startInd+round(blackBird)));
spikeTrain = zeros(1,size(filteredMotorEEG,2));
spikeTrain(markerInds) = 5; 
 
%% plotting results
%figure; plot(motorData'); title('Raw Motor Data')

%window = 15000:45000;
window = 10000:80000;

figure; hold on; title(strcat(subname,': Filtered (Low-Pass 60 Hz) MOTOR Data'))
plot(filteredMotorEEG(:,window)','k'); plot(spikeTrain(window));

% figure; hold on; title('Filtered (Low-Pass 60 Hz) FRONTAL Data')
% plot(filteredFrontEEG(:,window)','k'); plot(spikeTrain(window));

end


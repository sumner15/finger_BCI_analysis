%% loading data and setting data capture variables 
close all; clear;
data = load('Camilo_01.mat');   % loads a sample set of data
data = data.data;           
Fs= 128;                        % sampling Frequency
tElapsed= 1/Fs;                 % time elapsed per sample 
N = length(data);               % number of samples 
t = (0:N-1)*tElapsed;           % time vector (in sec)
fVec = linspace(0,Fs/2,N/2+1);  % frequency vector resolved by fft

%% test signal (for debugging only)
% f1 = 60; f2 = 30; f3 = 15;      %sample sine wav freqs
% data = sin(2*pi*t*f1)+sin(2*pi*t*f2)+sin(2*pi*t*f3);
% data = data';                   %transposing to original convention

%% creating and implementing low pass filter to exclude 60 Hz noise
n = 200;             % filter order
% f = [0   .02 .06 .76 .80  1];  % frequency (as fraction of Nyquist freq, i.e. 1=Nyquist f)
% a = [.1   0   1   1   0  0]; % band pass filter (5-50Hz)
f = [0 .76 .80  1]; % frequency (as fraction of Nyquist freq, i.e. 1=Nyquist f)
a = [1   1   0  0]; % low pass filter (50 Hz)
b = firls(n,f,a);   % creating filter

% Computing filtered result 
dataFilt = NaN(size(data));
for channel = 1:size(data,2)
    dataFilt(:,channel) = filtfilt(b,a,data(:,channel));
end    

%% plotting frequency response of the filter (if wanted)
[h,w] = freqz(b,1,n,2);
% Plot filter kernel + frequency response of actual and ideal filter
figure; subplot(1,2,1); plot(b); title('Filter kernel')
subplot(1,2,2); plot(w,abs(h))
hold on; plot(f,a,'r.-'); title('Frequency response of filter')
legend('Actual', 'Ideal')

%% computing signal mean over relevant data channels 
sigMean = squeeze(mean(data,2));        % averaging over channels        
sigMean = detrend(sigMean,'linear');    % detrending (dc offset/drift)
sigMeanFilt = squeeze(mean(dataFilt,2));
sigMeanFilt = detrend(sigMeanFilt,'linear');

%% taking fft of filtered and non-filtered signals for spectral analysis
% NFFT = nextPow2(N);
% fftMean= fft(signal,NFFT)/N;

fftMean = abs(fft(sigMean));
fftMean = fftMean(1:length(fVec),:);
fftMeanFilt = abs(fft(sigMeanFilt));
fftMeanFilt = fftMeanFilt(1:length(fVec),1);

%% Plotting test signal and filtered results
figure; 
inds = 5000:(5000+Fs*30);    %data indices for time selection
subplot(211); plot(t(inds),data(inds,:));     title('Raw Data');
subplot(212); plot(t(inds),dataFilt(inds,:)); title('Low Pass'); 

%% Plotting power spectrum
figure;
subplot(211); plot(fVec,fftMean);     title('Raw power spectrum');
subplot(212); plot(fVec,fftMeanFilt); title('Filtered spectrum');



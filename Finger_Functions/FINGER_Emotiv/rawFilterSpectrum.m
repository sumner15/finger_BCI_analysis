%% loading data and setting data capture variables 
close all; clear;
data = load('camilo_rest_data_2.mat');   % loads a sample set of data
data = data.temp;           

Fs= 128;                            % sampling Frequency
epochLength = 0.5;                  % length of epochs wanted (sec)

tElapsed= 1/Fs;                     % time elapsed per sample 
N = length(data);                   % number of samples 
t = (0:N-1)*tElapsed;               % time vector (in sec)

epochN = floor(epochLength*Fs);     % number of samples in an epoch
nWins = floor(N/Fs);                % number of windows in data set
fVec = linspace(0,Fs/2,epochN/2+1); % frequency vector resolved by fft

nChans = size(data,2);              % number of channels in data set

%% test signal (for debugging only)
% f1 = 60; f2 = 30; f3 = 15;      %sample sine wav freqs
% data = sin(2*pi*t*f1)+sin(2*pi*t*f2)+sin(2*pi*t*f3);
% data = data';                   %transposing to original convention

%% creating and implementing low pass filter to exclude 60 Hz noise
n = 200;             % filter order
% f = [0   .02 .06 .76 .80  1];  % frequency (as fraction of Nyquist freq, i.e. 1=Nyquist f)
% a = [0    0   1   1   0   0]; % band pass filter (5-50Hz)
f = [0 .76 .80  1]; % frequency (as fraction of Nyquist freq, i.e. 1=Nyquist f)
a = [1   1   0  0]; % low pass filter (50 Hz)
b = firls(n,f,a);   % creating filter

% Computing filtered result 
dataFilt = NaN(size(data));
for channel = 1:size(data,2)
    dataFilt(:,channel) = filtfilt(b,a,data(:,channel));
end    
clear channel

%% plotting frequency response of the filter (if wanted)
% [h,w] = freqz(b,1,n,2);
% % Plot filter kernel + frequency response of actual and ideal filter
% figure; subplot(1,2,1); plot(b); title('Filter kernel')
% subplot(1,2,2); plot(w,abs(h))
% hold on; plot(f,a,'r.-'); title('Frequency response of filter')
% legend('Actual', 'Ideal')

%% Segmenting epochs

segDataFilt = NaN(nWins, epochN, nChans);   %initializing segmented data size
for epoch = 1:nWins
    inds = (epoch-1)*epochN+1:epoch*epochN;
    segDataFilt(epoch,:,:) = dataFilt(inds,:);
end
clear inds epoch 

%% taking fft of data
bucketN = epochN;   %number of f-buckets = number of samples per epoch
fftSegDataFilt = NaN(bucketN, nWins, nChans); % initializing
% fft coeffs   =  f-bucket, epoch number , channel number
for channel = 1:nChans
    for epoch = 1:nWins
        % detrending the data within each and every epoch
        segDataFilt(epoch,:,channel) = detrend(segDataFilt(epoch,:,channel));
        % taking the fft of each epoch
        fftSegDataFilt(:,epoch,channel) = fft(segDataFilt(epoch,:,channel));
    end
end
fftSegDataFilt = abs(fftSegDataFilt);       %taking magnitude of complex (power)

meanFFT = squeeze(mean(fftSegDataFilt,2));  %taking mean across all epochs
meanFFT = squeeze(mean(meanFFT,2));         %taking mean across all chans
meanFFT = meanFFT(1:epochN/2+1);            %eliminating coeffs for neg. freqs


%% Plotting power spectrum
figure;
plot(fVec,meanFFT);     
title('Power Spectrum'); xlabel('Hz'); ylabel('Power'); 



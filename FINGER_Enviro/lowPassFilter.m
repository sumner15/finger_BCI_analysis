function filteredEEG = lowPassFilter(data, fCut, sr)

% this function takes in time series data (chan x time-sample) as a 2D
% array. It then uses the matlab filtfilt function to filter that data
% using a low pass approach. The cutoff freq is passed in Hz. Sampling rate
% is in Hz

%% Creating the filter TF
nyq = floor(sr/2);
n = floor(sr/3)-1;   % filter order
fLo =(fCut - 5)/nyq; % low cutoff in terms of nyquist
fHi = ( fCut+5)/nyq; % high cutoff in terms of nyquist
f = [0 fLo fHi 1];   % frequency (e.g. 0=0 & 1=Nyquist f)
a = [1  1   0  0];   % 
b = firls(n,f,a);

%% Calculate frequency response of filter & plot 
% [h,w] = freqz(b,1,n,2);
% % Plot filter kernel + frequency response of actual and ideal filter
% figure; subplot(1,2,1); plot(b); title('Filter kernel')
% subplot(1,2,2); plot(w,abs(h))
% hold on; plot(f,a,'r.-'); title('Frequency response of filter')
% legend('Actual', 'Ideal')

%% Using filter on raw EEG data
filteredEEG = NaN(size(data));
for channel = 1:size(data,1)      
   filteredEEG(channel,:) = filtfilt(b,a,data(channel,:));   
end
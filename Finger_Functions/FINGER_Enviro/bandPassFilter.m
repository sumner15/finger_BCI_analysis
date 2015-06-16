function filteredOut = bandPassFilter(data, fCut, sr)

% this function takes in time series data (chan x time-sample) as a 2D
% array. It then uses the matlab filtfilt function to filter that data
% using a band pass approach. The high cutoff freq is passed in Hz. 
% The low cutoff freq is hard set to 4 Hz.
% 
% inputs: data (chan x samp)
%         fCut, cutoff frequency (in Hz)
%         sr, sampling rate (in Hz)

%% Creating the filter TF
nyq = floor(sr/2);
n = floor(sr/3)-1;   % filter order
fLo =(fCut - 2)/nyq; % low cutoff in terms of nyquist
fHi =(fCut + 2)/nyq; % high cutoff in terms of nyquist
f = [0 fLo fHi 1];   % frequency (e.g. 0=0 & 1=Nyquist f)
a = [1 1   0   0];   % low pass
b = firls(n,f,a);

%% Calculate frequency response of low-pass filter & plot 
% [h,w] = freqz(b,1,n,2);
% % Plot filter kernel + frequency response of actual and ideal filter
% figure; subplot(1,2,1); plot(b); title('Filter kernel')
% subplot(1,2,2); plot(w,abs(h))
% hold on; plot(f,a,'r.-'); title('Frequency response of filter')
% legend('Actual', 'Ideal')

%% Using filter on raw data
filteredOut = NaN(size(data));
for channel = 1:size(data,1)      
   channelData = squeeze(double(data(channel,:)));
   filteredOut(channel,:) = filtfilt(b,a,channelData);   
end

%% creating low pass filter @ 4 Hz.
lowPassCut = 4;             % Hz
fLo =(lowPassCut - 2)/nyq;  % low cutoff in terms of nyquist
fHi =(lowPassCut + 2)/nyq;  % high cutoff in terms of nyquist
f = [0 fLo fHi 1];          % frequency (e.g. 0=0 & 1=Nyquist f)
a = [1 1   0   0];          % low pass
b = firls(n,f,a);

lowCut = NaN(size(data));
for channel = 1:size(data,1)      
   channelData = squeeze(double(data(channel,:)));
   lowCut(channel,:) = filtfilt(b,a,channelData);   
end

%% subtracting low-cut data from high-cut data
filteredOut = filteredOut-lowCut;
filteredOut = filteredOut*4;        % scaling correction 
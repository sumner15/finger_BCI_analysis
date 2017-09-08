function [ time, signal ] = createEEG( sampFreq, length )
% createEEG will create a simulated EEG signal with 1/f power spectrum, of
% length input:length. The amplitude and phase of the basic waves are
% randomized. 
%
%   outputs: time is a vector size 1xlength. signal is a vector size
%   1xlength.
%
%   inputs: sampFreq is an int; desired sampling frequency of the EEG data.
%   length is an int; the desired length of the resulting vector. 

time = linspace(0,length/sampFreq,length);  % time vector (in seconds)

% creating a signal of gaussian noise 
noise = randn(1,length);
noiseFFT = fft(noise);

% defining a frequency vector
f = linspace(1,sampFreq/2,ceil(length/2));

% multiplying first half of fft noise by 1/f
coeff = noiseFFT(1:ceil(length/2)).*1./f;
newCoeff = [coeff(1:floor(length/2)) fliplr(coeff)];

% result via inverse FFT
signal = real(ifft(newCoeff));


end


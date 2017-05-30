% this script will "visualize" EEG data aurally. How cool is that? But for
% now, it has a couple problems. I'm not 100% sure about the magnitude
% scaling. Squaring the frequency term in essence adds an exponential
% magnitude trend to the t-f data where high frequencies are further
% magnified. This "sounds" better, but may be technically incorrect. I am
% using decibel results for now, but this adds a level of complication.
% Note that negative dB values will also cause an increase in volume,
% meaning the result is unsigned. ERD/ERS both increase volume. It may be a
% better visualization to switch the effects of volume and frequency. For
% example, an ERS would cause a jump in frequency rather than volume. This
% may be more intuitive. Think about it -Sumner 10/24/14
clear 
username = 'Sumner'; subname = 'DIAJ';
%% loading data
setPathEnviro(username,subname)
filename = celldir([subname '*trialPower.mat']);
filename{1} = filename{1}(1:end-4);
disp(['Listen to the brain of ' filename{1} '... '])
load(filename{1});
%% global vars
song = 2;       % song selection (1-6)
Fs = 1000;      % sampling rate (Hz) EEG
audioFs = 48000;% sampling rate (Hz) audio (48kHz for now) -- must be multiple of Fs
res = 5;       % resolution (Hz) -- must be even (for now)
scale = 10;     % frequency upscale factor

%% computation
for song = 1:6
fftSignals = squeeze(trialPowerDB{song}(:,1,:));    % selecting t-f information
epochLength = size(fftSignals,2)/Fs;                % sec
nSamples = epochLength*audioFs;                     % number of samples

totalSig = zeros(1,nSamples);
for fftBucket = 1:res:(size(fftSignals,1)-res)
   f =(fftBucket+4)^2*scale;    % transformation fftBucket->actual f ...
                                % then scaled to human hearing level 
   % creating a basic sine wave at the audio sampling frequency
   tAudio = linspace(0,epochLength,epochLength*audioFs); %time vector
   currentSig = sin(2*pi*f*tAudio);
   % dotting the sine wave with the magnitude from the brain
   ind = fftBucket:(fftBucket+res-1);                   % indices to average across   
   fftMag = mean(fftSignals(ind,:),1);                  % fft coeff magnitude
   currentSig = currentSig.*interp(fftMag,audioFs/Fs);  % taking dot product
   % totaling the differenet frequency signals 
   totalSig = totalSig+currentSig;
   %clear f tAudio currentSig ind fftMag
end 
% scaling the total signal to 1 for proper volume
totalSig = totalSig./max(totalSig);

%% play sound
totalSig = interp(totalSig,2);  % lengthens signal, but cuts freq by half
clf; plot(totalSig);
sound(totalSig,audioFs);
wavwrite(totalSig, audioFs, 8, strcat(subname,'_0',num2str(song)));  
end

% This function analyzes the results of the FINGER therapy study. 
%
% The function pulls the final cleaned EEG data as a structure from the
% subjects' processed file (e.g. 'C:\Users...\FINGER-EEG
% study\Processed\LASF\Exam 1\LASF_finalclean#.mat') in your local
% directory (please download from the Cramer's lab servers). 
%
% Note that the calculation of ERD in this script uses the variance of the
% Fourier coefficients. Thus it is calculating the magnitude of the FC
% relative to the mean over the window. This may need changing in the
% future to a manual calculation that uses a pre-trial baseline (resting
% state data) or preceding trial as a reference/mean. 
%
% input: username and subname as strings (e.g. subname = 'LASF')

function therapyAnalysis(username, subname)
% Finger_EEG_analysis(subname)
% Input: subject name (as string)

% Set the environment
environment('egi256');                                     

%% Load in subject .mat data file 
switch username
    case 'Sumner'
        if ispc==1
            cd('C:\Users\Sumner\Desktop\FINGER-EEG study\Processed')             
        else
            cd('/Users/sum/Desktop/Finger-EEG study/Processed');
        end
    case 'Omar'
        cd('C:\Users\Omar\Desktop\FINGER-EEG study\Processed')  
    case 'Camilo'
        cd('C:\Users\Camilo\Desktop\FINGER-EEG study\Processed') 
    case 'Thuong'
        cd('C:\Users\Thuong\Documents\SPRING 2014\Research\Therapy_Study_Data\Processed');
end

if ispc==1
    cd(strcat(subname,'\Exam 1\'))    
else
    cd(strcat(subname,'/Exam 1/'))    
end

% Load the cleaned data
disp('Loading cleaned data...');
finalclean{1} = load(strcat(subname,'_finalclean1.mat'));
finalclean{2} = load(strcat(subname,'_finalclean2.mat'));
cd ..

if ispc==1, cd 'Exam 2'; 
else cd 'Exam 2'; end

finalclean{3} = load(strcat(subname,'_finalclean1.mat'));
finalclean{4} = load(strcat(subname,'_finalclean2.mat'));
disp('done.');


%% %%%%%%%%%%%%%%%%%
%%% EEG ANALYSIS %%%
%%%%%%%%%%%%%%%%%%%%

%% separate results by condition
spectra{1}.cond = 'Exam 1: Sunshine';
spectra{2}.cond = 'Exam 1: Speed test';
spectra{3}.cond = 'Exam 2: Sunshine';
spectra{4}.cond = 'Exam 2: Speed test';

%% pick windowing for analysis
windowSize = 250;   % in # of samples
% for each song
for i = 1:4
    % number of samples for a given song = #trials x #samples per trial
    numSamples(i) = size(finalclean{i}.data,3)*size(finalclean{i}.data,1);
    % start time for each window across all epochs
    startTimes{i} = 1:windowSize:numSamples(i); 
end

%% pick max frequency to save
maxFreq = 50;                       % Maximum freq. to evaluate (Hz)
df = finalclean{1}.sr/windowSize;   % frequency/spectral resolution 
maxbin = ceil(maxFreq/df)+1;        % number of bins
freqs = (0:(maxbin-1))*df;          % frequency bins

%% %Identify goodchan and goodepoch
for i = 1:4
    sumbadchan{i} = sum(finalclean{i}.artifact,2);
    goodchan{i} = find(sumbadchan{i} < 30);
    sumbadepoch{i} = sum(finalclean{i}.artifact,1);
    goodepoch{i} = find(sumbadepoch{i} < 30);
end

%% taking the FFT of the data
%this cell will produce fourier coefficients in a cell array as follows:

%fcoefeeg{song,trial,window} = freqbin x channel
% e.g.     4     43    12         14        194

disp('FFTing the data...');

for song = 1:4
    % Fast Fourier Transform
    nTrialSamples = size(finalclean{song}.data,1); %number of samples/trial
    for windowNum = 1:nTrialSamples/windowSize     %for each window number  
        for trial = 1:size(finalclean{song}.data,3)%for each trial
            % current window   
            win = (windowNum-1)*windowSize+(1:1:windowSize);
            % taking the fft...
            % fcoeffeeg{song,trial,window} = freqbin x channel
            fcoefeeg{song,trial,windowNum} = ...
                fft(ndetrend(finalclean{song}.data(win,:,trial)),[],1);
            % limit to max frequency
            fcoefeeg{song,trial,windowNum} = ...
                fcoefeeg{song,trial,windowNum}(1:maxbin,:);
            % reorganizing to...
            % fcoefeeg_chunks{song} = freqbin x channel x trial x windowNum
            fcoefeeg_chunks{song}(:,:,trial,windowNum) = ...
                fcoefeeg{song,trial,windowNum};
        end
    end    
end


%% Computing EEG power
for condnum = 1:length(spectra)    
    %EEG Power as magnitude of fourier coefficients for each window
    
    % {song}.eegpower_chunks = freqbin x channel x trial x windowNum
    spectra{condnum}.eegpower_chunks = abs(fcoefeeg_chunks{condnum});
    % {song}.eegpower_trials = freqbin x channel x windowNum
    % power across all trials
    spectra{condnum}.eegpower_trials = squeeze(mean(spectra{condnum}.eegpower_chunks,3));
    
end

%% Organizing some remaining data to save out
for song = 1:length(spectra)
    %Organize the structure
    spectra{song}.freqs = ((1:maxbin)-1)*finalclean{i}.sr/windowSize;
    spectra{song}.startTimes = startTimes{condnum};
    spectra{song}.midtime = startTimes{i}+windowSize/2;
    spectra{song}.goodchan = goodchan{i};
    spectra{song}.windowSize = windowSize;
    spectra{song}.subname = subname;
    spectra{song}.hm = finalclean{song}.hm;

end;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% saving data
cd ..; disp(strcat('Saving to: ',pwd));
savestring = strcat(subname,'_spectanalysis.mat');
save(savestring,'spectra');
disp('Finished! =D');

end

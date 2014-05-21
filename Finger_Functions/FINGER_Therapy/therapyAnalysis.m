% This function is currently functioning for power analysis (ERD) from the
% pilot study for the FINGER environmental effects on ERD study. It now
% needs modification to examine power changes (ERD) in the FINGER therapy
% study paradigm. Good luck! -Sumner 03/13/14
%
% input: username and subname as strings (e.g. subname = 'LASF')

function therapyAnalysis(username, subname)
% Finger_EEG_analysis(subname)
% Input: subject name (as string)

% Set the environment
environment('egi256');                                              %CHECK THIS!!

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
%%% EEG ANALYSES %%%
%%%%%%%%%%%%%%%%%%%%

%pick windowing for analysis
windowSize = 250;   % samples
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
disp('FFTing the data...');

for windowNum = 1:length(startTimes)    % for each window number    
    % Fast Fourier Transform
    for song = 1:4
        % current window   
        win = startTimes{i}(windowNum):(startTimes{i}(windowNum)+windowSize-1);
        % taking the fft
        fcoefeeg{song,windowNum} = fft(ndetrend(finalclean{i}.data(win,:,:),[],1));
        % limit to max frequency
        fcoefeeg{song,windowNum} = fcoefeeg{song,windowNum}(1:maxbin,:,:);
    end    
end
clear win 

%% separate results by condition
spectra{1}.cond = 'Exam 1: Sunshine';
spectra{2}.cond = 'Exam 1: Speed test';
spectra{3}.cond = 'Exam 2: Sunshine';
spectra{4}.cond = 'Exam 2: Speed test';

for condnum = 1:length(spectra)
    
    % Concatenate the Fourier coef chunks together
    tempfeeg = [];
    
    fcoefeeg_chunks = cell(1,length(startTimes));
    for windowNum = 1:length(startTimes) % for each window number
        temp = fcoefeeg{condnum,windowNum};
        fcoefeeg_chunks{condnum}(:,:,:,windowNum) = temp;
        tempfeeg = cat(3,tempfeeg,temp);
    end       
    
    %EEG Power (defined as variance of fourier coefficients for a single
    %window (from tempfeeg <- tempfeeg <- fcoefeeg at window number)
    spectra{condnum}.trialfcoefeeg(:,:,:) = temp;
    spectra{condnum}.eegpower(:,:) = var(tempfeeg,1,3);
    spectra{condnum}.eegeppower(:,:) = squeeze(abs(mean(tempfeeg,3)).^2);
    
    %EEG Power Chunks
    for windowNum = 1:length(startTimes)
        
        spectra{condnum}.eegpower_trialchunks(:,:,1,windowNum) = ...
            abs((fcoefeeg{windowNum}(:,:,windowNum).^2));
        
        spectra{condnum}.eegpower_chunks(:,:,windowNum) = ...
            var(fcoefeeg_chunks{condnum}(:,:,:,windowNum),1,3);
        
        spectra{condnum}.eegeppower_chunks(:,:,windowNum) = ...
            squeeze(abs(mean(fcoefeeg_chunks{condnum}(:,:,:,windowNum),3)).^2);
    end
    
    for song = 1:length(spectra)
        %Organize the structure
        spectra{song}.freqs = ((1:maxbin)-1)*finalclean{i}.sr/windowSize;
        spectra{song}.startTimes = startTimes{i};
        spectra{song}.midtime = startTimes{i}+windowSize/2;
        spectra{song}.goodchan = goodchan{i};
        spectra{song}.windowSize = windowSize;
        spectra{song}.subname = subname;
        
    end;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end

%% saving data
disp(strcat('Saving to: ',pwd));
savestring = strcat(subname,'_spectanalysis.mat');
save(savestring,'spectra');
disp('Finished! =D');

end

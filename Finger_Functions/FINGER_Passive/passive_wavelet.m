function data = passive_wavelet(subname,chansInterest,saveBool,data)
% Wavelet convolution of continuous EEG signal (not yet segmented) to avoid
% edge artifacts. See details: 
%
% Input: 
% subname = e.g. 'SLN' 
%
% uses subjects data file where data is a structure containing
% data.sr (sampling rate) and data.eeg (the signal) where:
% signal = array of signals as vectors (channel x samples)
%
%
% Constants: 
% wFreq = vector of wavelet frequencies to process (5:50 recommended)
% nCycles = number of cycles of the wavelet wanted ( 4   recommended)
%
% Outputs: 
% data is saved out again, now containing data.wavelet where:
% wave = (frequency_bin x channel x sample) 3D array of freq. domain data


%% loading data 
passive_setPath()

%Read in .mat file
if exist('data','var')
    disp('Concatenated data passed directly; skipping load...');
else
    filename = celldir([subname '*preProcessed.mat']);
    filename{1} = filename{1}(1:end-4);

    fprintf(['Loading ' filename{1} '...']);
    load(filename{1});  
    fprintf('Done.\n');
end

%% checking data for cleaning
if ~data.params.screened
    warning([subname ' data not cleaned!']);
end
if ~data.params.reOrdered     
    warning([subname ' data not in order!']);
end

%% setting constants
nRuns = length(data.eeg);   % number of runs
sampFreq = data.sr;         % sampling rate from data
wFreq = 5:40;               %vector of wavelet frequencies to process 
nCycles = 4;                %number of cycles of the wavelet wanted 
data.wavFreq = wFreq;       % saving to structure
data.wavCycles = nCycles;   % saving to structure

%% saving interest channels to structure & defining new data 
data.chansInterest = chansInterest;
for run = 1:nRuns
    data.eegInterest{run} = data.eeg{run}(chansInterest,:);
end

%% performing convolution
fprintf('Beginning wavelet convolution'); 
%preallocating for speed
for run = 1:nRuns         
    fprintf('\n----run number: %i / %i----\nsignal ',run,nRuns);
    dataDimensions = [length(wFreq),size(data.eegInterest{run})];
    data.wavelet{run} = zeros(dataDimensions);
    for ii = 1:size(data.eegInterest{run},1)  %for each channel (signal) 
        currentSig = data.eegInterest{run}(ii,:);
        fprintf('%i-',ii);
        for i = 1:length(wFreq)             %convolve with each freq wavelet
            f = wFreq(i);
            s = nCycles/(2*pi*f);   
            [wavelet,~] = cmorwavf(-1,1,2*sampFreq,s,f);    
            kernel = fliplr(wavelet);   

    %       convResult = conv(currentSig,kernel,'same');        
    %       resultIFFT = convResult;  %store in cell array

            % note: convolve = ifft(fft multiplication)          
            NFFT = length(currentSig)+length(kernel)-1;
            signalFFT = fft(currentSig,NFFT);   % taking the FFTs 
            kernelFFT = fft(kernel,NFFT);   
            resultFFT = signalFFT.*kernelFFT;   % finding the product
            resultIFFT = ifft(resultFFT);       % taking the inverse FFT
            % cutting the fat off        
            fat = floor((length(resultIFFT)-length(currentSig))/2);         
            resultIFFT = resultIFFT(fat+1:fat+length(currentSig));  
            data.wavelet{run}(i,ii,:) = resultIFFT;

        end %for each frequency
    end %for each signal
end % for each run
fprintf('\nDone.\n');


%% save concatenated data    
clear data.eegInterest
data.params.wavelet = true;
if exist('saveBool','var') && saveBool
    disp('Saving wavelet frequency-domain data...')
    passive_setPath();
    save(strcat(subname,'_wavData'),'data','-v7.3');
    disp('Done.');
else
    disp('Warning: Data not saved to disk; must pass directly');
end
end %function
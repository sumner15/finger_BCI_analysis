function waveletData = waveletTherapy(concatData)
% Wavelet convolution of continuous EEG signal (not yet segmented) to avoid
% edge artifacts. See details: 
%
% Input: 
% concatData is the structure produced by "preProcessTherapy"!! Do not pass
% the concatData directly from file. concatData is a structure containing
% concatData.sr (sampling rate) and concatData.motorEEG (the signal) where:
% signal = array of signals as vectors (channel x samples)
%
%
% Constants: 
% wFreq = vector of wavelet frequencies to process (5:50 recommended)
% nCycles = number of cycles of the wavelet wanted ( 4   recommended)
%
% Outputs: 
% concatData now contains concatData.wave where:
% wave = (frequency_bin x channel x sample) 3D array of freq. domain data


%% setting constants
nSongs = length(concatData.motorEEG);   % number of songs
sampFreq = concatData.sr;               % sampling rate from concatData
wFreq = 5:40;                   %vector of wavelet frequencies to process 
nCycles = 4;                    %number of cycles of the wavelet wanted 
concatData.wavFreq = wFreq;             % saving to structure
concatData.nCycles = nCycles;           % saving to structure

%% performing convolution
fprintf('Beginning wavelet convolution'); 
%preallocating for speed
for songNo = 1:nSongs          %for each song (6 total)
    fprintf('\n----song number: %i / %i----\n signal ',songNo,nSongs);
    dataDimensions = [length(wFreq),size(concatData.motorEEG{songNo})];
    concatData.wavelet{songNo} = zeros(dataDimensions);
    for ii = 1:size(concatData.motorEEG{songNo},1)  %for each channel (signal) 
        currentSig = concatData.motorEEG{songNo}(ii,:);
        fprintf('%i -',ii);
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
            concatData.wavelet{songNo}(i,ii,:) = resultIFFT;

        end %for each frequency
    end %for each signal
end % for each song
fprintf('\n Done.');


%% save concatenated data    
%concatData = rmfield(concatData,'eeg');
waveletData = concatData; clear concatData

end %function
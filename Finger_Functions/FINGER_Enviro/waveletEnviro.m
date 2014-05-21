function waveletConv = waveletEnviro(wFreq,signal,nCycles,sampFreq)
%SegFingerEnviro: wavelet convolution of  signal. Capable of handling
%several signals at once (nSignals), and outputs as a vector cell array of
%multidimensional arrays (wavelet freq. x samples (in time)). 
%
% Input: 
% nSignals = number of signals to process at once
% wFreq = vector of wavelet frequencies to process
% signal = vector cell array of signals as vectors (1x#samples vector)
% nCycles = number of cycles of the wavelet wanted
% sampFreq = sample frequency of the signal

fprintf('performing wavelet convolution (%i signal)...\n',nSignals);
waveletConv = cell(1,nSignals);     %preallocating for speed
for ii = 1:nSignals                 %for each signal 
    currentSig = signal{ii};
    for i = 1:length(wFreq)         %convolve with each freq wavelet
        f = wFreq(i);
        s = nCycles/(2*pi*f);   
        [wavelet,wTime] = cmorwavf(-1,1,2*sampFreq,s,f);    
        kernel = fliplr(wavelet);   
        
%%     convResult = conv(currentSig,kernel,'same');        
%       waveletConv{ii}(i,:) = convResult;  %store in cell array
        
        %% note: convolve = ifft(fft multiplication)          
        NFFT = length(currentSig)+length(kernel)-1;
        signalFFT = fft(currentSig,NFFT); % taking the FFTs 
        kernelFFT = fft(kernel,NFFT);   
        resultFFT = signalFFT.*kernelFFT;   % finding the product
        resultIFFT = ifft(resultFFT);       % taking the inverse FFT
        % cutting the fat off        
        fat = floor((length(resultIFFT)-length(currentSig))/2);         
        resultIFFT = resultIFFT(fat+1:fat+length(currentSig));  
        waveletConv{ii}(i,:) = resultIFFT;
        
    end %for each frequency
end %for each signal
disp('done.');
end %function
% This function analyzes the results of the FINGER environment study. 
%
% Input: 
% username = e.g. 'Sumner'
% subname = e.g. 'LASF' 
%
% The function pulls the final cleaned EEG data as a structure from the
% subjects' processed file (segWavData) in your local directory (please 
% download from the Cramer's lab servers). 
%
% Note that the calculation of ERD in this script is calculating the 
% decibel power as the 20*log10(abs(wavelet_coeff)).
%
% Input: username and subname as strings (e.g. subname = 'LASF')

function intraSubject(username, subname)
%% loading data 
setPathEnviro(username,subname)

%If the wavelet data variable isn't already in the global workspace
if(~exist('waveletData','var'))           
    %Read in .mat file
    filename = celldir([subname '*segWavData.mat']);

    filename{1} = filename{1}(1:end-4);
    disp(['Loading ' filename{1} '...']);
    global waveletData;
    waveletData = load(filename{1}); waveletData = waveletData.waveletData; 
    disp('Done.');
end

%% Some experiment variables
nSongs = length(waveletData.segWavData);

%% Computing EEG power
disp('Computing EEG power!')
for song = 1:nSongs
    fprintf('--- Working on Song %i / %i --- \n',song,nSongs);
    
    %computing power
    power{song} = abs(waveletData.segWavData{song}); 
    
    % Averaging across channels by hemisphere (L:1-7,R:8-14)
    power{song}(:,:,1,:) = mean(power{song}(:,:,1:7,:),3);   
    power{song}(:,:,2,:) = mean(power{song}(:,:,8:14,:),3);
    power{song} = power{song}(:,:,1:2,:); %clearing non-mean values
    
    % Averaging across all trials, and deleting singleton dimension
    % Final result: trialPower{song}(freqBin,hemisphere,trialTimeSample)
    % Final   size:             {6}  ( 36    x    2     x     3000 )
    trialPower{song} = squeeze(mean(power{song},1));
    
    % Computing decibel power
    % ADD THIS. Decibel power is 20*log(power(time)./baseline)
    % baseline power is something like mean(trialPower{song}(:,:,1:200))
    % (first 200msec comprises baseline)
end

%% Organizing remaining data to save out  

%% saving data
disp('Saving power average across trials');
save(strcat(subname,'_trialPower'),'trialPower','-v7.3');
disp('Done.');

end

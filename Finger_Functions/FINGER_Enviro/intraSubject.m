function intraSubject(username, subname, waveletData)
% This function analyzes the results of the FINGER environment study.  
%
% The function pulls the final cleaned EEG data as a structure from the
% subjects' processed file (segWavData) in your local directory (please 
% download from the Cramer's lab servers). 
%
% Note that the calculation of ERD in this script is calculating the 
% decibel power as the 20*log10(abs(wavelet_coeff)).
%
% Input: subname (identifier) as string, e.g. 'LASF', 
%        username as string, e.g. 'Sumner'
%        waveletData (optional) data set will speed up loading procedure

%% loading data 
setPathEnviro(username,subname)

%If the wavelet data variable isn't given
if nargin < 3
    %Read in .mat file
    filename = celldir([subname '*segWavData.mat']);

    filename{1} = filename{1}(1:end-4);
    disp(['Loading ' filename{1} '...']);    
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
    power{song}(:,:,1,:) = mean(power{song}(:,:,:,:),3); %currently evaluates all; change
    power{song}(:,:,2,:) = mean(power{song}(:,:,:,:),3); %back to 1:7,8:14 for hemispherical
    power{song} = power{song}(:,:,1:2,:); %clearing non-mean values
    
    % Averaging across all trials, and deleting singleton dimension
    % Final result: trialPower{song}(freqBin,hemisphere,trialTimeSample)
    % Final   size:             {6}  ( 36    x    2     x     3000 )
    trialPower{song} = squeeze(mean(power{song},1));
    
    % Computing decibel power
    % (first 250msec comprises baseline)
    baselinePower{song} = mean(trialPower{song}(:,:,1:250),3);
    baselinePower{song} = repmat(baselinePower{song},[1,1,size(trialPower{song},3)]);
    trialPowerDB{song} = trialPower{song}./baselinePower{song};
    trialPowerDB{song} = 10*log10(trialPowerDB{song});
end

%% Organizing remaining data to save out  

%% saving data
disp('Saving power average across trials');
save(strcat(subname,'_trialPower'),'trialPower','trialPowerDB','-v7.3');
disp('Done.');

end

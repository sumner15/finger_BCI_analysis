function intraSubject(username, subname, saveBool, waveletData)
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

%If the wavelet data variable isn't already in the global workspace
if ~exist('cleanWavData','var')
    %Read in .mat file
    filename = celldir([subname '*segWavData.mat']);

    filename{1} = filename{1}(1:end-4);
    disp(['Loading ' filename{1} '...']);        
    cleanWavData = load(filename{1}); 
    disp('Done.');
end

%% Some experiment variables
if isfield(cleanWavData,'waveletData')
    cleanWavData = cleanWavData.waveletData;
end
nSongs = length(cleanWavData.segEEG);

%% Computing EEG power
% note: segWavData is size {song}(trial x freq x chn x time) 
disp('Computing event-related power');
power = cell(1,nSongs);             trialPower = cell(1,nSongs); 
baselinePower = cell(1,nSongs);     trialPowerDB = cell(1,nSongs);
for song = 1:nSongs
    fprintf('Song %i / %i , ',song,nSongs);
    
    %computing power
    power{song} = abs(cleanWavData.segWavData{song}); 
    % Averaging across motor channels
    power{song} = squeeze(mean(power{song},3)); 
    % power is size {song}(trial x freq x time)
    
    % Averaging across all trials, and deleting singleton dimension
    trialPower{song} = squeeze(mean(power{song},1));
    % trialPower is size {song}(freq x time)
    
    % Computing decibel power
    % (first 250msec comprises baseline)
    baseSamples = round(0.25 * cleanWavData.sr); 
    baselinePower{song} = mean(trialPower{song}(:,1:baseSamples),2);
    baselinePower{song} = repmat(baselinePower{song},[1,size(trialPower{song},2)]);
    trialPowerDB{song} = trialPower{song}./baselinePower{song};
    trialPowerDB{song} = 10*log10(trialPowerDB{song});
end
fprintf('\n');

%% saving data
if saveBool
    disp('Saving power average across trials');
    save(strcat(subname,'_trialPower'),'trialPower','trialPowerDB','baseSamples','-v7.3');
    disp('Done.');
else
    disp('Warning: Data not saved to disk; must pass directly');

end
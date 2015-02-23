function intraSubjectTherapy(username, subname, cleanWavData)
% This function analyzes the results of the FINGER therapy study.  
%
% The function pulls the final cleaned EEG data as a structure from the
% subjects' processed file (cleanWavData) in your local directory (please 
% download from the Cramer's lab servers). 
%
% Note that the calculation of ERD in this script is calculating the 
% decibel power as the 20*log10(abs(wavelet_coeff)).
%
% Input: subname (identifier) as string, e.g. 'LASF', 
%        username as string, e.g. 'Sumner'
%        cleanWavData (optional) data set will speed up loading procedure

%% loading data 
setPathTherapy(username,subname)

%If the wavelet data variable isn't already in the global workspace
if nargin < 3
    loadBool = input('Do you want to load data from file? Type y or n:','s');
    if loadBool == 'y'
        %Read in .mat file
        filename = celldir([subname '*cleanWavData.mat']);

        filename{1} = filename{1}(1:end-4);
        disp(['Loading ' filename{1} '...']);        
        cleanWavData = load(filename{1}); cleanWavData = cleanWavData.cleanWavData; 
        disp('Done.');
    else
        error('You must pass cleanWavData structure to intraSubjectTherapy');
    end
end

%% Some experiment variables
nSongs = length(cleanWavData.segWavData);
motorChansHM = zeros(size(cleanWavData.motorChannels));
motorArtifact = cell(1,nSongs);
for chan = 1:length(cleanWavData.motorChannels)    
    % motor channel indices as defined by the current head model (256->194)
    motorChansHM(chan) = find(cleanWavData.hm.ChansUsed == cleanWavData.motorChannels(chan));
end
for song = 1:nSongs
    % motor artifacts only (will be rejected)
    motorArtifact{song} = cleanWavData.artifact{song}(motorChansHM,:);
    motorArtifact{song} = -1*(motorArtifact{song}-1); % flip bool (0<->1)
    motorArtifact{song} = repmat(
end

%% Computing EEG power
power = cell(1,nSongs); trialPower = cell(1,nSongs); 
baselinePower = cell(1,nSongs); trialPowerDB = cell(1,nSongs);
for song = 1:nSongs
    fprintf('--- Working on Song %i / %i --- \n',song,nSongs);
    
    %computing power
    power{song} = abs(cleanWavData.segWavData{song}); 
    
    % Averaging across motor channels
    power{song}(:,:,1,:) = mean(power{song}(:,:,:,:),3); 
    power{song}(:,:,2,:) = mean(power{song}(:,:,:,:),3); 
    power{song} = power{song}(:,:,1:2,:); %clearing non-mean values
    
    % Averaging across all trials, and deleting singleton dimension
    % Final result: trialPower{song}(freqBin,hemisphere,trialTimeSample)
    % Final   size:             {4}  ( 36    x    2     x     3000 )
    trialPower{song} = squeeze(mean(power{song},1));
    
    % Computing decibel power
    % (first 250msec comprises baseline)
    baselinePower{song} = mean(trialPower{song}(:,:,1:250),3);
    baselinePower{song} = repmat(baselinePower{song},[1,1,size(trialPower{song},3)]);
    trialPowerDB{song} = trialPower{song}./baselinePower{song};
    trialPowerDB{song} = 10*log(trialPowerDB{song});
end

%% Organizing remaining data to save out  

%% saving data
disp('Saving power average across trials');
save(strcat(subname,'_trialPower'),'trialPower','trialPowerDB','-v7.3');
disp('Done.');

end

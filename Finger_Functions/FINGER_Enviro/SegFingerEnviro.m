function waveletData = SegFingerEnviro(username,subname,saveBool,waveletData)
%SegFingerEnviro
%
% Segments FINGER environment study data into a 
% {song}(trial x freq x chn x time) cell array of segmented data
%
% Input: subname (identifier) as string, e.g. 'LASF', 
%        username as string, e.g. 'Sumner'
%        waveletData (optional) data set will speed up loading procedure


%% loading data if necessary
if exist('waveletData','var')
    disp('Wavelet data passed directly; skipping load...');
else
    filename = celldir([subname '*waveletData.mat']);
    filename{1} = filename{1}(1:end-4);

    fprintf(['Loading ' filename{1} '...']);
    load(filename{1});  
    fprintf('Done.\n');
end
%load('songName') %creates var songName <nNotes x 1 double> (ms)
setPathEnviro(username);
load('note_timing_Blackbird') %creates var Blackbird   <nNotes x 1 double>
clear data note_timing_Blackbird sunshineDay

%% info regarding the experimental setup
nSongs = length(waveletData.motorEEG);          % # songs per recording (6)
trialLength = 3;                                % length - one note trial (sec)
nTrials = length(blackBird);                % Number of notes in song
sr = waveletData.sr;                            % sampling rate
nChans = size(waveletData.eeg{1},1);            % number of active channels
nMotorChans = size(waveletData.motorEEG{1},1);  % number of ,motor channels
freqBins = length(waveletData.wavFreq);         % number of frequency bins 

%% Segment all-channel EEG data & wavelet data
fprintf('---Beginning Segmentation---');
for song = 1:nSongs    
    %structure: {song}(trial x chn x trial-time)
    waveletData.segEEG{song} = zeros(nTrials,nChans,sr*trialLength);        
    %structure: {song}(trial x freq x chn x trial-time)
    waveletData.segWavData{song} = zeros(nTrials,freqBins,nMotorChans,sr*trialLength);  
    
    fprintf('\nsong number: %i/%i ',song,nSongs);
    for trial = 1:nTrials        
        fprintf('.');
        %time indices that the current trial spans (3 sec total)
        timeStart = (trial-1)*sr*(trialLength+1)+1;
        timeSpan = timeStart:(timeStart+sr*trialLength-1);
        
        %filling segment into segEEG
        waveletData.segEEG{song}(trial,:,:) = waveletData.eeg{song}(:,timeSpan); %all channels       
        waveletData.segWavData{song}(trial,:,:,:) = waveletData.wavelet{song}(:,:,timeSpan);
    end    
end
fprintf('\n');
% clear memory
waveletData = rmfield(waveletData,{'eeg','wavelet'});
if isfield(waveletData,'vid'); waveletData = rmfield(waveletData,'vid'); end

%% Saving data
waveletData.params.segmented = false;
if saveBool
    setPathEnviro(username,subname);
    disp('Saving SEGMENTED wavelet frequency-domain data...')
    save(strcat(subname,'_segWavData'),'waveletData','-v7.3');
    disp('Done.');
else
    disp('Warning: Data not saved to disk; must pass directly');
end

end

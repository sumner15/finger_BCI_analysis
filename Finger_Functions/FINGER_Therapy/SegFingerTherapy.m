function waveletData = SegFingerTherapy(username,subname,waveletData)
%SegFingerEnviro
%
% Segments FINGER therapy study data into a 
% {song}(trial x freq x chn x time) cell array of segmented data
%
% Input: subname (identifier) as string, e.g. 'LASF', 
%        username as string, e.g. 'Sumner'
%        waveletData (optional) data set will speed up loading procedure


%% Read in note/trial timing data 
cd .. ; cd .. ;
%load('songName') %creates var songName <nNotes x 1 double> (ms)
load('note_timing_SpeedTest')
load('note_timing_SunshineDay')
setPathTherapy(username,subname)

%% info regarding the experimental setup
nSongs = length(waveletData.motorEEG);          % # songs per recording (6)
triallength = 3;                                % length - one note trial (sec)
nTrials = [length(sunshineDay) length(speedTest)];  % Number of notes 
nTrials = repmat(nTrials,[1 2]);                % (extending to 4 songs)
sr = waveletData.sr;                            % sampling rate
nChans = size(waveletData.eeg{1},1);            % number of active channels
nMotorChans = size(waveletData.motorEEG{1},1);  % number of ,motor channels
freqBins = length(waveletData.wavFreq);         % number of frequency bins 

%% Create marker spike trains                       
markerInds = cell(1,nSongs);
for songNo = 1:nSongs
    %start index of time sample marking beginning of trial (from labjack)
    startInd = min(find(abs(waveletData.vid{songNo})>1000000));
    %markerInds is an integer array of marker indices (for all trials)
    if songNo==1 || songNo==3
        markerInds{songNo} = startInd+round(sunshineDay);
    else
        markerInds{songNo} = startInd+round(speedTest);
    end
end

%% Segment all-channel EEG data
fprintf('Beginning Segmentation');
% Initialize data structure components
for songNo = 1:nSongs
    %structure: {song}(trial x chn x trial-time)
    waveletData.segEEG{songNo} = zeros(nTrials(songNo),nChans,sr*triallength);    
end
% segmentation
for songNo = 1:nSongs    
    fprintf('\n----song number: %i / %i----\n signal ',songNo,nSongs);
    for trialNo = 1:nTrials(songNo)        
        fprintf('%i -',trialNo);
        %time indices that the current trial spans (3 sec total)
        timeSpan = markerInds{songNo}(trialNo)-(sr*triallength/2):markerInds{songNo}(trialNo)+(sr*triallength/2)-1; 
        %filling segment into segEEG
        waveletData.segEEG{songNo}(trialNo,:,:) = waveletData.eeg{songNo}(:,timeSpan); %all channels       
    end    
end
% clear memory
waveletData = rmfield(waveletData,'eeg');

%% Segment Wavelet data & Motor EEG
for songNo = 1:nSongs
    %structure: {song}(trial x freq x chn x trial-time)
    waveletData.segWavData{songNo} = zeros(nTrials(songNo),freqBins,nMotorChans,sr*triallength);  
    %structure: {song}(trial x chn x trial-time)    
    waveletData.segMotorEEG{songNo}= waveletData.segEEG{songNo}(:,waveletData.motorChannels,:);
end
% segmentation
for songNo = 1:nSongs
    fprintf('\n----song number: %i / %i----\n signal ',songNo,nSongs);
    for trialNo = 1:nTrials(songNo)
        fprintf('%i -',trialNo);
        %time indices that the current trial spans (3 sec total)
        timeSpan = markerInds{songNo}(trialNo)-(sr*triallength/2):markerInds{songNo}(trialNo)+(sr*triallength/2)-1; 
        %filling segment into waveletData
        waveletData.segWavData{songNo}(trialNo,:,:,:) = waveletData.wavelet{songNo}(:,:,timeSpan);
    end
end

%% Saving data
if(isfield(waveletData,'vid'))
    waveletData = rmfield(waveletData,{'vid','motorEEG','wavelet'});
end

fprintf('\n'); disp('Saving SEGMENTED wavelet frequency-domain data...')
save(strcat(subname,'_segWavData'),'waveletData','-v7.3');
disp('Done.');

end

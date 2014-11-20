function waveletData = SegFingerTherapy(username,subname,waveletData)
%SegFingerEnviro
%
% Segments FINGER therapy study data into a 
% {song}(trial x freq x chn x time) cell array of segmented data
%
% Input: subname (identifier) as string, e.g. 'LASF', 
%        username as string, e.g. 'Sumner'
%        waveletData (optional) data set will speed up loading procedure


%% loading data 
setPathTherapy(username,subname)

%If the wavelet data variable isn't already in the global workspace
if nargin < 3
    %Read in .mat file
    filename = celldir([subname '*waveletData.mat']);
    
    filename{1} = filename{1}(1:end-4);
    disp(['Loading ' filename{1} '...']);    
    waveletData = load(filename{1}); waveletData = waveletData.waveletData; 
    disp('Done.');
end
%Remove the eeg only component if it exists (legacy scripts kept eeg field)
if(isfield(waveletData,'eeg'))
    waveletData = rmfield(waveletData,'eeg');
end

%Read in note/trial timing data 
cd .. ; cd .. ;
%load('songName') %creates var songName <nNotes x 1 double> (ms)
load('note_timing_SpeedTest')
load('note_timing_SunshineDay')
setPathTherapy(username,subname)

%% info regarding the experimental setup
nSongs = length(waveletData.motorEEG);      % # songs per recording (6)
triallength = 3;                            % length - one note trial (sec)
nTrials = [length(sunshineDay) length(speedTest)];  % Number of notes 
nTrials = repmat(nTrials,[1 2]);            % (extending to 4 songs)
sr = waveletData.sr;                        % sampling rate
nChans = size(waveletData.wavelet{1},2);    % number of active channels
freqBins = length(waveletData.wavFreq);     % number of frequency bins 

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

%% Initialize data structure components
for songNo = 1:nSongs
    %structure: {song}(trial x freq x chn x trial-time)
    waveletData.segWavData{songNo} = zeros(nTrials(songNo),freqBins,nChans,sr*triallength);    
    %structure: {song}(trial x chn x trial-time)
    waveletData.segEEG{songNo}     = zeros(nTrials(songNo),nChans,sr*triallength);
end

%% Segment EEG data
for songNo = 1:nSongs
    fprintf('\n Song Number %i / %i \n',songNo,nSongs);
    for trialNo = 1:nTrials(songNo)
        fprintf('- %2i ',trialNo);
        %time indices that the current trial spans (3 sec total)
        timeSpan = markerInds{songNo}(trialNo)-(sr*triallength/2):markerInds{songNo}(trialNo)+(sr*triallength/2)-1; 
        %filling segment into segEEG
        waveletData.segEEG{songNo}(trialNo,:,:) = waveletData.motorEEG{songNo}(:,timeSpan);
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

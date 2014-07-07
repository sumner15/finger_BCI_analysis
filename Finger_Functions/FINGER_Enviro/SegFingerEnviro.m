function SegFingerEnviro(username,subname)
%SegFingerEnviro
%
% Segments FINGER environment study data into a 
% {song}(trial x freq x chn x time) cell array of segmented data
%
% Input: subname (identifier) as string, e.g. 'LASF', 
%        username as string, e.g. 'Sumner'


%% loading data 
setPathEnviro(username,subname)

%Read in .mat file
filename = celldir([subname '*waveletData.mat']);

filename{1} = filename{1}(1:end-4);
disp(['Loading ' filename{1} '...']);
load(filename{1});  
disp('Done.');

%Read in note/trial timing data 
cd .. ; 
load('note_timing_Blackbird') %creates var Blackbird   <nNotes x 1 double>
clear data note_timing_Blackbird sunshineDay

%% info regarding the experimental setup
nSongs = length(waveletData.eeg);           % # songs per recording (6)
triallength = 3;                            % length - one note trial (sec)
nTrials = length(blackBird);                % Number of notes in song
sr = waveletData.sr;                        % sampling rate
nChans = size(waveletData.wavelet{1},2);    % number of active channels
freqBins = length(waveletData.wavFreq);     % number of frequency bins 


%% Create marker spike trains
markerInds = cell(1,nSongs);
marker =     cell(1,nSongs);

for songNo = 1:nSongs
    %start index of time sample marking beginning of trial (from labjack)
    startInd = min(find(abs(waveletData.vid{songNo})>2000));
    %markerInds is an integer array of marker indices (for all trials)
    markerInds{songNo} = startInd+round(blackBird);
end


%% Initialize data structure components
for songNo = 1:length(waveletData.eeg)
    %structure: {song}(trial x freq x chn x trial-time)
    waveletData.segWavData{songNo} = zeros(nTrials,freqBins,nChans,sr*triallength);    
    %structure: {song}(trial x chn x trial-time)
    waveletData.segEEG{songNo}     = zeros(nTrials,257,sr*triallength);
end

%% Segment EEG data
disp('Segmenting data');
for songNo = 1:nSongs
    fprintf('---- song %i / %i ----\n Trial:',songNo,nSongs);
    for trialNo = 1:nTrials
        fprinf('|');
        %time indices that the current trial spans (3 sec total)
        timeSpan = markerInds{songNo}(trialNo)-(sr*1.5):markerInds{songNo}(trialNo)+(sr*1.5)-1; 
        %filling segment into segEEG
        waveletData.segEEG{songNo}(trialNo,:,:) = waveletData.eeg{songNo}(:,timeSpan);
        %filling segment into waveletData
        waveletData.segWavData{songNo}(trialNo,:,:,:) = waveletData.wavelet{songNo}(:,:,timeSpan);
    end
end
fprintf('\n');

%% Saving data

disp('Saving SEGMENTED wavelet frequency-domain data...');
save(strcat(subname,'_waveletData'),'waveletData','-v7.3');
disp('Done.');

end

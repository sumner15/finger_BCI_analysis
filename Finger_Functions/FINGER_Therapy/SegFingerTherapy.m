function waveletData = SegFingerEnviro(username,subname,waveletData)
%SegFingerEnviro
%
% Segments FINGER environment study data into a 
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
cd .. ; 
%load('note_timing_Blackbird') %creates var Blackbird   <nNotes x 1 double>
load('song')
cd(subname);

%% info regarding the experimental setup
nSongs = length(waveletData.motorEEG);      % # songs per recording (6)
triallength = 3;                            % length - one note trial (sec)
nTrials = length(blackBird);                % Number of notes in song
sr = waveletData.sr;                        % sampling rate
nChans = size(waveletData.wavelet{1},2);    % number of active channels
freqBins = length(waveletData.wavFreq);     % number of frequency bins 


%% Create marker spike trains                       %%%%%%%%%%% ADJUST TO ACCEPT MULTIPLE SONGS %%%%%%%%%%%
markerInds = cell(1,nSongs);
marker =     cell(1,nSongs);

for songNo = 1:nSongs
    %start index of time sample marking beginning of trial (from labjack)
    startInd = min(find(abs(waveletData.vid{songNo})>2000));
    %markerInds is an integer array of marker indices (for all trials)
    markerInds{songNo} = startInd+round(blackBird);
end

%% Initialize data structure components
for songNo = 1:nSongs
    %structure: {song}(trial x freq x chn x trial-time)
    waveletData.segWavData{songNo} = zeros(nTrials,freqBins,nChans,sr*triallength);    
    %structure: {song}(trial x chn x trial-time)
    waveletData.segEEG{songNo}     = zeros(nTrials,nChans,sr*triallength);
end

%% Reordering data according to run type
% cd ..
% load runOrder.mat   %identifying run order
% subjects = {'BECC','NAVA','TRAT','POTA','TRAV','NAZM',...
%             'TRAD','DIAJ','GUIR','DIMC','LURI','TRUS'};        
% subNum = find(ismember(subjects,subname));
% waveletData.runOrder = runOrder(subNum,:);
% cd(subname)

%% Segment EEG data
for songNo = 1:nSongs
    fprintf('\n Song Number %i / %i \n',songNo,nSongs);
    runNo = waveletData.runOrder(songNo);
    for trialNo = 1:nTrials
        fprintf('- %2i ',trialNo);
        %time indices that the current trial spans (3 sec total)
        timeSpan = markerInds{songNo}(trialNo)-(sr*triallength/2):markerInds{songNo}(trialNo)+(sr*triallength/2)-1; 
        %filling segment into segEEG
        waveletData.segEEG{runNo}(trialNo,:,:) = waveletData.motorEEG{songNo}(:,timeSpan);
        %filling segment into waveletData
        waveletData.segWavData{runNo}(trialNo,:,:,:) = waveletData.wavelet{songNo}(:,:,timeSpan);
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

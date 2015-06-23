function screenOut = screenTherapy(username, subname, concatData)
% This is a wrapper function that allows the use of the artscreen.m
% function on the FINGER therapy clinical EEG data
%
% inputs: 
% username as string (e.g. 'Sumner')
% subname as 4-character string (e.g. NORS)
% concatData, a structure produced by the FINGER therapy analysis code.
% concatData is an optional argument, mostly useful for debugging so you
% don't have to load the data every time you run the function. 

%% loading data if necessary
if ~exist('concatData','var')
    setPathTherapy(username,subname);
    filename = celldir([subname '*concatData.mat']);
    filename = filename{1}(1:end-4);
    disp(['Loading ' filename '...']);
    load(filename);  
end
% Read in note/trial timing data 
setPathTherapy(username);
%load('songName') %creates var songName <nNotes x 1 double> (ms)
load('note_timing_SpeedTest')
load('note_timing_SunshineDay')

%% check to see if we've already cleaned this data
if concatData.params.screened && concatData.params.ICA
    disp('This data has already been cleaned');
    screenOut = NaN;
    return
end

%% common var definition
nSongs = length(concatData.eeg);    % number of songs (should be 4)
nChans = length(concatData.hm.ChansUsed); % number of channels (194)
sr = concatData.sr;                 % sampling rate 
trialLength = 3;                    % length - one note trial (sec)
nTrials = [length(sunshineDay) length(speedTest)];  % Number of notes 
nTrials = repmat(nTrials,[1 2]);    % (extending to 4 songs)

%% Segment all-channel EEG data
markerInds = cell(1,nSongs);
% creating marker spike train
for song = 1:nSongs
    %start index of time sample marking beginning of trial (from labjack)
    startInd = find(abs(concatData.vid{song})>1000000, 1 );
    %markerInds is an integer array of marker indices (for all trials)
    if song==1 || song==3
        markerInds{song} = startInd+round(sunshineDay);
    else
        markerInds{song} = startInd+round(speedTest);
    end
end
disp('Segmenting EEG for cleaning...');      
segEEG = cell(1,nSongs);
for song = 1:nSongs    
    %structure: {song}(trial x chn x trial-time)
    segEEG{song} = zeros(nTrials(song),nChans,sr*trialLength);  
        
    for trialNo = 1:nTrials(song)            
        %time indices that the current trial spans (3 sec total)
        timeSpan = markerInds{song}(trialNo)-(sr*trialLength/2):markerInds{song}(trialNo)+(sr*trialLength/2)-1; 
        %filling segment into segEEG
        segEEG{song}(trialNo,:,:) = concatData.eeg{song}(:,timeSpan); %all channels       
    end    
end

%% CLEANING (wrapper)
% creating datain var for use in artscreen
dataIn.sr = concatData.sr;
dataIn.hm = concatData.hm;
for song = 1:nSongs
   % segEEG{song} (trial x channel x sample)
   %                   becomes
   % datain.data  (sample x channel x trial)
   dataIn.data = permute(segEEG{song},[3 2 1]);  
   
   dataOut = artscreen(dataIn);        
   dataOut = icasegdata(dataOut);
   dataOut = icareview(dataOut);
   dataOut = icatochan(dataOut);
   concatData.artifact{song} = dataOut.artifact;
   % segEEG{song} (sample x channel x trial)
   segEEG{song} = dataOut.data;   
end

%% compile data back into continuous EEG (zero-padded)
disp('re-structuring data (to continuous eeg :: zero-padded, 1sec');
for song = 1:nSongs
    totalSamples = nTrials(song)*sr*(trialLength+1);
    concatData.eeg{song} = zeros(nChans,totalSamples);
    for trial = 1:nTrials(song)
        timeStart = (trial-1)*sr*(trialLength+1)+1;
        timeSpan = timeStart:(timeStart+sr*trialLength-1);
        if max(concatData.eeg{song}(:,timeSpan)) ~= 0
            error('overlapping data');
        else
            concatData.eeg{song}(:,timeSpan) = squeeze(segEEG{song}(:,:,trial))';
        end
    end
end

%% save data if wanted
saveBool = input('Would you like to save? Type y or n: ','s');
if saveBool == 'y'
    setPathTherapy(username,subname);    
    concatData.params.screened = true;
    concatData.params.ICA = true;
    save(strcat(subname,'_concatData'),'concatData','-v7.3');  
end

end
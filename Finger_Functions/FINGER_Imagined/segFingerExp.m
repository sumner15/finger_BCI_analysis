function segFingerExp(subname)
%segFingerExp(subname)
%
% Segments FINGER experiment data into a channel by sample by trial array
%
% Input: subname as string, e.g. 'Mark'
%

if ispc == 1
    cd(strcat('FINGER_EEG_imagery_data\',subname,'002'));
else
    cd(strcat('~/Documents/MATLAB/FINGER_data/FINGER_EEG_imagery_data/',subname,'002'));
end

dat_dir = dir('*.dat');

for j = 1:length(dat_dir)
    datfiles{j} = dat_dir(j).name;
end

% load the EGI head model
load egihm.mat
segdata.hm = EGI;

%% info regarding the experimental setup
sr = 600; % sampling rate 
triallength = 3; % approximate length of a one note trial
nchans = 128; % number of eeg channels recorded

%% Variables determined from the data
nblocks = length(datfiles);
numtrials = 40;   % Number of trials per block (assuming this is constant for Walk the Line)

%% Initialize data structure components
segdata.sr = sr;
segdata.markers = zeros(sr*triallength,numtrials);
segdata.data = zeros(sr*triallength,nchans,numtrials);

bb = 0;
%% Import EEG data
for b = 1:nblocks; % for each block being segmented
    disp(['Loading ' datfiles{b} '...']);
    [eeg markers] = load_bcidat(datfiles{b});
    eeg = filtereeg(eeg,sr);
    
    % Finds which samples the marker occurred 
    ind_cleanmarkers = GetFingerSpike(markers)';
    segdata.cleanmarkers{b} = ind_cleanmarkers;
    
    % segment into a sample x channel x trial matrix
    for i = 1:length(ind_cleanmarkers)
        bb = bb + 1;
        segdata.data(:,:,bb) = eeg(ind_cleanmarkers(i)-sr*1.5:ind_cleanmarkers(i)+sr*1.5-1,:);
    end   
end

save(strcat(subname,'_002_segdata'),'segdata');
disp(strcat(subname,'_002_segdata.mat saved.'));
 
cd ..
cd ..

end

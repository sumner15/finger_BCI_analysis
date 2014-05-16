function [concatData] = concatEnviro(username,subname)
%concatEnviro
%
% concatEnviro concatenates the files from the environmental FINGER study
% into a structure.
%
% The concatData structure contains a single raw data array that is 
% 256_channels x nTimeSamples. It also contains an index array containing 
% the beginning indices for each sub-test. note: this function excludes
% resting state data from the final structure.
%
% Input: subname (identifier) as string, e.g. 'LASF', 
%        username as string, e.g. 'Sumner'


%% Load in subject .mat data file, timing data, and head model

switch username
    case 'Sumner'
        if ispc==1
            cd('C:\Users\Sumner\Desktop\FINGER-Enviro study')             
        else
            cd('/Users/sum/Desktop/Finger-Enviro study');
        end
    case 'Omar'
        cd('C:\Users\Omar\Desktop\FINGER-Enviro study')  
    case 'Camilo'
        cd('C:\Users\Camilo\Desktop\FINGER-Enviro study') 
    case 'Thuong'
        cd('C:\Users\Thuong\Documents\SPRING 2014\Research\Enviro_Study_Data');
end
addpath .; cd subname

%% Read in .mat file
filename = celldir([subname '*.mat']);
filename = filename{1}(1:end-4);
disp(['Loading ' filename '...']);
load(filename);

% Read in note/trial timing data 
cd .. ; 
load('note_timing_Blackbird') %creates var Blackbird   <nNotes x 1 double>

% load the EGI head model
load egihc256redhm
segdata1.hm = EGIHC256RED;
segdata2.hm = EGIHC256RED;

%% info regarding the experimental setup
sr = samplingRate;
triallength = 3; % approximate length of a one note trial in seconds
nchans = length(EGIHC256RED.ChansUsed); % number of eeg channels in the headmodel

%% Variables determined from the data
numtrials1 = length(sunshineDay);   % Number of notes in Sunshine Day
numtrials2 = length(speedTest);     % Number of notes in Speed Test

%% Initialize data structure components
segdata1.sr = sr; segdata2.sr = sr;
segdata1.data = zeros(sr*triallength,nchans,numtrials1);
segdata2.data = zeros(sr*triallength,nchans,numtrials2);

%% Create marker spike trains

% Marker data for FINGER Game
filename = strrep(filename,' ','_');
marker1 = eval([filename '2Video_trigger']);
marker2 = eval([filename '3Video_trigger']);
ind1 = find(getspike(marker1) > 0)-2000;
ind2 = find(getspike(marker2) > 0)-2000;

for n = 1:numtrials1
    segdata1.marker1(1,ind1+sunshineDay(n)) = 1;    
end

for n = 1:numtrials2
    segdata2.marker2(1,ind2+speedTest(n)) = 1;    
end

marker1inds = find(segdata1.marker1 > 0);
marker2inds = find(segdata2.marker2 > 0);


%% Load, filter, and segment EEG data

eeg1 = eval([filename '2']);
eeg2 = eval([filename '3']);
disp('Filtering the data...');
eeg1 = filtereeg(eeg1(EGIHC256RED.ChansUsed,:)',sr);
eeg2 = filtereeg(eeg2(EGIHC256RED.ChansUsed,:)',sr);
  
% segment into sample x channel x trial matrix
for t = 1:numtrials1
    segdata1.data(:,:,t) = eeg1(marker1inds(t)-(sr*1.5):marker1inds(t)+(sr*1.5)-1,:);
end

for t = 1:numtrials2
    segdata2.data(:,:,t) = eeg2(marker2inds(t)-(sr*1.5):marker2inds(t)+(sr*1.5)-1,:);
end

disp('Saving segmented data...');
if ispc == 1 
    cd(strcat(subname,'\raw data\'))  
else
    cd(strcat(subname,'/raw data/'))
end
save(strcat(subname,'_segdata1'),'segdata1');
save(strcat(subname,'_segdata2'),'segdata2');

end

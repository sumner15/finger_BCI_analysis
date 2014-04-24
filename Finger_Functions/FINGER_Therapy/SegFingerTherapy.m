function segdata = SegFingerTherapy(username,subname)
%SegFingerTherapy
%
% Segments FINGER therapy data into a sample by channel by trial array
%
% Input: subname (identifier) as string, e.g. 'LASF', 
%        username ast string, e.g. 'Sumner'


% Load in subject .mat data file 

switch username
    case 'Sumner'
        if ispc==1
            cd('C:\Users\Sumner\Desktop\FINGER-EEG study')             
        else
            cd('/Users/sum/Desktop/Finger-EEG study');
        end
    case 'Omar'
        cd('C:\Users\Omar\Desktop\FINGER-EEG study')  
    case 'Camilo'
        cd('C:\Users\Camilo\Desktop\FINGER-EEG study') 
    case 'Thuong'
        cd('C:\Users\Thuong\Documents\SPRING 2014\Research\FINGER-EEG study');
end
addpath .
if ispc==1
    cd(strcat(subname,'\Exam 1\'))    
else
    cd(strcat(subname,'/Exam 1/'))    
end


filename = celldir([subname '*.mat']);
filename = filename{1}(1:end-4);
disp(['Loading ' filename '...']);
load(filename);

% Read in note/trial timing data 
cd .. ; cd ..;
load('note_timing_SunshineDay') %creates var speedTest   <70x1 double>
load('note_timing_SpeedTest')   %creates var sunshineDay <43x1 double>

% load the EGI head model
load egihc256redhm
segdata.hm = EGIHC256RED;

%% info regarding the experimental setup
sr = samplingRate;
triallength = 3; % approximate length of a one note trial in seconds
nchans = length(EGIHC256RED.ChansUsed); % number of eeg channels in the headmodel

%% Variables determined from the data
numtrials1 = length(sunshineDay);   % Number of notes in Sunshine Day
numtrials2 = length(speedTest);     % Number of notes in Speed Test

%% Initialize data structure components
segdata.sr = sr;
segdata.data = zeros(sr*triallength,nchans,numtrials1);

%% Create marker spike train

% Marker data for FINGER Game
filename = strrep(filename,' ','_');
marker1 = eval([filename '2Video_trigger']);
%marker1 = JOHG_20140122_12232Video_trigger;
ind1 = find(getspike(marker1) > 0)-2000;

for n = 1:numtrials1
    segdata.marker1(1,ind1+sunshineDay(n)) = 1;    
end

marker1inds = find(segdata.marker1 > 0);

% Marker data for Speed Test
% parse in info from text file into marker2
% save this variable as segdata.markers(2,:)
%marker2 = JOHG_20140122_12233Video_trigger;
%ind2 = find(getspike(marker2) > 0);


%% Load, filter, and segment EEG data

eeg = eval([filename '2']);
disp('Filtering the data...');
eeg = filtereeg(eeg(EGIHC256RED.ChansUsed,:)',sr);
  
% segment into sample x channel x trial matrix
for t = 1:numtrials1
    segdata.data(:,:,t) = eeg(marker1inds(t)-(sr*1.5):marker1inds(t)+(sr*1.5)-1,:);
end

disp('Saving segmented data...');
if ispc == 1 
    cd(strcat(subname,'\Exam 1\'))  
else
    cd(strcat(subname,'/Exam 1/'))
end
save(strcat(subname,'_segdata'),'segdata');

end

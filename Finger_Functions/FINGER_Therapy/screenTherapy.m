function screenOut = screenTherapy(username, subname, waveletData)
% This is a wrapper function that allows the use of the artscreen.m
% function on the FINGER therapy clinical EEG data
%
% inputs: 
% username as string (e.g. 'Sumner')
% subname as 4-character string (e.g. NORS)
% waveletData, a structure produced by the FINGER therapy analysis code.
% waveletData is an optional argument, mostly useful for debugging so you
% don't have to load the data every time you run the function. 

%% loading data if necessary
if nargin < 3
    setPathTherapy(username,subname);
    filename = celldir([subname '*segWavData.mat']);
    filename = filename{1}(1:end-4);
    disp(['Loading ' filename '...']);
    load(filename);  % pre-exam
end

%% common var definition
nSongs = length(waveletData.segEEG);

%% wrapper functionality
% creating datain var for use in artscreen
datain.sr = waveletData.sr;
datain.hm = waveletData.hm;
for song = 1:nSongs
   % waveletData.segEEG{song}(trial x channel x sample)
   %                   becomes
   %           datain.data   (sample x channel x trial)
   datain.data = permute(waveletData.segEEG{song},[3 2 1]);
   screenOut = artscreen(datain);
   waveletData.artifact{song} = screenOut.artifact;
   waveletData.screenedEEG{song} = screenOut.data;
end

%% save data if wanted
saveBool = input('Would you like to save? Type y or n: ','s');
if saveBool == 'y'
    setPathTherapy(username,subname);
    cleanWavData = waveletData;
    save(strcat(subname,'_cleanWavData'),'cleanWavData','-v7.3');  
end
end
% subject name
subname = 'Justin';
collection = 2;
cond = 3;
% collection 1:
% condition: spectra{n} corresponds to n= [active, passive, nostim]
% collection 2:
% condition: spectra{n} corresponds to n= [imagined, resting, active]

%load in the spectral analysis file from server
fprintf('loading spectral analysis for %s (collection %i)...', subname, collection);
if collection == 2
path = strcat('Z:\Transfer\FINGER_EEG_imagery_data\',...
       subname,'002\',subname,'_002_spectanalysis_mod.mat');
elseif collection == 1
path = strcat('Z:\Transfer\FINGER EEG initial data\',...
        subname,'001\',subname,'_001_spectanalysis_mod.mat');
else
    error('this collection number does not exist');
end
%load(path);
fprintf('done.\n');

% ORGANIZATION: 
% [...]chunks(frequency,channels,trial,time)
% frequency indexes: [0,8,16,24...]
freq = [2 4];
chan =  [7    31    37    42    32    38    43    48];

% finding the maximum log10 reduction in power of each trial 
space = size(squeeze(spectra{cond}.eegpower_trialchunks));
nTrials = space(3); %number of trials completed
maxDesync = zeros(nTrials,2);
for f = 1:length(freq)
    for i = 1:nTrials    
        power = mean(squeeze(spectra{cond}.eegpower_trialchunks(freq(f),chan,i,:)));
        restPower = mean(power);
        normPower = log10(power./restPower);
        maxDesync(i,f) = min(normPower);    
    end
end


function Finger_Emotiv_analysis(subname,os)
%Finger_EEG_analysis(subname)
%
% Input: subject name (as string)
%

% Set the environment
%environment('antegi');

if nargin < 2
    cd(strcat('~/Dropbox/Finger_BCI_DATA/FINGER EEG initial data/',subname,'001/'));
elseif os == 2
    cd(strcat('E:\Dropbox\Finger_BCI_DATA\FINGER EEG initial data\',subname,'001\'));
end

% Load the cleaned data
disp('Loading cleaned data...');
finalclean = load(strcat(subname,'_001_finalclean.mat'));

% Load the behavioral data (will need to convert your .txt output into a
% condition structure that is meaningful with the EEG
disp('Loading behavioral data...');
load(strcat(subname,'_001_bdata.mat'));

ncond = length(unique(bdata.conds));

%%%%%%%%%%%%%%%%%%%%
%%% EEG ANALYSES %%%
%%%%%%%%%%%%%%%%%%%%

%pick windowing for analysis
windowsize = 128;
starttime =  1:128:128*3;

%pick max frequency to save
maxfreq = 30;
df = finalclean.sr/windowsize;
maxbin = ceil(maxfreq/df)+1;
freqs = (0:(maxbin-1))*df;

%Identify goodchan and goodepoch
sumbadchan = sum(finalclean.artifact,2);
goodchan = find(sumbadchan < 30);
sumbadepoch = sum(finalclean.artifact,1);
goodepoch = find(sumbadepoch < 30);

% Separate out trials by condition
for j = 1:ncond
    trials{j} = intersect(goodepoch,find(bdata.conds == j));
end;

disp('FFTing the data...');

for j = 1:length(starttime)
    win = starttime(j):(starttime(j)+windowsize-1);
    % Fast Fourier Transform
    fcoefeeg{j} = fft(ndetrend(finalclean.eeg(win,:,:),[],1));
    %limit to max frequency
    fcoefeeg{j} = fcoefeeg{j}(1:maxbin,:,:);
end

%separate results by condition
spectra{1}.cond = 'ACTIVE';
spectra{2}.cond = 'PASSIVE';
spectra{3}.cond = 'NOSTIM';

for k = 1:ncond
    
    %cat the fcoefs together
    tempfeeg = [];
    for j = 1:length(starttime)
        temp = fcoefeeg{j}(:,:,trials{k});
        fcoefeeg_chunks{k}(:,:,:,j) = temp;
        tempfeeg = cat(3,tempfeeg,temp);
    end
    
    %EEG POWER
    spectra{k}.trialfcoefeeg(:,:,:) = temp;
    spectra{k}.eegpower(:,:) = var(tempfeeg,1,3);
    spectra{k}.eegeppower(:,:) = squeeze(abs(mean(tempfeeg,3)).^2);
    
    %EEG & EMG POWER CHUNKS
    for j = 1:length(starttime)
        spectra{k}.eegpower_chunks(:,:,j) = var(fcoefeeg_chunks{k}(:,:,:,j),1,3);
        spectra{k}.eegeppower_chunks(:,:,j) = squeeze(abs(mean(fcoefeeg_chunks{k}(:,:,:,j),3)).^2);
    end
    
    for j = 1:ncond
        %some house keeping
        spectra{j}.trials = trials{j};
        spectra{j}.freqs = ((1:maxbin)-1)*finalclean.sr/windowsize;
        spectra{j}.starttime = starttime;
        spectra{j}.midtime = starttime+windowsize/2;
        spectra{j}.goodchan = goodchan;
        
    end;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end

disp(strcat('Saving to: ',pwd));
clear finalclean
save(strcat(subname,'_001_spectanalysis.mat'));
disp(strcat('Finished! =D'));

end

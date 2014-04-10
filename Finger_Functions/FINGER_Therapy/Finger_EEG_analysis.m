%EDIT ME EDIT ME EDIT ME
% This function is currently functioning for power analysis (ERD) from the
% pilot study for the FINGER environmental effects on ERD study. It now
% needs modification to examine power changes (ERD) in the FINGER therapy
% study paradigm. Good luck! -Sumner 03/13/14

function Finger_EEG_analysis(subname)
% Finger_EEG_analysis(subname)
% Input: subject name (as string)

% Set the environment
environment('antegi');                                              %CHECK THIS!!

% Load in subject .mat data file 
if ispc ==1
    cd('C:\Users\Sumner\Desktop\FINGER-EEG study')  
    cd(strcat(subname,'\Exam 1\'))    
else
    error('Please identify path for Linux machines in function');
end

% Load the cleaned data
disp('Loading cleaned data...');
finalclean = load(strcat(subname,'_finalclean.mat'));

% note: behavioral data neither required nor processed for therapy study
% -SN Mar 18 2014
numconds = 1;

% % Load the behavioral data created from LoadBlockInfo.m
% disp('Loading behavioral data...');
% load(strcat(subname,'_bdata.mat'));
% 
% %numconds = length(unique(bdata.condsEL));
% numconds = length(unique(bdata.conds));

%%%%%%%%%%%%%%%%%%%%
%%% EEG ANALYSES %%%
%%%%%%%%%%%%%%%%%%%%

%pick windowing for analysis
windowsize = 75; %samples
starttime =  1:75:1800;

%pick max frequency to save
maxfreq = 50; %Hertz
df = finalclean.sr/windowsize;
maxbin = ceil(maxfreq/df)+1;
freqs = (0:(maxbin-1))*df;

%Identify goodchan and goodepoch
sumbadchan = sum(finalclean.artifact,2);
goodchan = find(sumbadchan < 30);
sumbadepoch = sum(finalclean.artifact,1);
goodepoch = find(sumbadepoch < 30);

% % Separate out trials by condition
% for k = 1:numconds
%     %trialtype{k} = intersect(goodepoch,find(bdata.condsEL == k));
%     trialtype{k} = intersect(goodepoch,find(bdata.conds == k));
% end;

disp('FFTing the data...');

for epoch = 1:length(starttime)
    win = starttime(epoch):(starttime(epoch)+windowsize-1);
    % Fast Fourier Transform
    if isfield(finalclean,'data')
        fcoefeeg{epoch} = fft(ndetrend(finalclean.data(win,:,:),[],1));
    else
        fcoefeeg{epoch} = fft(ndetrend(finalclean.eeg(win,:,:),[],1));
    end
    % limit to max frequency
    fcoefeeg{epoch} = fcoefeeg{epoch}(1:maxbin,:,:);
end

% separate results by condition
spectra{1}.cond = 'Imagined Movement';
spectra{2}.cond = 'Resting State';
spectra{3}.cond = 'Active Movement - Early';
spectra{4}.cond = 'Active Movement - Late';

for condnum = 1:numconds
    
    % Concatenate the Fourier coef chunks together
    tempfeeg = [];
    for epoch = 1:length(starttime)
        %temp = fcoefeeg{epoch}(:,:,trialtype{condnum});        
        %fcoefeeg_chunks{condnum}(:,:,:,epoch) = temp;
        temp = fcoefeeg{epoch};
        fcoefeeg_chunks{condnum}(:,:,:,epoch) = temp;
        tempfeeg = cat(3,tempfeeg,temp);
    end
    
    %EEG Power
    spectra{condnum}.trialfcoefeeg(:,:,:) = temp;
    spectra{condnum}.eegpower(:,:) = var(tempfeeg,1,3);
    spectra{condnum}.eegeppower(:,:) = squeeze(abs(mean(tempfeeg,3)).^2);
    
    %EEG Power Chunks
    for epoch = 1:length(starttime)
        
        k=1;%for k = 1:length(trialtype{condnum})
            trialnum = trialtype{condnum}(k);
            spectra{condnum}.eegpower_trialchunks(:,:,k,epoch) = abs((fcoefeeg{epoch}(:,:,trialnum).^2));
        %end
        
        spectra{condnum}.eegpower_chunks(:,:,epoch) = var(fcoefeeg_chunks{condnum}(:,:,:,epoch),1,3);
        spectra{condnum}.eegeppower_chunks(:,:,epoch) = ...
            squeeze(abs(mean(fcoefeeg_chunks{condnum}(:,:,:,epoch),3)).^2);
    end
    
    for epoch = 1:numconds
        %Organize the structure
        spectra{epoch}.trials = trialtype{epoch};
        spectra{epoch}.freqs = ((1:maxbin)-1)*finalclean.sr/windowsize;
        spectra{epoch}.starttime = starttime;
        spectra{epoch}.midtime = starttime+windowsize/2;
        spectra{epoch}.goodchan = goodchan;
        
    end;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end

disp(strcat('Saving to: ',pwd));
clear finalclean
save(strcat(subname,'_002_spectanalysis_mod.mat'));
%save(strcat(subname,'_002_spectanalysis.mat'));
disp(strcat('Finished! =D'));

end

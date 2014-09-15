function plotSub(username,subname)
% plotSub pluts the intra-subject results of the FINGER environment study.  
%
% The function pulls the final analyzed EEG data from the subjects' 
% processed file (intraSubject.m gives trialPower) in your local directory 
% (please download from the Cramer's lab servers). 
%
% Input: subname (identifier) as string, e.g. 'LASF', 
%        username as string, e.g. 'Sumner'

conditions = {'AV-only','robot+motor','motor only','AV-only','robot only','AV-only'};

%% loading data
setPathEnviro(username,subname)
filename = celldir([subname '*trialPower.mat']);
filename{1} = filename{1}(1:end-4);
disp(['Loading ' filename{1} '...'])
load(filename{1});
disp('Done.')

%% plotting trial power (decibels)
freq = 8:11; % 18Hz - 23Hz (add 4)

scrsz = get(0,'ScreenSize'); 
set(figure,'Position',scrsz)

for song = 1:length(trialPowerDB)
    subplot(2,3,song)
    
    plot(-1500:1499,squeeze(mean(trialPowerDB{song}(freq,2,:),1)))
        
    title([subname ' ' conditions{song} ': Mu (' num2str(freq(1)+4) '-' num2str(freq(end)+4) 'Hz) normalized power']);
    ylabel('dB'); xlabel('trial time (msec)');
    axis([-1500 1500 -3 3]);
end

%% plotting trial power (raw)
set(figure,'Position',scrsz)

for song = 1:length(trialPower)
    subplot(2,3,song)
    
    plot(-1500:1499,squeeze(mean(trialPower{song}(freq,2,:),1)),'LineWidth',1.5)
        
    title([subname ' ' conditions{song} ': Mu (' num2str(freq(1)+4) '-' num2str(freq(end)+4) 'Hz) normalized power']);
    ylabel('power'); xlabel('trial time (msec)');
    axis([-1500 1500 0 3000]);   
end

%% plotting freq x time map (decibel)
set(figure,'Position',scrsz)

for song = 1:length(trialPowerDB)
    subplot(2,3,song);
    trialPowerDBrHem{song} = squeeze(trialPowerDB{song}(:,2,:));
    
    imagesc(-1500:1499,5:40,trialPowerDBrHem{song},[-3 3]); colorbar    
    set(gca,'YDir','normal')
    
    title([subname ' ' conditions{song} ': Normalized Power (dB)']);
    ylabel('frequency (Hz)'); xlabel('trial time (msec)')    
end

%% plotting freq x time map (raw)
set(figure,'Position',scrsz)

for song = 1:length(trialPowerDB)
    subplot(2,3,song);
    trialPowerRHem{song} = squeeze(trialPower{song}(:,2,:));
    
    imagesc(-1500:1499,5:40,trialPowerRHem{song},[100 1000]); colorbar    
    set(gca,'YDir','normal')
    
    title([subname ' ' conditions{song} ':Power']);
    ylabel('frequency (Hz)'); xlabel('trial time (msec)')    
end

%% plotting example spectra 
figure; hold on
colors = {'g','m','r','g','b','g'};
for song = 1:length(trialPowerDB)
    desyncPeriod = 500:1000;
    spectra = squeeze(trialPower{song}(:,2,:));     %right hemisphere only
    spectra = squeeze(mean(spectra(:,desyncPeriod),2)); %desync period only        
    h(song) = plot(5:40,spectra,colors{song});
end
title([subname ' amplitude spectra: t=' num2str(desyncPeriod(1)-1500) ':' num2str(desyncPeriod(end)-1500)]);
xlabel('Frequency (Hz)'); ylabel('Amplitude');
legend(h([1 2 3 5]),'AV only','robot+motor','motor','robot');


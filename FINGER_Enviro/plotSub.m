function plotSub(username,subname)
% plotSub pluts the intra-subject results of the FINGER environment study.  
%
% The function pulls the final analyzed EEG data from the subjects' 
% processed file (intraSubject.m gives trialPower) in your local directory 
% (please download from the Cramer's lab servers). 
%
% Input: subname (identifier) as string, e.g. 'LASF', 
%        username as string, e.g. 'Sumner'

disp(['Plotting results for ' subname]);
conditions = {'AV-only','robot+motor','motor only','AV-only','robot only','AV-only'};
t = -1500:1499;
%scrsz = get(0,'ScreenSize'); 
scrsz = [ 1 1 1306 677]+50;

%% loading data
setPathEnviro(username,subname)
filename = celldir([subname '*trialPower.mat']);
filename{1} = filename{1}(1:end-4);
disp(['Loading ' filename{1} '...'])
load(filename{1});
disp('Done.')

%% plotting trial power, Mu band (decibels)
freq = (8:13)-4; % (add 4)
set(figure,'Position',scrsz)

for song = 2:5 %1:length(trialPowerDB)
    subplot(2,2,song-1)
    
    dbPowerAtFreq = squeeze(mean(trialPowerDB{song}(freq,:),1));
    plot(t,dbPowerAtFreq);
        
    title([subname ' ' conditions{song} ': Mu (' num2str(freq(1)+4) '-' num2str(freq(end)+4) 'Hz) normalized power']);
    ylabel('dB'); xlabel('trial time (msec)');
    axis([-1400 1400 -5 5]);
end

%% plotting trial power (raw)
set(figure,'Position',scrsz)

for song = 1:length(trialPower)
    subplot(2,3,song)
    
    powerAtFreq = squeeze(mean(trialPower{song}(freq,:),1));
    plot(t,powerAtFreq,'LineWidth',1.5)
        
    title([subname ' ' conditions{song} ': Mu (' num2str(freq(1)+4) '-' num2str(freq(end)+4) 'Hz) normalized power']);
    ylabel('power'); xlabel('trial time (msec)');    
    xlim([-1400 1400]);
end

%% plotting freq x time map (decibel)
set(figure,'Position',scrsz)

for song = 1:length(trialPowerDB)
    subplot(2,3,song);
        
    imagesc(t,5:40,trialPowerDB{song}); colorbar    
    xlim([-1400 1400]);
    set(gca,'YDir','normal')
    
    title([subname ' ' conditions{song} ': Normalized Power (dB)']);
    ylabel('frequency (Hz)'); xlabel('trial time (msec)')    
end

%% plotting freq x time map (raw)
set(figure,'Position',scrsz)
suptitle(subname);
songs = [3 2 4 5];
for i = 1:length(songs) %1:length(trialPowerDB)
    song = songs(i);
    subplot(2,2,i);    
        
    imagesc(t,5:40,trialPower{song});%,[120 350]); 
    xlim([-1400 1400]);
    title(conditions{song});        
    set(gca,'YDir','normal')
    
    %title([subname ' ' conditions{song} ':Power']);
    %title(titles(song),'FontSize',20);
    ylabel('freq (Hz)','FontSize',24); xlabel('time (s)','FontSize',24);    
end

%% plotting example spectra 
figure; hold on
colors = {'g','m','r','g','b','g'};
for song = 1:length(trialPowerDB)
    desyncPeriod = 500:1000;    
    spectra = squeeze(mean(trialPower{song}(:,desyncPeriod),2)); %desync period only        
    h(song) = plot(5:40,spectra,colors{song});
end
title([subname ' amplitude spectra: t=' num2str(desyncPeriod(1)-1500) ':' num2str(desyncPeriod(end)-1500)]);
xlabel('Frequency (Hz)'); ylabel('Amplitude');
legend(h([1 2 3 5]),'AV only','robot+motor','motor','robot');


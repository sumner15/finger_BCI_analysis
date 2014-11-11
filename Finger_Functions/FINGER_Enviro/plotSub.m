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
freq = (8:13)-4; % (add 4)

scrsz = get(0,'ScreenSize'); 
set(figure,'Position',scrsz)

for song = 2:5 %1:length(trialPowerDB)
    subplot(2,2,song-1)
    
    plot(-1500:1499,squeeze(mean(trialPowerDB{song}(freq,2,:),1)))
        
    title([subname ' ' conditions{song} ': Mu (' num2str(freq(1)+4) '-' num2str(freq(end)+4) 'Hz) normalized power']);
    ylabel('dB'); xlabel('trial time (msec)');
    axis([-1500 1500 -5 5]);
end

%% plotting trial power (raw)
set(figure,'Position',scrsz)

for song = 1:length(trialPower)
    subplot(2,3,song)
    
    plot(-1500:1499,squeeze(mean(trialPower{song}(freq,2,:),1)),'LineWidth',1.5)
        
    title([subname ' ' conditions{song} ': Mu (' num2str(freq(1)+4) '-' num2str(freq(end)+4) 'Hz) normalized power']);
    ylabel('power'); xlabel('trial time (msec)');
    axis([-1500 1500 0 500]);   
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
set(figure,'Position',[ 1 1 1306 677])
songs = [3 2 4 5];
for i = 1:length(songs) %1:length(trialPowerDB)
    song = songs(i);
    subplot(2,2,i);
    trialPowerRHem{song} = squeeze(trialPower{song}(:,2,:));
    
    imagesc(-1500:1499,5:40,trialPowerRHem{song},[120 350]);  
    if song == 4; imagesc(-1500:1499,5:40,trialPowerRHem{song},[90 300]); end
    if i == length(songs); colorbar; end
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
    spectra = squeeze(trialPower{song}(:,2,:));     %right hemisphere only
    spectra = squeeze(mean(spectra(:,desyncPeriod),2)); %desync period only        
    h(song) = plot(5:40,spectra,colors{song});
end
title([subname ' amplitude spectra: t=' num2str(desyncPeriod(1)-1500) ':' num2str(desyncPeriod(end)-1500)]);
xlabel('Frequency (Hz)'); ylabel('Amplitude');
legend(h([1 2 3 5]),'AV only','robot+motor','motor','robot');


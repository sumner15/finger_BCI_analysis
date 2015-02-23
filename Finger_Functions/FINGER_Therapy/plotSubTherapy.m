function plotSubTherapy(username,subname)
% plotSub pluts the intra-subject results of the FINGER therapy study.  
%
% The function pulls the final analyzed EEG data from the subjects' 
% processed file (intraSubject.m gives trialPower) in your local directory 
% (please download from the Cramer's lab servers). 
%
% Input: subname (identifier) as string, e.g. 'LASF', 
%        username as string, e.g. 'Sumner'

conditions = {'PRE-song','PRE-speed','POST-song','POST-speed'};

%% plot settings
dbRange = 8; % +/- dB range

%% loading data
setPathTherapy(username,subname)
cd('raw data')
filename = celldir([subname '*trialPower.mat']);
filename{1} = filename{1}(1:end-4);
disp(['Loading ' filename{1} '...'])
load(filename{1});
disp('Done.')

%% plotting trial power (decibels)
freq = (8:13)-4; % (add 4)

scrsz = get(0,'ScreenSize'); scrsz = scrsz+50;
set(figure,'Position',round(scrsz/1.4))

for song = 1:length(trialPowerDB)
    subplot(2,2,song)
    
    plot(-1500:1499,squeeze(mean(trialPowerDB{song}(freq,2,:),1)))
        
    title([subname ' ' conditions{song} ': ' num2str(freq(1)+4) '-' num2str(freq(end)+4) 'Hz normalized power'],'FontSize',18);
    ylabel('dB','FontSize',16); xlabel('trial time (msec)','FontSize',16);
    axis([-1500 1500 -5 5]);
end

%% plotting trial power (raw)
set(figure,'Position',round(scrsz/1.4))

for song = 1:length(trialPower)
    subplot(2,2,song)
    
    plot(-1500:1499,squeeze(mean(trialPower{song}(freq,2,:),1)),'LineWidth',1.5)
        
    title([subname ' ' conditions{song} ': ' num2str(freq(1)+4) '-' num2str(freq(end)+4) 'Hz raw power'],'FontSize',18);
    ylabel('power','FontSize',16); xlabel('trial time (msec)','FontSize',16);
    axis([-1500 1500 0 500]);   
end

%% plotting freq x time map (decibel)
set(figure,'Position',round(scrsz/1.4))

for song = 1:length(trialPowerDB)
    subplot(2,2,song);
    trialPowerDBrHem{song} = squeeze(trialPowerDB{song}(:,2,:));
    
    imagesc(-1500:1499,5:40,trialPowerDBrHem{song},[-dbRange dbRange]); colorbar    
    set(gca,'YDir','normal')
    
    title([subname ' ' conditions{song} ': Normalized Power (dB)'],'FontSize',18);
    ylabel('frequency (Hz)','FontSize',16); xlabel('trial time (msec)','FontSize',16)    
end

%% plotting freq x time map (raw)
set(figure,'Position',round(scrsz/1.4))

for song = 1:length(trialPowerDB)    
    subplot(2,2,song);
    trialPowerRHem{song} = squeeze(trialPower{song}(:,2,:));
    
    imagesc(-1500:1499,5:40,trialPowerRHem{song});%,[120 350]);          
    colorbar;
    set(gca,'YDir','normal')
    
    title([subname ' ' conditions{song}],'FontSize',18);   
    ylabel('freq (Hz)','FontSize',16); xlabel('time (s)','FontSize',16);    
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
title([subname ' amplitude spectra: t=' num2str(desyncPeriod(1)-1500) ':' num2str(desyncPeriod(end)-1500)],'FontSize',18);
xlabel('Frequency (Hz)','FontSize',16); ylabel('Amplitude','FontSize',16);
legend(conditions{1},conditions{2},conditions{3},conditions{4});


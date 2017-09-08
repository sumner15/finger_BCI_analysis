function plotSubTherapy(username,subname)
% plotSub pluts the intra-subject results of the FINGER therapy study.  
%
% The function pulls the final analyzed EEG data from the subjects' 
% processed file (intraSubject.m gives trialPower) in your local directory 
% (please download from the Cramer's lab servers). 
%
% Input: subname (identifier) as string, e.g. 'LASF', 
%        username as string, e.g. 'Sumner'


%% loading data
setPathTherapy(username,subname)
filename = celldir([subname '*trialPower.mat']);
filename{1} = filename{1}(1:end-4);
disp(['Loading ' filename{1} '...'])
load(filename{1});
disp('Done.')

%% shared variabls
freq = 8:13 - 4; % +/- dB range of interest (subtract 4 for indexing)
scrsz = get(0,'ScreenSize'); scrsz = round(scrsz/1.4); scrsz = scrsz+50;
conditions = {'PRE-song','PRE-speed','POST-song','POST-speed'};
nSongs = length(trialPowerDB);
t = -1500:1499;
f = 5:40;

%% plotting trial power (decibels)
set(figure,'Position',scrsz)

for song = 1:nSongs
    subplot(2,2,song)
    
    powerAtFreq = squeeze(mean(trialPowerDB{song}(freq,:),1));
    plot(t,powerAtFreq);
        
    title([subname ' ' conditions{song} ': ' num2str(freq(1)+4) '-' num2str(freq(end)+4) 'Hz normalized power'],'FontSize',18);
    ylabel('dB','FontSize',16); xlabel('trial time (msec)','FontSize',16);    
    xlim([-1500 1500]);
end

%% plotting trial power (raw)
set(figure,'Position',scrsz)

for song = 1:nSongs
    subplot(2,2,song)
    
    powerAtFreq = squeeze(mean(trialPower{song}(freq,:),1));
    plot(t,powerAtFreq,'LineWidth',1.5);
        
    title([subname ' ' conditions{song} ': ' num2str(freq(1)+4) '-' num2str(freq(end)+4) 'Hz raw power'],'FontSize',18);
    ylabel('power','FontSize',16); xlabel('trial time (msec)','FontSize',16);
    axis([-1500 1500 0 500]);   
end

%% plotting freq x time map (decibel)
set(figure,'Position',scrsz)

for song = 1:nSongs
    subplot(2,2,song);    
    
    imagesc(t,f,trialPowerDB{song}) %,[-dbRange dbRange]); 
    colorbar;
    set(gca,'YDir','normal')
    
    title([subname ' ' conditions{song} ': Normalized Power (dB)'],'FontSize',18);
    ylabel('frequency (Hz)','FontSize',16); xlabel('trial time (msec)','FontSize',16)    
end

%% plotting freq x time map (raw)
set(figure,'Position',scrsz)

for song = 1:nSongs    
    subplot(2,2,song);    
    
    imagesc(t,f,trialPower{song}); %,[120 350]);          
    colorbar;
    set(gca,'YDir','normal')
    
    title([subname ' ' conditions{song}],'FontSize',18);   
    ylabel('freq (Hz)','FontSize',16); xlabel('time (s)','FontSize',16);    
end

%% plotting example spectra 
set(figure,'Position',scrsz)
hold on
colors = {'r','m','b','g'};
for song = 1:nSongs            
    spectra = squeeze(mean(trialPower{song},2)); %desync period only        
    h(song) = plot(f,spectra,colors{song});
end
title([subname ' amplitude spectra'],'FontSize',18);
xlabel('Frequency (Hz)','FontSize',16); ylabel('Amplitude','FontSize',16);
legend(conditions{1},conditions{2},conditions{3},conditions{4});


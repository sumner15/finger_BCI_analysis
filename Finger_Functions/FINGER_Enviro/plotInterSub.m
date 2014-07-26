clc;

subjects = {{'BECC'},{'NAVA'},{'TRAT'},{'POTA'},{'TRAV'},{'NAZM'},...
            {'TRAD'},{'DIAJ'},{'GUIR'},{'DIMC'},{'LURI'},{'TRUS'}};
%subjects = {{'TRAT'}};
conditions = {'AV-only','robot+motor','motor only','AV-only','robot only','AV-only'};

if (~exist('username','var'))
   username = input('Username: ','s'); 
end

disp('-----------------------------');
disp('   Intersubject Plotting ');
disp('-----------------------------');
    
%% loading data
for currentSub = 1:length(subjects)
    subname = subjects{currentSub};   
    subname = subname{1};     
    
    clear trialPower trialPowerDB
    setPathEnviro(username,subname)
    filename = celldir([subname '*trialPower.mat']);
    filename{1} = filename{1}(1:end-4);
    disp(['Loading ' filename{1} '...'])    
    eval([subname ' = load(filename{1});']);
    disp('Done.')        
end

%% computing mean results
for currentSub = 1:length(subjects)
    subname = subjects(currentSub); subname = char(subname{1});    
    if currentSub == 1
        MEAN.trialPowerDB = eval([subname '.trialPowerDB;']);
    else
        for song = 1:6
            MEAN.trialPowerDB{song} = eval(['MEAN.trialPowerDB{song} + ' subname '.trialPowerDB{song};']);
        end
    end
end
for song = 1:6
    MEAN.trialPowerDB{song} = MEAN.trialPowerDB{song}./length(subjects);
end

%% plotting trial power (decibels)
freq = 4:9; % 8Hz - 13Hz 
scrsz = get(0,'ScreenSize'); 
set(figure,'Position',scrsz)

% plotting DB power for each song (subplots)
for song = 1:6
    subplot(2,3,song); hold on
    title([conditions{song} ': Inter-Subject Mean Mu (8-13Hz) normalized power'])
    ylabel('dB'); xlabel('trial time (msec)');
    axis([-1500 1500 -20 20]);
    
    % plotting DB power for each subject (new line within subplots)
    for currentSub = 1:length(subjects)    
        subname = subjects(currentSub); subname = char(subname{1});        
        trialPowerDB = eval([subname '.trialPowerDB;']);
        plot(-1500:1499,squeeze(mean(trialPowerDB{song}(freq,2,:),1)))        
    end    
    % plotting mean DB power across all subjects
    plot(-1500:1499,squeeze(mean(MEAN.trialPowerDB{song}(freq,2,:),1)),'r','LineWidth',3)        
end

%% plotting trial power freq x time maps (decibels)
set(figure,'Position',scrsz)
% plotting DB power for each song (subplots)
for song = 1:6
    subplot(2,3,song); hold on
    title([conditions{song} ': Inter-Subject Mean Normalized power'])
    ylabel('frequency (Hz)'); xlabel('trial time (msec)');    
    
    trialPowerDBrHem{song} = squeeze(MEAN.trialPowerDB{song}(:,2,:));
    
    imagesc(-1500:1499,5:40,trialPowerDBrHem{song},[-6 6]); colorbar   
    axis([-1500 1500 5 40]);
    set(gca,'YDir','normal')
end


%%
clear trialPowerDB trialPower currentSub scrsz song subname 
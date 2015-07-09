function plotInterSubTherapy(subjects)
% plotInterSub pluts the inter-subject results of the FINGER therapy study.  
%
% Optional input: subjects, a cell array of subject identifier strings
% e.g. a subset of...
% subjects = {'AGUJ','ARRS','BROR','CHIB','CORJ','CROD','ESCH','FLOA',...
%             'GONA','HAAN','JOHG','KILB','LAMK','LEUW','LOUW','MALJ',...
%             'MCCL','MILS','NGUT','POOJ','PRIJ','RITJ','SARS','VANT',...
%             'WHIL','WILJ','WRIJ','YAMK'};            
% 
% If a subject list is not given, all subjects are processed.
% the function pulls the final analyzed EEG data from the subjects' 
% processed files (intraSubject.m gives trialPower) in your local directory 
% (please download from the Cramer's lab servers). 

%% begin
disp('-----------------------------');
disp('   Intersubject Plotting ');
disp('-----------------------------');
scrsz = floor((get(0,'ScreenSize')+50)/1.4);
close all

%% setting subject list and common vars
if ~exist('subjects','var')
    subjects = {'AGUJ','ARRS','BROR','CHIB','CORJ','CROD','ESCH','FLOA',...
            'GONA','HAAN','JOHG','KILB','LAMK','LEUW','LOUW','MALJ',...
            'MCCL','MILS','NGUT','POOJ','PRIJ','RITJ','SARS','VANT',...
            'WHIL','WILJ','WRIJ','YAMK'};            
    disp('no subject list passed... assuming all subjects')
end
nSubs = length(subjects);

% experimental conditions
conditions = {'PRE-song','PRE-speed','POST-song','POST-speed'};
nSongs = length(conditions);
time = -1500:1499;
freqs = 5:40;
nFreqs = length(freqs);

% username check
if (~exist('username','var'))
   username = input('Username: ','s'); 
end
    
%% loading data
currentSub = 1;
while currentSub <= nSubs
    try
        subname = subjects{currentSub};       
        clear trialPower trialPowerDB
        setPathTherapy(username,subname)
        filename = celldir([subname '*trialPower.mat']);
        filename{1} = filename{1}(1:end-4);
        disp(['Loading ' filename{1} '...'])    
        eval([subname ' = load(filename{1});']);        
        currentSub = currentSub+1;
    catch me
        disp(['Could not load data for ' subname]);
        subjects(:,currentSub) = [];
        currentSub = currentSub-1;
        nSubs = nSubs-1;
    end
end

%% creating high/low group indices
% loading therapy data tables
setPathTherapy(username)
load('therapyData.mat');
tableSubs = therapyTextData(:,1);       % column of subject id's
groupIndex = ismember(therapyTextData(1,:),'group'); %finds group column
tableGroup = therapyData(:,groupIndex); % stores group numbers (2s&3s)

lowSubs = []; highSubs = [];          % array of indices for hi/lo subs
for currentSub = 1:nSubs
    subname = subjects{currentSub};      
    tableSubInd = ismember(tableSubs,subname); %index of sub in table
    group = tableGroup(tableSubInd); %current sub's group level
    if group == 2
        lowSubs = [lowSubs currentSub];
    elseif group ==3
        highSubs = [highSubs currentSub];
    else 
        error('group level is not properly defined');
    end
end

%% computing mean results
for currentSub = 1:nSubs
    subname = subjects{currentSub};
    if currentSub == 1
        MEAN.trialPowerDB = eval([subname '.trialPowerDB;']);
    else
        for song = 1:nSongs
            MEAN.trialPowerDB{song} = eval(['MEAN.trialPowerDB{song} + ' subname '.trialPowerDB{song};']);
        end
    end
end
for song = 1:nSongs
    MEAN.trialPowerDB{song} = MEAN.trialPowerDB{song}./nSubs;
end

%% creating a nice Power array in 4D: Power(song,subject,freq,time)
%initializing the power array
power= zeros(nSongs,nSubs+3,nFreqs,length(time));

for currentSub = 1:nSubs %for each subject
    subname = subjects{currentSub};    
    for song = 1:nSongs %for each song                
        power(song,currentSub,:,:) = eval([subname '.trialPowerDB{song};']);    
    end
end
% computing mean power profiles in 3D: groupPower(song,freq,time)
lowGroupPower = squeeze(mean(power(:,lowSubs,:,:),2));
highGroupPower = squeeze(mean(power(:,highSubs,:,:),2));
allGroupPower = squeeze(mean(power,2));

%% plotting trial power (decibels)
freqInterest = 12:25-4; 
% plotting DB power for each song (subplots)
set(figure,'Position',scrsz)
hsuptitle = suptitle([num2str(freqInterest(1)+4) '-' num2str(freqInterest(end)+4) ' power (dB)']);
set(hsuptitle,'FontSize',25,'FontWeight','normal')
for song = 1:nSongs
    subplot(2,2,song); hold on    
    title(conditions{song},'FontSize',20)
    if song == 1 || song == 2; xlabel('time (ms)','FontSize',16); end
    if song == 2 || song == 4; ylabel('dB','FontSize',16); end
    %axis([-1500 1500 -10 13]);     
    
    % plotting DB power for each subject (new line within subplots)    
    lowPower = squeeze(mean(power(song,lowSubs,freqInterest,:),3));    
    highPower = squeeze(mean(power(song,highSubs,freqInterest,:),3));
    hLine_low = plot(time,lowPower,'b'); 
    hLine_high = plot(time,highPower,'r');   
    legend([hLine_low(1) hLine_high(1)],'low group','high group');
    % plotting mean DB power across all subjects
    lowPower = squeeze(mean(lowGroupPower(song,:,:),2));
    highPower = squeeze(mean(highGroupPower(song,:,:),2));
    plot(time,lowPower,'b','LineWidth',5); 
    plot(time,highPower,'r','LineWidth',5);
    
    axis([-1350 1350 -2 2]);
    set(gca,'FontSize',14);          
end

%% plotting trial power freq x time maps (decibels)
% plotting DB power for each song (subplots)
set(figure,'Position',scrsz)
% suptitle('Inter-Subject time-freq power (dB normalized)')
lim = 1; %dB
for song = 1:nSongs
    %low group
    subplot(2,4,song); hold on
    title([conditions{song} ' low group'],'FontSize',20)
    xlabel('trial time (msec)','FontSize',16);    
    ylabel('frequency (Hz)','FontSize',16);
        
    imagesc(-1500:1499,freqs,squeeze(lowGroupPower(song,:,:)),[-lim lim]); 
    axis([-1350 1350 5 40]);
    set(gca,'YDir','normal')
    
    % high group
    subplot(2,4,song+nSongs); hold on
    title([conditions{song} ' high group'],'FontSize',20)
    xlabel('trial time (msec)','FontSize',16);    
    ylabel('frequency (Hz)','FontSize',16);
    
    imagesc(-1500:1499,freqs,squeeze(highGroupPower(song,:,:)),[-lim lim]); 
    axis([-1350 1350 5 40]);
    set(gca,'YDir','normal')
end

%% plotting trial power freq x time maps (decibels) DIFFERENCE
% plotting DB power for each song (subplots)
set(figure,'Position',scrsz)
hsuptitle = suptitle('Difference in dB power, group level');
set(hsuptitle,'FontSize',20)
for song = 1:nSongs
    %low group - high group
    subplot(2,2,song); hold on
    title([conditions{song}],'FontSize',20)
    xlabel('trial time (msec)','FontSize',16);    
    ylabel('frequency (Hz)','FontSize',16);
        
    difference = abs(squeeze(lowGroupPower(song,:,:))-squeeze(highGroupPower(song,:,:)));
    imagesc(-1500:1499,freqs,difference); colorbar
    axis([-1350 1350 5 40]);
    set(gca,'YDir','normal')
end

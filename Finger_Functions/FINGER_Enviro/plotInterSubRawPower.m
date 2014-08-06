 subjects = {{'BECC'},{'NAVA'},{'TRAT'},{'POTA'},{'TRAV'},{'NAZM'},...
             {'TRAD'},{'DIAJ'},{'GUIR'},{'DIMC'},{'LURI'},{'TRUS'}};
%subjects = {{'DIAJ'},{'DIMC'},{'GUIR'},{'NAZM'},{'POTA'},{'TRAD'},{'TRAT'}};
nSubs = length(subjects);

conditions = {'AV-only','robot+motor','motor only','AV-only','robot only','AV-only'};
time = -1500:1499;

if (~exist('username','var'))
   username = input('Username: ','s'); 
end

disp('-----------------------------');
disp('   Intersubject Plotting ');
disp('-----------------------------');
    
%% loading data
for currentSub = 1:nSubs
    subname = subjects{currentSub};   
    subname = subname{1};     
    
    clear trialPower trialPowerDB
    setPathEnviro(username,subname)
    filename = celldir([subname '*trialPower.mat']);
    filename{1} = filename{1}(1:end-4);
    disp(['Loading ' filename{1} '...'])    
    eval([subname ' = load(filename{1});']);
    eval([subname '.trialPowerDB = ' subname '.trialPower;']);
    disp('Done.')        
end
cd .. ; load('robPos.mat'); 

%% computing mean results
for currentSub = 1:nSubs
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
    MEAN.trialPowerDB{song} = MEAN.trialPowerDB{song}./nSubs;
end

%% averaging across electrodes/frequencies and re-storing as muPower
freq = 4:9; % 8Hz - 13Hz 
muPower = cell(1,6);
for song = 1:6; muPower{song} = zeros(nSubs+1,length(time)); end

for currentSub = 1:nSubs %for each subject
    subname = subjects{currentSub}; subname = char(subname{1});    
    trialPowerDB = eval([subname '.trialPowerDB;']);    
    for song = 1:6 %for each song        
        % fill in the subjects mean power profile 
        muPower{song}(currentSub,:) = squeeze(mean(trialPowerDB{song}(freq,2,:),1));
    end
end
% computing mean power profile 
for song = 1:6
    muPower{song}(nSubs+1,:) = mean(muPower{song}(1:nSubs,:),1);
end

%% computing confidence intervals and stats
disp('Computing stats...')
mu = NaN(1,length(time)); sig = mu; conf = sig; %initializing
for sample = 1:length(time)
    % calculating the mean, std, and ci at each sample time
    [mu(sample) sig(sample) conf(sample)] = ci(muPower{4}(1:nSubs,sample));
end
disp('Done.')

disp('Determining significance...')
sigInds = cell(6,10);
for song = 1:6
    nArea = 1; %number of significant areas
    for sample = 1:length(time)         %read through each sample pt
        %if significant...
        if muPower{song}(nSubs+1,sample)>(mu(sample)+conf(sample)) || ...
           muPower{song}(nSubs+1,sample)<(mu(sample)-conf(sample))
            sigInds{song,nArea} = [sigInds{song,nArea} sample];
        else  %if not sig, but last sample was, we are in a new area                                      
            if ~isempty(sigInds{song,nArea})
                nArea = nArea+1;
            end %done adding new area
        end %if significant
    end %for each sample
end %for each song
disp('Done.')

%% plotting trial power (decibels)
scrsz = get(0,'ScreenSize'); 
set(figure,'Position',scrsz)

% plotting DB power for each song (subplots)
for song = 1:6
    subplot(2,3,song); hold on
    title([conditions{song} ': Inter-Subject Mean Mu (8-13Hz) power'])
    ylabel('power'); xlabel('trial time (msec)');
    axis([-1500 1500 0 4000]);     
    
%     %shading significance
%     for nArea = 1:size(sigInds,2)
%        if ~isempty(sigInds{song,nArea})
%            harea = area(sigInds{song,nArea}-1500, ...
%                 20*ones(size(sigInds{song,nArea})),'LineStyle','none');
%            set(harea,'FaceColor','r'); alpha(0.15);
%            harea = area(sigInds{song,nArea}-1500, ...
%                -20*ones(size(sigInds{song,nArea})),'LineStyle','none');
%            set(harea,'FaceColor','r'); alpha(0.15);
%        end
%     end
    
    % plotting DB power for each subject (new line within subplots)
    plot(time,muPower{song}(1:nSubs,:),'b')
    % plotting mean DB power across all subjects
    plot(time,muPower{song}(nSubs+1,:),'r','LineWidth',3)   
    
    % plotting robot trajectory when appropriate
    if song==2 || song==3 || song==5
        robot = plot(time,-1500*robPos(song,:)+2000,'g','LineWidth',1.5);        
        legend(robot,'robot trajectory','Location','Best')
    end
end

%% plotting trial power freq x time maps (decibels)
set(figure,'Position',scrsz)
% plotting DB power for each song (subplots)
for song = 1:6
    subplot(2,3,song); hold on
    title([conditions{song} ': Inter-Subject Mean power'])
    ylabel('frequency (Hz)'); xlabel('trial time (msec)');    
    
    trialPowerDBrHem{song} = squeeze(MEAN.trialPowerDB{song}(:,2,:));
    
    imagesc(-1500:1499,5:40,trialPowerDBrHem{song},[300 1800]); colorbar   
    axis([-1500 1500 5 40]);
    set(gca,'YDir','normal')
end


%%
clear trialPowerDB trialPower currentSub scrsz song subname trialPowerDBrHem
clear robot filename temp rest
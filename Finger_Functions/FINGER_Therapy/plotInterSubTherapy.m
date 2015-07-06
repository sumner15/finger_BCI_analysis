% plotInterSub pluts the inter-subject results of the FINGER therapy study.  
%
% The function pulls the final analyzed EEG data from the subjects' 
% processed files (intraSubject.m gives trialPower) in your local directory 
% (please download from the Cramer's lab servers). 

subjects = {'AGUJ','ARRS','BROR','CHIB','CORJ','CROD'};

nSubs = length(subjects);

conditions = {'PRE-song','PRE-speed','POST-song','POST-speed'};
nSongs = length(conditions);
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
    clear trialPower trialPowerDB
    setPathTherapy(username,subname)
    filename = celldir([subname '*trialPower.mat']);
    filename{1} = filename{1}(1:end-4);
    disp(['Loading ' filename{1} '...'])    
    eval([subname ' = load(filename{1});']);
    disp('Done.')        
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

%% averaging across electrodes/frequencies and re-storing as muPower
freq = 8:13-4; % 8Hz - 13Hz 
muPower = cell(1,nSongs);
for song = 1:nSongs
    muPower{song} = zeros(nSubs+1,length(time));
end

for currentSub = 1:nSubs %for each subject
    subname = subjects{currentSub};
    trialPowerDB = eval([subname '.trialPowerDB;']);    
    for song = 1:nSongs %for each song        
        % fill in the subjects mean power profile 
        muPower{song}(currentSub,:) = squeeze(mean(trialPowerDB{song}(freq,:),1));
    end
end
% computing mean power profile 
for song = 1:nSongs
    muPower{song}(nSubs+1,:) = mean(muPower{song}(1:nSubs,:),1);
end

%% computing confidence intervals and stats
% disp('Computing stats...')
% mu = NaN(1,length(time)); sig = mu; conf = sig; %initializing
% for sample = 1:length(time)
%     % calculating the mean, std, and ci at each sample time
%     [mu(sample) sig(sample) conf(sample)] = ci(muPower{4}(1:nSubs,sample));
% end
% disp('Done.')
% 
% disp('Determining significance...')
% sigInds = cell(nSongs,10);
% for song = 1:nSongs
%     nArea = 1; %number of significant areas
%     for sample = 1:length(time)         %read through each sample pt
%         %if significant...
%         if muPower{song}(nSubs+1,sample)>(mu(sample)+conf(sample)) || ...
%            muPower{song}(nSubs+1,sample)<(mu(sample)-conf(sample))
%             sigInds{song,nArea} = [sigInds{song,nArea} sample];
%         else  %if not sig, but last sample was, we are in a new area                                      
%             if ~isempty(sigInds{song,nArea})
%                 nArea = nArea+1;
%             end %done adding new area
%         end %if significant
%     end %for each sample
% end %for each song
% disp('Done.')

%% plotting trial power (decibels)
scrsz = floor((get(0,'ScreenSize')+50)/1.4);
set(figure,'Position',scrsz)

% plotting DB power for each song (subplots)
suptitle('Inter-Subject Mu power (dB normalized)')
for song = 1:nSongs
    subplot(2,2,song); hold on    
    title(conditions{song},'FontSize',20)
    if song == 1 || song == 2; xlabel('time (ms)','FontSize',16); end
    if song == 2 || song == 4; ylabel('dB','FontSize',16); end
    %axis([-1500 1500 -10 13]);     
    
%     %shading significance
%     for nArea = 1:size(sigInds,2)
%        if ~isempty(sigInds{song,nArea})
%            harea = area(sigInds{song,nArea}-1500, ...
%                 20*ones(size(sigInds{song,nArea})),'LineStyle','none');
%            set(harea,'FaceColor','r'); alpha(0.10);
%            harea = area(sigInds{song,nArea}-1500, ...
%                -20*ones(size(sigInds{song,nArea})),'LineStyle','none');
%            set(harea,'FaceColor','r'); alpha(0.10);
%        end
%     end
    
    % plotting DB power for each subject (new line within subplots)
    plot(time,muPower{song}(1:nSubs,:),'b'); set(gca,'FontSize',14);
    % plotting mean DB power across all subjects
    plot(time,muPower{song}(nSubs+1,:),'r','LineWidth',5); set(gca,'FontSize',14);
    
end

%% plotting trial power freq x time maps (decibels)
set(figure,'Position',scrsz)
% plotting DB power for each song (subplots)
suptitle('Inter-Subject time-freq power (dB normalized)')
for song = 1:nSongs
    subplot(2,2,song); hold on
    title(conditions{song},'FontSize',20)    
    ylabel('frequency (Hz)','FontSize',16); xlabel('trial time (msec)','FontSize',16);    
        
    imagesc(-1500:1499,5:40,MEAN.trialPowerDB{song});%,[-3 3]); 
    colorbar   
    axis([-1500 1500 5 40]);
    set(gca,'YDir','normal')
end


%% computing delta-ERD, delta-ERS (dB)::both songs, all subjects
% % Preparing maximum desync and rebound values for export to ANOVA
% maxDesync = NaN(nSubs,nSongs); maxRebound = NaN(nSubs,nSongs);
% desInds = 1:1500; rebInds = 1000:3000;
% for song = 1:nSongs
%     maxDesync(:,song) = min(muPower{song}(1:nSubs,desInds),[],2);
%     maxRebound(:,song)= max(muPower{song}(1:nSubs,rebInds),[],2);
% end
% 
% %%
% clear trialPowerDB trialPower currentSub scrsz song subname trialPowerDBrHem
% clear robot filename temp rest
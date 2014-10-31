subjects = {{'BECC'},{'NAVA'},{'TRAT'},{'POTA'},{'TRAV'},{'NAZM'},...
            {'TRAD'},{'DIAJ'},{'GUIR'},{'DIMC'},{'LURI'},{'TRUS'}};

% subjects = {{'BECC'},{'NAVA'},{'TRAV'},{'DIAJ'},{'DIMC'},...
%             {'LURI'},{'TRUS'}};
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
titles = ['A' 'A' 'B' 'C' 'D' 'E' 'F'];
for song = 2:5
    subplot(2,2,song-1); hold on
    %title([conditions{song} ': Inter-Subject Mean Mu (8-13Hz) normalized power'])
    %title(titles(song),'FontSize',20);
    if song == 2 || song == 3; xlabel('time (ms)','FontSize',16); end
    if song == 3 || song == 5; ylabel('dB','FontSize',16); end
    axis([-1500 1500 -10 13]);     
    
    %shading significance
    for nArea = 1:size(sigInds,2)
       if ~isempty(sigInds{song,nArea})
           harea = area(sigInds{song,nArea}-1500, ...
                20*ones(size(sigInds{song,nArea})),'LineStyle','none');
           set(harea,'FaceColor','r'); alpha(0.10);
           harea = area(sigInds{song,nArea}-1500, ...
               -20*ones(size(sigInds{song,nArea})),'LineStyle','none');
           set(harea,'FaceColor','r'); alpha(0.10);
       end
    end
    
    % plotting DB power for each subject (new line within subplots)
    plot(time,muPower{song}(1:nSubs,:),'b'); set(gca,'FontSize',14);
    % plotting mean DB power across all subjects
    plot(time,muPower{song}(nSubs+1,:),'r','LineWidth',5); set(gca,'FontSize',14);
    
    % plotting robot trajectory when appropriate
    if song==2 || song==3 || song==5
        robot = plot(time,-7*robPos(song,:),'--g','LineWidth',2);        
        %legend(robot,'robot trajectory','Location','Best','FontSize',12)
    end
end

%% plotting trial power freq x time maps (decibels)
set(figure,'Position',scrsz)
% plotting DB power for each song (subplots)
for song = 2:5
    subplot(2,2,song-1); hold on
    %title([conditions{song} ': Inter-Subject Mean Normalized power'])
    title(titles(song),'FontSize',20);
    ylabel('frequency (Hz)','FontSize',16); xlabel('trial time (msec)','FontSize',16);    
    
    trialPowerDBrHem{song} = squeeze(MEAN.trialPowerDB{song}(:,2,:));
    
    imagesc(-1500:1499,5:40,trialPowerDBrHem{song},[-1.5 1]); colorbar   
    axis([-1500 1500 5 40]);
    set(gca,'YDir','normal')
end

%% Preparing maximum desync and rebound values for export to ANOVA
maxDesync = NaN(nSubs,6); maxRebound = NaN(nSubs,6);
desInds = 1:1500; rebInds = 1000:3000;
for song = 1:6
    maxDesync(:,song) = min(muPower{song}(1:nSubs,desInds),[],2);
    maxRebound(:,song)= max(muPower{song}(1:nSubs,rebInds),[],2);
end
maxDesyncANOVA = NaN(nSubs*2,2); maxReboundANOVA = NaN(nSubs*2,2);
for currentSub = 1:nSubs
    row = currentSub*2-1;
    maxDesyncANOVA(row:row+1,:) = ...
        [[maxDesync(currentSub,4) maxDesync(currentSub,5)];...
         [maxDesync(currentSub,3) maxDesync(currentSub,2)]];
    maxReboundANOVA(row:row+1,:) = ...
        [[maxRebound(currentSub,4) maxRebound(currentSub,5)];...
         [maxRebound(currentSub,3) maxRebound(currentSub,2)]];
end
% computing ANOVA across subjects 
pDesync  = anova2(maxDesyncANOVA,nSubs,'on');  title('Max ERD ANOVA')
pRebound = anova2(maxReboundANOVA,nSubs,'on'); title('Max Rebound ANOVA')
clear desInds rebInds row;

%% Computing intra/interSub ANOVA results (note columns=robot & rows=motor)
ANOVA = NaN(nSubs,4);
for currentSub = 1:nSubs
    row = currentSub*2-1;
    pDesync =  anova2(maxDesyncANOVA(row:row+1,:),1,'off');
    pRebound = anova2(maxReboundANOVA(row:row+1,:),1,'off');
    ANOVA(currentSub,1:2) = pDesync;
    ANOVA(currentSub,3:4) = pRebound;   
end
clear pDesync pRebound

%% printing intraSub ANOVA results to variable editor for easy access
ANOVAcell = zeros(size(ANOVA,1)+2,size(ANOVA,2)+1); 
ANOVAcell(3:end,2:end) = ANOVA;
ANOVAcell = num2cell(ANOVAcell);
ANOVAcell{1,2} = 'ERD'; ANOVAcell{1,4} = 'Rebound';
ANOVAcell{2,2} = 'robot'; ANOVAcell{2,3} = 'motor'; 
ANOVAcell{2,4} = 'robot'; ANOVAcell{2,5} = 'motor'; 
for currentSub = 1:nSubs
    ANOVAcell{currentSub+2,1} = strcat('Subject ',num2str(currentSub));
end
open('ANOVAcell');

%%
clear trialPowerDB trialPower currentSub scrsz song subname trialPowerDBrHem
clear robot filename temp rest
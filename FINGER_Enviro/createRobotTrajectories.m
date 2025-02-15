subjects = {'BECC','NAVA','TRAT','POTA','TRAV','NAVM',...
            'TRAD','DIAJ','GUIR','DIMC','LURI','TRUS'};  

if (~exist('username','var'))
   username = input('Username: ','s'); 
end
setPathEnviro(username);
load('note_timing_Blackbird') %creates var Blackbird   <nNotes x 1 double>
cd robotData

%% storing trajectory vectors in a subject x song cell array
allTraj = cell(length(subjects),6); tic
for sub = 1:length(subjects)
    subname = char(subjects{sub});
    disp(['-------- ' subname ' --------']);
    subFileNames = celldir(['positions_' subname '*.txt']);
    for song = 1:6
        fprintf('- %i',song);        
        importRobotData(subFileNames{song});
        % storing trajectory vectors in a subject x song cell array
        allTraj{sub,song} = (data(:,1)+data(:,3))';
    end
    fprintf('\n');    
end
clear subname subFileNames data textdata

%% re-ordering by run type
disp('reordering data'); 
tempAllTraj = allTraj;
clear allTraj; %allTraj = cell(length(subjects),6);
% allTraj = sub x song x sample
allTraj = NaN(length(subjects),6,200000);

cd ..; load runOrder.mat   %identifying run order       
for sub = 1:length(subjects)    
    for song = 1:6
        allTraj(sub,runOrder(sub,song),:) = tempAllTraj{sub,song}(1:200000);
    end
end
songTraj = squeeze(mean(allTraj,1));
disp('Done.')

%% segmenting average across subjects
% finding first robot movement to readjust note timing as necessary
firstRobotMoveInd = find(songTraj(5,:)>0.05,1);
[peak peakInd] = max(songTraj(5,firstRobotMoveInd:firstRobotMoveInd+1000));
firstRobotMoveInd = firstRobotMoveInd+peakInd;
blackBird = blackBird-blackBird(1)+firstRobotMoveInd;
blackBird = round(blackBird);

% segmenting into songTrialTraj (62 trial x 6 song x 3000sample)
songTrialTraj = NaN(length(blackBird),6,3000);
for note = 1:length(blackBird)
    noteInds = (blackBird(note)-1500):(blackBird(note)+1499);
    songTrialTraj(note,:,:) = songTraj(:,noteInds);
end

%% creating and cleaning final robot trajectories 
robPos = squeeze(mean(songTrialTraj,1));
robPos = robPos- repmat(min(robPos,[],2),1,3000);    %subtracting DC offset
tempAV = robPos([1 4 6],:);
robPos = robPos./repmat(max(robPos,[],2),1,3000);    %scaling to 1
robPos(1,:) = tempAV(1,:); robPos(4,:) = tempAV(2,:); robPos(6,:) = tempAV(3,:);

%% plotting average trajectory for each condition
figure(1); suptitle('Averaged trajectory by song type')
for song = 1:6
    subplot(2,3,song)
    plot(songTraj(song,:))
end
figure(2); suptitle('All Trajectories as Pos v. Time for 12 subjects, 6 songs')
for song = 1:6
    for sub = 1:12
        currPlot = (song-1)*12+sub;
        subplot(6,12,currPlot)
        plot(squeeze(allTraj(sub,song,:)));
    end
end
%%
figure(3); %suptitle('Average robot trajectory for each song across all subjects/notes')
colors = {'y','r','g','y','b','y',};
time = -1.5:.001:1.499;
for song = 2:5
    subplot(2,2,song-1)    
    plot(time,-robPos(song,:),'LineWidth',3)
    axis([time(1) time(end) -1.2 .2])
    xlabel('time (s)','FontSize',24); 
end
%legend('AV only','robot+motor','motor',' ','robot')

%% plotting robot force profiles
figure(4); suptitle('Robot force profiles (all subjects)');
for sub = 1:length(subjects)
    subname = char(subjects{sub});    
    subFileNames = celldir(['positions_' subname '*.txt']);
    % AV condition force-time vector 
    condNo = find(runOrder(sub,:)==1);
    importRobotData(subFileNames{condNo});
    e1 = data(:,1); e2 = data(:,3);   
    AV = data(:,7).*e1+data(:,8).*e1+data(:,9).*e2+data(:,10).*e2;  
    % robot only condition force-time vector    
    condNo = find(runOrder(sub,:)==5);
    importRobotData(subFileNames{condNo});
    e1 = data(:,5)-data(:,1); e2 = data(:,6)-data(:,3);
    robot = data(:,7).*e1+data(:,8).*e1; %+data(:,9).*e2+data(:,10).*e2;
    % robot+motor condition force-time vector
    condNo = find(runOrder(sub,:)==2);
    importRobotData(subFileNames{condNo});
    e1 = data(:,5)-data(:,1); e2 = data(:,6)-data(:,3);
    robot_motor = data(:,7).*e1+data(:,8).*e1; %+data(:,9).*e2+data(:,10).*e2;
    
    subplot(4,3,sub); hold on;  
    plot(AV,'g','LineWidth',2); plot(robot); plot(robot_motor,'r');
    if sub==1; legend('AV','robot only','robot+motor'); end
    axis([0 150000 -1 1]);
end

clear subname subFileNames e1 e2 AV robot robot_motor 

%% save and send success email!
save('robPos','robPos');
toc; sendEmail;

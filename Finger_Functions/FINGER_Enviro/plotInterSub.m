clc;

% subjects = {{'BECC'},{'TRUS'},{'DIMC'},{'GUIR'},{'LURI'},{'NAVA'},...
%             {'NAZM'},{'TRAT'},{'TRAV'},{'POTA'},{'DIAJ'},{'TRAD'}};
subjects = {{'TRAT'}};

if (~exist('username','var'))
   username = input('Username: ','s'); 
end

for currentSub = 1:length(subjects)
    subname = subjects{currentSub};   
    subname = subname{1};
    
    disp('-----------------------------');
    disp('   Intersubject Plotting ');
    disp('-----------------------------');
    
    %% loading data
    clear trialPower trialPowerDB
    setPathEnviro(username,subname)
    filename = celldir([subname '*trialPower.mat']);
    filename{1} = filename{1}(1:end-4);
    disp(['Loading ' filename{1} '...'])
    load(filename{1});
    disp('Done.')
    
    
    %% plotting trial power (decibels)
    freq = 4:9; % 8Hz - 13Hz 
    
    if currentSub==1
        scrsz = get(0,'ScreenSize'); 
        set(figure,'Position',scrsz)
        hold on
    end

    for song = 1:length(trialPowerDB)
        subplot(2,3,song)

        plot(-1500:1499,squeeze(mean(trialPowerDB{song}(freq,2,:),1)))

        title('Mu (8-13Hz) normalized power')
        ylabel('dB'); xlabel('trial time (msec)');
        axis([-1500 1500 -10 10]);
    end
end
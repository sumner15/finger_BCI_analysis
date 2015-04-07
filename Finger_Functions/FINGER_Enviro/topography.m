% plots topography measures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Movement Anticipation and EEG: Implications for BCI-robot therapy
%  subjects = {{'BECC'},{'TRUS'},{'DIMC'},{'GUIR'},{'LURI'},{'NAVA'},...
%              {'NAZM'},{'TRAT'},{'TRAV'},{'POTA'},{'DIAJ'},{'TRAD'}};
 subjects = {{'BECC'},{'TRUS'},{'DIMC'}};

nSubs = length(subjects);       % number of subjects analyzed 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (~exist('username','var'))
   username = input('Username: ','s'); 
end    

%% options %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for condition = 2                % ONLY CONDITION USED! 
%     for curFreq = 5:5:30
freq = [15 10 25 14 6 18 22 22 18 30 30 10]; 
% freq = zeros(1,nSubs)+curFreq;       % mu rhythm 
N = 200;                        % Sample length 
baseInd = 1:2;                  % baseline period (in int multiples of N 
                                % ms) for dB change calculation

fs = 1000;                      % sampling frequency (Hz)
% Hz (desired center freq used for topography)
fVec = linspace(0,fs/2,N/2+1);  % frequency vector resolved by fft
nWins = floor(fs*3/N);          % number of windows per epoch (3 sec)
freqInd = NaN(1,nSubs);         % initializing frequency index vector
freqUsed = NaN(1,nSubs);        % initializing frequency used vector

%% loading run order data
setPathEnviro(username);
load runOrder.mat   %identifying run order
subRuns  = {'BECC','NAVA','TRAT','POTA','TRAV','NAZM',...
            'TRAD','DIAJ','GUIR','DIMC','LURI','TRUS'};       
condStr = {'AV','motor','motor+robot','AV','robot','AV'};

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% processing subject data (FFT)
% outcome: 
% trialPower{subject} = channels x 200msTrialWindowNumber
trialPower = cell(1,nSubs);

for currentSub = 1:nSubs
%% computing actual freq used and frequency index
% freq converted to an index
[c freqInd(currentSub)] = min(abs(fVec-freq(currentSub))); 
% Finds closest freq in resolved freq vector
freqUsed(currentSub) = fVec(freqInd(currentSub));       
    
%% loading in the data 
subname = subjects{currentSub};   
subname = subname{1};

disp('-------------------------------------');
disp(['Beginning data processing for ' subname]);
disp('-------------------------------------');

clear concatData
setPathEnviro(username,subname)
load(strcat(subname,'_concatData.mat'))

%% Reordering data according to run type
subNum = find(ismember(subRuns,subname));
conditionInd = find(runOrder(subNum,:)==condition);

%% applying head model
% reduce to 256 if starting with 256 or keep 194 in red HM
nChans = min(256,size(concatData.eeg{conditionInd},1));
data = concatData.eeg{conditionInd}(1:nChans,:);  
hm = concatData.hm;
%[~,motorChans] = ismember(concatData.motorChans,concatData.hm.ChansUsed);
% motor channels as originally selected in terms of 194-ch head model
% motorChans = [79    87    96   110   120   119   118   117   130   129];
motorChans = [79 87 120 121 131 140 148 161 162 163 164 165 166 171 172 173 123 174 175 176 179 180 181 182 183 8 ];


%% normalizing data based on std (helps correct for different impedance)
% stdData = repmat(std(data,[],2),[1,size(data,2)]);
% data = data./stdData;

%% computing FFT
% data = samples x channels
nSamples = size(data,2); nChans = size(data,1); % common vars
fdata = NaN(nChans,floor(nSamples/N));          %preparing data structure

for window = 1:floor(nSamples/N)   % moving along in 100ms windows   
   sampleWin = (window-1)*N+1:window*N;         % preparing sample window
   feeg = fft(data(:,sampleWin)')';             % taking fft of data
   feeg = squeeze(abs(feeg(:,freqInd(currentSub)))); % computing power @ f
   fdata(:,window) = feeg';                     % filling in data structure
   % fdata = channels x 100msWindowNumber 
end

%% segmenting data
cd .. ; 
load('note_timing_Blackbird') %creates var Blackbird   <nNotes x 1 double>
clear data note_timing_Blackbird sunshineDay
cd(subname);

 %start index of time sample marking beginning of trial (from labjack)
 startInd = find(abs(concatData.vid{conditionInd})>2000, 1 );
 %markerInds is an integer vector of marker indices (rounded to 100ms)
 markerInds = round((startInd+round(blackBird))/N);

 for trial = 1:length(markerInds)
    if trial==1; sumTrials=zeros(nChans,nWins); end;    
    trialData = fdata(:,markerInds(trial)-floor(nWins/2):markerInds(trial)+floor(nWins/2));
    sumTrials = sumTrials+trialData(1:nChans,1:nWins);
 end
 % trialPower = channels x 100msTrialWindowNumber(31 total)
 trialPower{currentSub} = sumTrials./length(markerInds);
 
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plotting inter-subject topography data (max desync value)

scrsz = [25 75 1600 850]; set(figure,'Position',scrsz); 
suptitle(['ERD (dB), Condition ' num2str(condition) ', ' condStr{condition}]);
dBPower = cell(1,nSubs);

for currentSub = 1:nSubs        
    baseline = repmat(mean(trialPower{currentSub}(:,baseInd),2),[1 nWins]);
    dBPower{currentSub}  = 10*log10(trialPower{currentSub}./baseline);
%     [~, minimizeMuIndex] = min(squeeze(mean(dBPower{currentSub}(motorChans,:),1)));
    minimizeMuIndex = 4:6; % .8-1.2 seconds into trial
    

    subplot(ceil(sqrt(nSubs)),ceil(sqrt(nSubs)),currentSub)
    subname = subjects{currentSub};   
    subname = subname{1};    
    title([subname ': ' num2str(freqUsed(currentSub)) ' Hz'])
    
    powerTopo = squeeze(mean(-dBPower{currentSub}(:,minimizeMuIndex),2));
    corttopo(powerTopo,hm,'drawelectrodes',0)        
    %set(gca,'clim',[-0.5 1.5])
    colorbar

end

%% time series result (fft preview)

set(figure,'Position',scrsz); hold on
suptitle(['ERD (dB), Condition ' num2str(condition) ', ' condStr{condition}]);
for currentSub = 1:nSubs
    smcPower = squeeze(mean(dBPower{currentSub}(motorChans,:),1));
    avgPower = squeeze(mean(dBPower{currentSub}(:,:),1));
    t = N*(1:length(smcPower))/fs;
    plot(t,smcPower,'r'); plot(t,avgPower);
    legend('SMC','AllChans','Location','Best');
end

%% single subject topography data (needs updating)
%% plotting data
% time course:
% set(figure,'Position',scrsz)
% for win = 1:nWins
%     subplot(3,5,win);
%     corttopo(trialPower{currentSub}(:,win),hm,'drawelectrodes',0);    
%     title(['trialTime = ' num2str(win*N/fs) ' sec']);
%     set(gca,'clim',[-200 200]) 
%     
% %     if win==1; pause(1); end;
% %     pause(0.010);
% end
%     end
end
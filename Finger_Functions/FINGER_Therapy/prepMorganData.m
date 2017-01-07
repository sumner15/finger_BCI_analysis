% function prepMorganData
% opens individual subject data and organizes it into the table for
% Morgan's predictor paper
% 
% If a subject list is not given, all subjects are processed.

% set parameters here
clearvars -except username 
clc; close all;

% frequency of interest
freqs = 5:40;
nFreqs = length(freqs);
disp(['Evaluating ' num2str(freqs(1)) '-' num2str(freqs(end)) ' Hz.'])

% time windows of interest (ms+1500 relative to t=0)
erdWindow = 250:1500;
ersWindow = 1250:3000; 

% username check
if (~exist('username','var'))
   username = input('Username (e.g. ''LAB''): ','s'); 
end

%% setting subject list and common vars
if ~exist('subjects','var')
    subjects = {'AGUJ','ARRS','BROR','CHIB','CORJ','CROD','ESCH','FLOA',...
            'GONA','HAAN','JOHG','KILB','LAMK','LEUW','LOUW','MALJ',...
            'MCCL','MILS','NGUT','POOJ','PRIJ','RITJ','SARS','VANT',...
            'WHIL','WILJ','WRIJ','YAMK'};            
else
    disp('subject list found.')
end
nSubs = length(subjects);

%% loading data
currentSub = 1;
while (currentSub <= nSubs) 
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
        nSubs = nSubs-1;
    end
end

%% creating table
colLabels = {'ERD_max_dB','ERD_latency_ms',...
             'ERS_max_dB','ERS_latency_ms',...
             'SMR_center_frequency'};
dataTableVals = NaN(nSubs,length(colLabels));         
       
for currentSub = 1:nSubs
    %select subjects data only
    subname = subjects{currentSub};
    data = eval(subname);    
    disp([  'min: ' num2str(min(data.trialPowerDB{1}(:))) ...
          '  max: ' num2str(max(data.trialPowerDB{1}(:)))])
    %average data across freqs of interest
    freqInds = freqs-4;
    [songPower{1},peakFreq1] = max(data.trialPowerDB{1}(freqInds,:));
    [songPower{2},peakFreq2] = max(data.trialPowerDB{2}(freqInds,:));
    [songPower{3},peakFreq3] = min(data.trialPowerDB{1}(freqInds,:));
    [songPower{4},peakFreq4] = min(data.trialPowerDB{2}(freqInds,:));    
    powerMax = 2*mean([songPower{1};songPower{2}],1);
    powerMin = 2*mean([songPower{3};songPower{4}],1);    
    %find erd max and index        
    [erdMax,erdMaxInd] = min(powerMin(erdWindow));
    erdLatency = erdMaxInd-(1500-erdWindow(1));    
    [ersMax,ersMaxInd] = max(powerMax(ersWindow));
    ersLatency = ersMaxInd-(1500-ersWindow(1));
    %find frequency responsible for erd/ers peaks
    peakFreq = mean([peakFreq1;peakFreq2;peakFreq3;peakFreq4],1);
    peakFreq = mode(peakFreq)+freqs(1)-1;
    %make data row for subject
    dataTableVals(currentSub,:) = [erdMax, erdLatency, ersMax, ...
                                   ersLatency, peakFreq];
end

%fill into table variable
eegData = table(dataTableVals(:,1),dataTableVals(:,2),...
                dataTableVals(:,3),dataTableVals(:,4),...
                dataTableVals(:,5),...
                'RowNames',subjects','VariableNames',colLabels')
%save data (if wanted)
saveBool = input('Would you like to save (y/n): ','s');
setPathTherapy(username);
if saveBool == 'y'
    writetable(eegData,'eegDataSummary.csv','WriteRowName',true);
end
    
       
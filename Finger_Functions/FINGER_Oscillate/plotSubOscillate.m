function plotSubOscillate(username,subname,powerData)
% plotSub pluts the intra-subject results of the FINGER Oscillate study.  
%
% The function pulls the final analyzed EEG data from the subjects' 
% processed file in your local directory 
%
% Input: subname (identifier) as string, e.g. 'LASF', 
%        username as string, e.g. 'Sumner'
%
% important structure: 
% powerData.power{exam}(trial,channel,fourierFreq,epoch)
%   size       { 2  }(  6  ,  16   ,    500    , 8/20)
%

disp('--- PLOTTING results ---');

%% loading data
if nargin < 3 
    setPathOscillate(username,subname)
    filename = celldir([subname '*powerData.mat']);
    filename{1} = filename{1}(1:end-4);
    disp(['Loading ' filename{1} '...'])
    load(filename{1}); fprintf('Done.\n');
    close all 
else
    disp('power data passed directly');
    if ~powerData.params.fourier 
        error('data does not contain power data');
    end
end

%% some vars
nExams = length(powerData.power);
nTrials = size(powerData.segEEG{1},1);
nChans = size(powerData.power{1},2);
nFreqs = size(powerData.power{1},3);
freqTested = [2 4 8 16 32 64];

% channels of interest
%chansUsed = 1:16;
chansUsed = [5  6  7  9   10 11 12 13];
%           C3 Cz C4 CP3 Cp4 P3 P2 P4              
%chansUsed = [6 7 10];
%           Cz C4 Cp4

%% %%%%%%%%%%%%%%%%%%% BEGIN TOPOGRAPHICAL PLOTTING %%%%%%%%%%%%%%%%%%%%%%%
%array of 3d space, size: (nChans x 3)
for exam = 1:nExams
    figure; hold on; suptitle([subname ' Topography (at freq of interest)']);
    for trial = 1:powerData.nTrials
        % averaging over epochs: powArray = (nChans x 1)
%         trialArray = squeeze(mean(powerData.power{exam}(trial,:,freqTested(trial),:),4));
%         breakArray = squeeze(mean(powerData.breakPower{exam}(trial,:,freqTested(trial),:),4));
        trialArray = squeeze(mean(powerData.power{exam}(trial,:,freqTested(trial),:),4));
        breakArray = squeeze(mean(powerData.breakPower{exam}(trial,:,freqTested(trial),:),4));
        dPowArray = trialArray - breakArray;
        subplot(floor(sqrt(powerData.nTrials)),ceil(sqrt(powerData.nTrials)),trial)   
        corttopo(dPowArray,powerData.hm,'drawelectrodes',0,'drawcolorbar',1); 
        %set(gca,'clim',[-400 400]);  
        title(['Robot Freq: ' num2str(freqTested(trial)) ' Hz']);         
    end
end   


%% %%%%%%%%%%%%%%%%%%%%% BEGIN TEMPORAL PLOTTING %%%%%%%%%%%%%%%%%%%%%%%%%
for exam = 1:nExams
    figure; hold on; suptitle([subname ' Temporal Results']);
    opengl software; clim = [0 800]; % limit on imagesc colors
    
   for trial = 1:powerData.nTrials       
       % averaging channels: powArray = (fourFreq x epoch)
       powArray = squeeze(mean(powerData.power{exam}(trial,chansUsed,2:70,:),2));
       % plotting result
       subplot(2,nTrials,trial);
       %title(['Robot Freq: ' num2str(freqTested(trial)) ' Hz']); 
       imagesc(powArray,clim); set(gca,'YDir','normal')
       %axis([1 20 1 50]);
       
       % repeating for the break
       powArray = squeeze(mean(powerData.breakPower{exam}(trial,chansUsed,2:70,:),2));
       subplot(2,nTrials,nTrials+trial);       
       imagesc(powArray,clim); set(gca,'YDir','normal') 
       %axis([1 8 1 50]);
       title(['Robot Freq: ' num2str(freqTested(trial)) ' Hz'],'FontSize', 14); 
   end
end

%% %%%%%%%%%%%%%%%%%%%%% BEGIN TIME INVARIANT %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% take average across temporal space (1-s epochs within trial)
for exam = 1:length(powerData.power)
    powerData.power{exam} = squeeze(mean(powerData.power{exam},4));
    powerData.breakPower{exam} = squeeze(mean(powerData.breakPower{exam},4));
end

%% plotting spectra for all tested freqs averaged across used channels  
 for exam = 1:nExams
    figure; hold on; suptitle([subname ' oscillating power spectra']); 
    for trial = 1:powerData.nTrials
        
        % computing average power spectra across channels of interest        
        powVec = squeeze(mean(powerData.power{exam}(trial,chansUsed,:),2));
        
        %plotting results
        subplot(floor(sqrt(powerData.nTrials)),ceil(sqrt(powerData.nTrials)),trial)             
        plot(powVec);
        axis([0 100 0 1500]); 
        title(['Robot Freq: ' num2str(freqTested(trial)) ' Hz']);   
        xlabel('Hz'); ylabel('power')                            
    end     
end

%% plotting spectra for all resting periods (after trials)
%  for exam = 1:nExams
%     figure; hold on; suptitle([subname ' power spectra: all channels average, BREAK ONLY']); 
%     for trial = 1:powerData.nTrials
%         
%         % computing average power spectra across all channels
%         powVec = zeros(nFreqs,1);
%         for channel = 1:nChans            
%             powVec = powVec+squeeze(powerData.breakPower{exam}(trial,channel,:));
%         end
%         powVec = powVec./nChans;
%         
%         %plotting results
%         subplot(floor(sqrt(powerData.nTrials)),ceil(sqrt(powerData.nTrials)),trial)             
%         plot(freqLinspace,powVec);
%         axis([0 40 0 600]); 
%         title(['Robot Freq: ' num2str(freqTested(trial)) ' Hz']);   
%         xlabel('Hz'); ylabel('power')                            
%     end     
% end

%% plotting delta spectra (trial vs. break) across channels  
 for exam = 1:nExams
    figure; hold on; suptitle([subname ' DELTA power spectra']); 
    for trial = 1:powerData.nTrials
        
        % computing average power spectra across channels of interest        
        powVec = squeeze(mean(powerData.power{exam}(trial,chansUsed,:),2));
        breVec = squeeze(mean(powerData.breakPower{exam}(trial,chansUsed,:),2));
        delVec = powVec-breVec;
        
        %plotting results
        subplot(floor(sqrt(powerData.nTrials)),ceil(sqrt(powerData.nTrials)),trial)             
        plot(delVec);
        axis([0 100 -500 500]); 
        title(['Robot Freq: ' num2str(freqTested(trial)) ' Hz']);   
        xlabel('Hz'); ylabel('power')                            
    end     
end

%% plotting spectra for all tested freqs and each channel individually
% for exam = 1:nExams
%     figure; hold on; suptitle([subname ' amplitude spectra']); 
%     for trial = 1:powerData.nTrials
%         for channel = 1:nChans  
%             % power spectrum for individual trial & channel combination
%             powVec = squeeze(powerData.power{exam}(trial,channel,:));
%             
%             %plotting results
%             subplot(powerData.nTrials,nChans,(trial-1)*nChans+channel)
%             plot(freqLinspace,powVec);
%             axis([0 40 0 1000]);                        
%         end
%     end     
% end
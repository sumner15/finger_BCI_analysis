function plotSubOscillate(username,subname)
% plotSub pluts the intra-subject results of the FINGER Oscillate study.  
%
% The function pulls the final analyzed EEG data from the subjects' 
% processed file in your local directory 
%
% Input: subname (identifier) as string, e.g. 'LASF', 
%        username as string, e.g. 'Sumner'
%
% important structure: 
% subData.power{exam}(trial,channel,fourierFreq,epoch)
%   size       { 2  }(  6  ,  16   ,    128    , 8/20)
%

%% loading data
setPathOscillate(username,subname)
filename = celldir([subname '*subData.mat']);
filename{1} = filename{1}(1:end-4);
disp(['Loading ' filename{1} '...'])
load(filename{1});
fprintf('Done.\n');

%% some vars
nExams = length(subData.segEEG);
nTrials = size(subData.segEEG{1},1);
nChans = size(subData.power{1},2);
nFreqs = size(subData.power{1},3);
freqTested = [4 6 8 10 12 14];
freqLinspace = linspace(0,subData.sr/2,nFreqs);


%% %%%%%%%%%%%%%%%%%%%%% BEGIN TEMPORAL PLOTTING %%%%%%%%%%%%%%%%%%%%%%%%%
for exam = 1:nExams
    figure; hold on; suptitle([subname 'Temporal Results']);
    opengl software; clim = [0 800]; % limit on imagesc colors
    
   for trial = 1:subData.nTrials       
       % averaging channels: powArray = (fourFreq x epoch)
       powArray = squeeze(mean(subData.power{exam}(trial,:,2:70,:),2));
       % plotting result
       subplot(nExams,nTrials,trial);
       title(['Robot Freq: ' num2str(freqTested(trial)) ' Hz']); 
       imagesc(powArray,clim); set(gca,'YDir','normal')
       
       % repeating for the break
       powArray = squeeze(mean(subData.breakPower{exam}(trial,:,2:70,:),2));
       subplot(nExams,nTrials,nTrials+trial);
       title(['Robot Freq: ' num2str(freqTested(trial)) ' Hz']); 
       imagesc(powArray,clim); set(gca,'YDir','normal')       
   end
end

%% %%%%%%%%%%%%%%%%%%%%% BEGIN TIME INVARIANT %%%%%%%%%%%%%%%%%%%%%%%%%%%%
for exam = 1:length(subData.power)
    subData.power{exam} = squeeze(mean(subData.power{exam},4));
    subData.power{exam} = squeeze(mean(subData.breakPower{exam},4));
end

%% plotting spectra for all tested freqs and each channel individually
for exam = 1:nExams
    figure; hold on; suptitle([subname ' amplitude spectra']); 
    for trial = 1:subData.nTrials
        for channel = 1:nChans  
            % power spectrum for individual trial & channel combination
            powVec = squeeze(subData.power{exam}(trial,channel,:));
            
            %plotting results
            subplot(subData.nTrials,nChans,(trial-1)*nChans+channel)
            plot(freqLinspace,powVec);
            axis([0 40 0 1000]);                        
        end
    end     
end

%% plotting spectra for all tested freqs averaged across all channels  
 for exam = 1:nExams
    figure; hold on; suptitle([subname ' power spectra: all channels average']); 
    for trial = 1:subData.nTrials
        
        % computing average power spectra across all channels
        powVec = zeros(nFreqs,1);
        for channel = 1:nChans            
            powVec = powVec+squeeze(subData.power{exam}(trial,channel,:));
        end
        powVec = powVec./nChans;
        
        %plotting results
        subplot(floor(sqrt(subData.nTrials)),ceil(sqrt(subData.nTrials)),trial)             
        plot(freqLinspace,powVec);
        axis([0 40 0 1000]); 
        title(['Robot Freq: ' num2str(freqTested(trial)) ' Hz']);   
        xlabel('Hz'); ylabel('power')                            
    end     
end

%% plotting spectra for all resting periods (after trials)
%  for exam = 1:nExams
%     figure; hold on; suptitle([subname ' power spectra: all channels average, BREAK ONLY']); 
%     for trial = 1:subData.nTrials
%         
%         % computing average power spectra across all channels
%         powVec = zeros(nFreqs,1);
%         for channel = 1:nChans            
%             powVec = powVec+squeeze(subData.breakPower{exam}(trial,channel,:));
%         end
%         powVec = powVec./nChans;
%         
%         %plotting results
%         subplot(floor(sqrt(subData.nTrials)),ceil(sqrt(subData.nTrials)),trial)             
%         plot(freqLinspace,powVec);
%         axis([0 40 0 600]); 
%         title(['Robot Freq: ' num2str(freqTested(trial)) ' Hz']);   
%         xlabel('Hz'); ylabel('power')                            
%     end     
% end

%% plotting delta spectra (trial vs. break) across channels  
%  for exam = 1:nExams
%     figure; hold on; suptitle([subname ' power spectra vs. baseline (chan-avg)']); 
%     for trial = 1:subData.nTrials
%         
%         % computing average power spectra across all channels
%         powVec = zeros(nFreqs,1); 
%         for channel = 1:nChans     
%             %power computed as difference between trial power and
%             %break/resting power
%             powVec = powVec+(squeeze(subData.power{exam}(trial,channel,:))...
%                 -squeeze(subData.breakPower{exam}(trial,channel,:)));            
%         end
%         powVec = powVec./nChans; 
%         
%         %plotting results
%         subplot(floor(sqrt(subData.nTrials)),ceil(sqrt(subData.nTrials)),trial)             
%         plot(freqLinspace,powVec);
%         axis([0 40 -1000 200]);
%         title(['Robot Freq: ' num2str(freqTested(trial)) ' Hz']);   
%         xlabel('Hz'); ylabel('power')                            
%     end     
% end
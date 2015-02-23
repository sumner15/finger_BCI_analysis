function plotSubOscillate(username,subname)
% plotSub pluts the intra-subject results of the FINGER Oscillate study.  
%
% The function pulls the final analyzed EEG data from the subjects' 
% processed file in your local directory 
%
% Input: subname (identifier) as string, e.g. 'LASF', 
%        username as string, e.g. 'Sumner'

%% loading data
setPathOscillate(username,subname)
filename = celldir([subname '*subData.mat']);
filename{1} = filename{1}(1:end-4);
disp(['Loading ' filename{1} '...'])
load(filename{1});
disp('Done.')

%% some vars
nChans = size(subData.power{1},2);
nFreqs = size(subData.power{1},3);

%% plotting spectra 
freqLinspace = linspace(0,subData.sr/2,nFreqs);

for exam = 1:length(subData.segEEG)
    figure; hold on; suptitle([subname ' amplitude spectra']); 
    for trial = 1:subData.nTrials
        for channel = 1:nChans            
            powVec = squeeze(subData.power{exam}(trial,channel,:));
            
            subplot(subData.nTrials,nChans,(trial-1)*nChans+channel)
            plot(freqLinspace,powVec);
            axis([0 40 0 120]);                        
        end
    end     
end
% xlabel('Frequency (Hz)'); ylabel('Amplitude');
% legend(h([1 2 3 5]),'AV only','robot+motor','motor','robot');


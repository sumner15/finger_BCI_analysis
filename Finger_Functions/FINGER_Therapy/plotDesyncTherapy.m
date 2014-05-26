function plotDesyncTherapy(spectra,freq)
%PlotMuDesync(spectra, freq)
% Plots mu over time by using the spectra variable as it is loaded from the
% subjects finalcean.mat data file.
%
% spectra: cell array of structures containing data from finalclean.mat
% freq: desired frequency lower bound in Hz. (e.g. freq = 8 will give the
% 8-12 Hz band).

if ~exist('spectra','var')
    error('please load finalclean, and verify existence of var: spectra');
end  
clf; close all;

%% checking that the frequency given was valid.
freqInd = find(spectra{1}.freqs==freq);
if isempty(freqInd)
    error(['please select a valid frequency: ' num2str(spectra{1}.freqs)]);
end

% creating string for plotting title purposes
freqrez = spectra{1}.freqs(2)-spectra{1}.freqs(1);
freqstr = [num2str(freq-freqrez/2) '-' num2str(freq+freqrez/2)];

%% Channel selection TEMPORARY SOLUTION ONLY!!!
LM_256 = [71  72  75  76  77  78  79  80  63  64  65  66  57  58  59 ...
          60  50  51  52  53  43  44  45  87  88  89];    
RM_256 = [132 185 197 144 184 196 205 204 195 183 155 164 182 194 203 ...
          173 181 131 143 154 163 172 180 130 142 153 ];      

hand = input('Which hand was tested (impaired hand)? (type L or R): ','s');
if     (hand == 'L'),  elecs = RM_256; %cont. cort LH = RM
elseif (hand == 'R'),  elecs = LM_256; %cont. cort RH = LM
else   error('improper selection of motor cortex channels');
end

newChans = zeros(1,length(elecs));
for i = 1:length(elecs)
    tempInd = find(spectra{1}.hm.ChansUsed==elecs(i));
    newChans(i) = tempInd;   
end
elecs = newChans;

%% Computing power, normalized power, and plotting results
%creating time vector for plotting
time = (-1500:250:1375)';

figure; hold on;
colors = ['r' 'g' 'b' 'k']; 

for i = 1:4
    % computing power across all chosen electrodes at the chosen frequency
    power{i} = squeeze(mean(spectra{i}.eegpower_trials(freqInd,elecs,:),2));
    % computing normalized power to first window of trial 
    normPower{i} = power{i}/power{i}(1)-1;
    % plotting result vs. time
    plot(time,normPower{i},colors(i));
end

xlabel('Time (msec rel to not reaching target)');
ylabel('Normalized Power (% change)');
title(strcat('Contralateral Motor Cortex : ',freqstr,'Hz Power'));

legend(spectra{1}.cond,spectra{2}.cond,spectra{3}.cond,spectra{4}.cond,'Location','Best');
axis([time(1) time(end) -1 1]);

%% Computing normalized power for all frequency bins
clear power normPower
power = cell(1,4); normPower = cell(1,4);
nFreqBins = size(spectra{1}.eegpower_trials,1);
nWindows  = size(spectra{1}.eegpower_trials,3);
for song = 1:4
    power{song} = zeros(nFreqBins,nWindows);
    for freqBin = 1:size(spectra{song}.eegpower_trials,1)   
       % computing power across all chosen electrodes at the current freq
       power{song}(freqBin,:) = squeeze(mean(spectra{song}.eegpower_trials(freqBin,elecs,:),2))';
       % computing normalized power to first window of trial
       normPower{song}(freqBin,:) = power{song}(freqBin,:)/power{song}(freqBin,1)-1;
    end   
end

%% Imagesc of frequency x time

figure;
for i = 1:4
    subplot(2,2,i)
%     %determining min and max power for plotting
%     minp = min(min(normPower{i})); maxp = max(max(normPower{i}));
    
    % plotting results
    h(1) = imagesc(normPower{i}(:,2:end),[-0.5 0.5]);
    colorbar
    
    %flipping y axis back to normal and labeling (frequency)
    set(gca,'YDir','normal') 
    set(gca,'YTick',1:1:length(spectra{1}.freqs))    
    for ii = 1:length(spectra{i}.freqs)
        strfreqs{ii} = num2str(spectra{i}.freqs(ii)); end
    set(gca,'YTickLabel',strfreqs)
        
    %labeling x axis ticks (time)
    set(gca,'XTick',1:1:length(time)-1)
    for ii = 1:length(time)-1
        strtimes{ii} = num2str(250*ii-1500); end
    set(gca,'XTickLabel',strtimes)
    
    % labels and titles
    ylabel('Frequency (Hz)');
    xlabel('Time (msec rel movement)');
    title(spectra{i}.cond);
end
    
end


function PlotMuDesync(spectra,freq)
%PlotMuDesync(spectra)
%   Plots mu over time

%% Raw Power

figure;

freqstr = num2str(spectra{1}.freqs(spectra{1}.freqs == freq));
freq = find(spectra{1}.freqs == freq);

time = -1500:125:1375;
 
LM = [7,31,37,42,32,38,43,48];

plot(time,squeeze(mean(spectra{1}.eegpower_chunks(freq,LM,:),2)),'r')
hold on;
plot(time,squeeze(mean(spectra{2}.eegpower_chunks(freq,LM,:),2)),'b')
plot(time,squeeze(mean(spectra{3}.eegpower_chunks(freq,LM,:),2)),'g')

xlabel('Time (sec rel to movement)');
ylabel('Power (uV^2)');
title(strcat('Left Motor Cortex : ',freqstr,'Hz Power Over Time'));

legend('Active','Passive','No Stim','Location','Best');

%ylim([0.5*10^6 1.5*10^6]);

%% Normalized Power

figure;

restingpower1 = ones(length(time),1)*squeeze(mean(spectra{1}.eegpower_chunks(freq,LM,1),2));
restingpower2 = ones(length(time),1)*squeeze(mean(spectra{2}.eegpower_chunks(freq,LM,1),2));
restingpower3 = ones(length(time),1)*squeeze(mean(spectra{3}.eegpower_chunks(freq,LM,1),2));

trialpower1 = squeeze(mean(spectra{1}.eegpower_chunks(freq,LM,:),2));
trialpower2 = squeeze(mean(spectra{2}.eegpower_chunks(freq,LM,:),2));
trialpower3 = squeeze(mean(spectra{3}.eegpower_chunks(freq,LM,:),2));

normpower1 = trialpower1./restingpower1;
normpower2 = trialpower2./restingpower2;
normpower3 = trialpower3./restingpower3;

normpower1 = normpower1';
normpower2 = normpower2';
normpower3 = normpower3';

plotx(time,log10(normpower1),'r');
hold on;
plotx(time,log10(normpower2),'b');
plotx(time,log10(normpower3),'g');

xlabel('Time (sec rel to movement)');
ylabel('Power (uV^2)');
title(strcat('Left Motor Cortex : ',freqstr,'Hz Normalized Power Over Time'));

legend('Active','Passive','No Stim','Location','Best');

%% Imagesc of frequency x time

figure;

colormap jet

time = -1.5:.125:1.375;

restingpower1 =  squeeze(mean(spectra{1}.eegpower_chunks(:,LM,1),2))*ones(1,size(spectra{1}.eegpower_chunks,3));
restingpower2 =  squeeze(mean(spectra{2}.eegpower_chunks(:,LM,1),2))*ones(1,size(spectra{1}.eegpower_chunks,3));
restingpower3 =  squeeze(mean(spectra{3}.eegpower_chunks(:,LM,1),2))*ones(1,size(spectra{1}.eegpower_chunks,3));

trialpower1 = squeeze(mean(spectra{1}.eegpower_chunks(:,LM,:),2));
trialpower2 = squeeze(mean(spectra{2}.eegpower_chunks(:,LM,:),2));
trialpower3 = squeeze(mean(spectra{3}.eegpower_chunks(:,LM,:),2));

normpower1 = trialpower1./restingpower1;
normpower2 = trialpower2./restingpower2;
normpower3 = trialpower3./restingpower3;

normpower1 = normpower1';
normpower2 = normpower2';
normpower3 = normpower3';

maxpower(1) = max(max(normpower1));
maxpower(2) = max(max(normpower2));
maxpower(3) = max(max(normpower3));

minpower(1) = min(min(normpower1));
minpower(2) = min(min(normpower2));
minpower(3) = min(max(normpower3));

maxp = log10(max(maxpower));
minp = log10(min(minpower));


for k = 1:length(spectra{1}.freqs)
     strfreqs{k} = num2str(spectra{1}.freqs(k));
end
for k = 1:length(time)
     strtimes{k} = num2str(time(k));
end

subplot(3,1,1);
h(1) = imagesc(log10(normpower1)',[minp maxp]);
colorbar
set(gca,'YTick',1:1:length(spectra{1}.freqs))
set(gca,'YTickLabel',strfreqs)
set(gca,'XTick',1:1:length(time))
set(gca,'XTickLabel',strtimes)
ylabel('Frequency (Hz)');
xlabel('Time (msec rel movement)');
title('Active Condition');

subplot(3,1,2);
h(2) = imagesc(log10(normpower2)',[minp maxp]);
colorbar
set(gca,'YTick',1:1:length(spectra{1}.freqs))
set(gca,'YTickLabel',strfreqs)
set(gca,'XTick',1:1:length(time))
set(gca,'XTickLabel',strtimes)
ylabel('Frequency (Hz)');
xlabel('Time (msec rel movement)');
title('Passive Condition');

subplot(3,1,3);
h(3) = imagesc(log10(normpower3)',[minp maxp]);
colorbar
set(gca,'YTick',1:1:length(spectra{1}.freqs))
set(gca,'YTickLabel',strfreqs)
set(gca,'XTick',1:1:length(time))
set(gca,'XTickLabel',strtimes)
ylabel('Frequency (Hz)');
xlabel('Time (msec rel movement)');
title('No Stim Condition');
    


end


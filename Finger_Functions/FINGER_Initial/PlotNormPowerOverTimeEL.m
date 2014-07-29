function PlotNormPowerOverTimeEL(spectra,freq,brain_region)
%PlotNormPowerOverTime(spectra,freq,brain_region)
%   Plots power over time for early-late parsed data
%   spectra: from spectanalysis structure
%   freq: frequencies to average over (as indices from freqs var)
%   brain_region: vector of channel numbers to average over

%% Normalized Power

figure;

time = -1500:125:1500-125;

restingpower1 = ones(size(spectra{1}.eegpower_chunks,3),1)*mean(squeeze(mean(spectra{1}.eegpower_chunks(freq,brain_region,1),1)));
restingpower2 = ones(size(spectra{1}.eegpower_chunks,3),1)*mean(squeeze(mean(spectra{2}.eegpower_chunks(freq,brain_region,1),1)));
restingpower3 = ones(size(spectra{1}.eegpower_chunks,3),1)*mean(squeeze(mean(spectra{3}.eegpower_chunks(freq,brain_region,1),1)));
restingpower4 = ones(size(spectra{1}.eegpower_chunks,3),1)*mean(squeeze(mean(spectra{4}.eegpower_chunks(freq,brain_region,1),1)));

trialpower1 = mean(squeeze(mean(spectra{1}.eegpower_chunks(freq,brain_region,:),1)));
trialpower2 = mean(squeeze(mean(spectra{2}.eegpower_chunks(freq,brain_region,:),1)));
trialpower3 = mean(squeeze(mean(spectra{3}.eegpower_chunks(freq,brain_region,:),1)));
trialpower4 = mean(squeeze(mean(spectra{4}.eegpower_chunks(freq,brain_region,:),1)));

normpower1 = trialpower1./restingpower1';
normpower2 = trialpower2./restingpower2';
normpower3 = trialpower3./restingpower3';
normpower4 = trialpower4./restingpower4';

plotx(time,log10(normpower1),'r');
hold on;
plotx(time,log10(normpower2),'b');
plotx(time,log10(normpower3),'g');
plotx(time,log10(normpower4),'k');

xlabel('Time (sec rel to movement)');
ylabel('Power (uV^2)');
title('Normalized Power Over Time');

legend('Imagined','Resting','Active Early','Active Late','Location','Best');


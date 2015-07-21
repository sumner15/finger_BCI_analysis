function PC = eegPCA(datain)
% function PCAEnviro(username,subname,trialPower)
% 
% input: datain (channel x time points)
% datain will typically contain all channels across a set of time
% points consistent with an epoch length that surrounds the event-related
% response to some stimulus. This will typically be an ERP or trial power 
% calculated at a frequency of interest. 
% 
% eegPCA calculates the primary components for the data
% and stores them in a structure with the fields:
%
% component:    (nChans x # of PCs) channel weighting for each component
% evals:        weight of each PC
% pcTime:       (# PCs x time points) time course of each primary component 
% pcSpectra:    spectra of each primary component

%% common vars
[nChans,nData] = size(datain);

%% calculate covariance matrix
datain = datain - repmat(mean(datain,2),[1 nData]);
cov = (datain*datain')./(nData-1); 

%% computing PCA via eigenvalue decomposition
[pc,evals] = eig(cov);
% Components are listed in increasing order; here we
% convert to descending order (most variance first)
PC.component = pc(:,end:-1:1);
evals = diag(evals);
% convert to percent change
PC.evals = 100*evals(end:-1:1)./sum(evals);

%% computing time course of each PC
PC.time = PC.component'*datain;

end
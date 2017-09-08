function concatData = concatPhase(username,subname,saveBool)
%concatEnviro
%
% concatEnviro concatenates the files from the Wadsworth FINGER study
% into a structure. (3-phase) 
%
% The concatData structure contains a single raw data array that is 
% nChannels x nTimeSamples. It also contains an index array containing 
% the beginning indices for each sub-test.
%
% Input: subname (identifier) as string, e.g. 'SLN', 
%        username as string, e.g. 'Sumner'


%% Load in subject .mat data file, timing data, and head model
setPathPhase(username,subname);
nTrialsExpected = 2;
concatData = datToMat(subname,nTrialsExpected);

%% info regarding the experimental setup
%sampling rate
concatData.sr = concatData.bciPrm.SamplingRate.NumericValue;   

%% concatenate or reorganize data
% setting convention of channel x sample array (not transposed)
for run = 1:length(concatData.eeg)
    if size(concatData.eeg{run},1)>size(concatData.eeg{run},2)
        concatData.eeg{run} = concatData.eeg{run}';
    end
end


%% save concatenated data
if saveBool
    disp('Saving concatenated data...');
    save(strcat(subname,'_concatData'),'concatData');
    disp('Done.');
else
    disp('Warning: Data not saved to disk; must pass directly');
end

end

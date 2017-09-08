function dataOut = datToMat(subname,nTrialsExpected)
% loads all subject data from .dat file produced by BCI2000 
% note: uses the BCI2000 mex scripts; must have BCI2000 installed!
%
% varin:
% subname as string (e.g. datToMat('NORS'));
% -- optional --
% nTrialsExpected: number of trials expected (error checking only)
% 
% varout:
% dataOut structure of 
% -signal cell array {trials},(samples x channels)
% -parameters (struct of BCI2000 parameters, set by BCI2000 config)

%% loading data 
fprintf('Converting data to .mat...');
try
    filename = celldir([subname '*.dat']);      %find filenames
catch me
    error('celldir failure: Are you sure the files are located here?');
end
nTrials = length(filename);

%% check that the number of trials matches what is expected for the exp.
if nargin == 2
    if nTrials~=nTrialsExpected
        error('data missing or in excess'); 
    end;
end

%% structure data into .signal & .parameters
for run = 1:nTrials
    %[signal, states, parameters, total_samples, file_samples] = load_bcidat( 'run.dat')
    [dataOut.eeg{run}, dataOut.state{run}, dataOut.bciPrm,~,~] = ...
        load_bcidat(filename{run});
    %transpose from sample-channel to channel-sample
    dataOut.eeg{run} = dataOut.eeg{run}';
end
fprintf('Done.\n');
end
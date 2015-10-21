function dataOut = datToMat(subname)
% loads all subject data from .dat file produced by BCI2000 
% note: uses the BCI2000 mex scripts; must have BCI2000 installed!
%
% subname as string (e.g. datToMat('NORS'));

%% loading data 
fprintf('Converting data to .mat...');
setPathGRAM(subname);
filename = celldir([subname '*.dat']);      %find filenames
nTrials = length(filename);

%% check that the number of trials matches what is expected for the exp.
% if nTrials~=nTrialsExpected; 
%     error('data missing or in excess'); 
% end;

%% structure data into .signal & .parameters
dataOut.signal = cell(1,nTrials);
for run = 1:nTrials
    %[signal, states, parameters, total_samples, file_samples] = load_bcidat( 'run.dat')
    [dataOut.signal{run}, ~, dataOut.parameters,~,~] = load_bcidat(filename{run});
end
fprintf('Done.\n');
end
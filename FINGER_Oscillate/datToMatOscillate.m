function dataOut = datToMatOscillate(username,subname)
% loads all subject data from .dat file produced by BCI2000 
% note: uses the BCI2000 mex scripts; must have BCI2000 installed!
%
% username as string (e.g. 'Sumner' or 'LAB')
% subname as string (e.g. datToMat('NORS'));

%% loading data 
setPathOscillate(username,subname);
filename = celldir([subname '*.dat']);      %find filenames

%if length(filename)~=6; error('data missing or in excess'); end;
dataOut.signal = cell(1,length(filename));
for run = 1:length(filename)
    %[signal, states, parameters, total_samples, file_samples] = load_bcidat( 'run.dat')
    [dataOut.signal{run}, dataOut.states{run}, dataOut.parameters,~,~] = load_bcidat(filename{run});
end

end
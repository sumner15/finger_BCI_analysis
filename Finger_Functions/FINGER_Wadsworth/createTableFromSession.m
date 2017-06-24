%calls datToMat to parse data from BCI2000 Wadsworth BCI study and stores
%the results in a table 
%
% takes in subID as a string, e.g. "NORS"
%       and session as integer, e.g. 09
%
% function dependencies:
% getERD(), getHitRate(), getMaxF()

function tableOut = createTableFromSession(subID, session)
%% create session and run strings
if session <= 09
    sessionString = [subID '00' num2str(session)];
else
    sessionString = [subID '0' num2str(session)];
end

%% load data into mat format
startDir = dataDirectory();
cd(sessionString);
data = datToMat(subID);
cd(startDir);

%% convert data into usable measures of performance
% ERD = getERD(data);
% maxF = getMaxF(data);
yellow = 1; blue = 2; index = 1; middle = 2; both = 3;
latencyYI = getLatency(data, session, yellow, index);
latencyYM = getLatency(data, session, yellow, middle);
latencyYB = getLatency(data, session, yellow, both);
latencyBI = getLatency(data, session, blue, index);
latencyBM = getLatency(data, session, blue, middle);
latencyBB = getLatency(data, session, blue, both);

tableOut = table(latencyYI, latencyYM, latencyYB, ...
                 latencyBI, latencyBM, latencyBB);

end


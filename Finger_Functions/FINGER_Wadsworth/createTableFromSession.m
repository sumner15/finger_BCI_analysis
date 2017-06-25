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
yellow = 1; blue = 2; index = 1; middle = 2; both = 3;

[latencyYI, maxPYI, latMaxPYI, maxVYI, latMaxVYI] = getLatency(data, session, yellow, index);
[latencyYM, maxPYM, latMaxPYM, maxVYM, latMaxVYM] = getLatency(data, session, yellow, middle);
[latencyYB, maxPYB, latMaxPYB, maxVYB, latMaxVYB] = getLatency(data, session, yellow, both);
[latencyBI, maxPBI, latMaxPBI, maxVBI, latMaxVBI] = getLatency(data, session, blue, index);
[latencyBM, maxPBM, latMaxPBM, maxVBM, latMaxVBM] = getLatency(data, session, blue, middle);
[latencyBB, maxPBB, latMaxPBB, maxVBB, latMaxVBB] = getLatency(data, session, blue, both);

tableOut = table(latencyYI, maxPYI, latMaxPYI, maxVYI, latMaxVYI,...
                 latencyYM, maxPYM, latMaxPYM, maxVYM, latMaxVYM,...
                 latencyYB, maxPYB, latMaxPYB, maxVYB, latMaxVYB,...
                 latencyBI, maxPBI, latMaxPBI, maxVBI, latMaxVBI,...
                 latencyBM, maxPBM, latMaxPBM, maxVBM, latMaxVBM,...
                 latencyBB, maxPBB, latMaxPBB, maxVBB, latMaxVBB);
end


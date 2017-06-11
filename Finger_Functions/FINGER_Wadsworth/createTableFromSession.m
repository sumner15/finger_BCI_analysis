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
ERD = getERD(data);
maxF = getMaxF(data);

tableOut = table(ERD,maxF);

end


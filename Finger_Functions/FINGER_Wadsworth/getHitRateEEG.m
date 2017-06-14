% opens the applog function to get hit rate as percentage
% takes in subID (e.g. NORS) and session (e.g. 7)
% returns hit rate in percentage (scalar)
function hitRate = getHitRateEEG(subID, session)
hitRate = NaN;

%% open data
if session <= 09
    sessionString = [subID '00' num2str(session)];
    applogString = [subID 'S00' num2str(session) '.applog'];
else
    sessionString = [subID '0' num2str(session)];
    applogString = [subID 'S0' num2str(session) '.applog'];
end
dataDirectory();
cd(sessionString);

fileID = fopen(applogString);
data = fread(fileID, 'uint8=>char')';
fclose(fileID);

%% parse data based on phase
if session > 3 && session < 10
    correctInds = strfind(data, '% correct')-2;
    hitRate = getNumber(correctInds,data);
end

%% function that gets integer hit rates from char array
    function number = getNumber(inds,data)
        runResults = NaN(1,length(inds));
        for run = 1:length(inds)
            numberChar = data(inds(run):inds(run)+1);
            runResults(run) = str2double(numberChar);
        end
        number = mean(runResults);
    end
end
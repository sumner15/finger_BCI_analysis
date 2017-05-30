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
    session = [subID '00' num2str(session)];
else
    session = [subID '0' num2str(session)];
end

%% load data into mat format
startDir = dataDirectory();
data = datToMat(subID);
cd(startDir);

%% convert data into usable measures of performance
ERD = getERD(data);
hitRate = getHitRate(data);
maxF = getMaxF(data);

tableOut = table(ERD,hitRate,maxF);

%% function to change directory according to computer 
    function startDir = dataDirectory(hostname)
        if nargin==0
            [~,hostname]= system('hostname');
        end
        try 
            if ispc         
                if hostname(1)=='D'
                    cd 'D:\Dropbox\UCI RESEARCH\FINGER\FINGER_wadsworth\data'
                else
                    error('missing path for Lab PC')
                end
            else
                cd '/Users/Sum/Dropbox/UCI RESEARCH/FINGER/FINGER_wadsworth/Data/'        
            end
            startDir = pwd;
            cd(session)                                    
        catch me
            error('Could not find data set or could not load')
        end
    end
end


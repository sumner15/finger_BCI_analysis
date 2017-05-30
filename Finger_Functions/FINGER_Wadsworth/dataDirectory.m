%% function to change directory according to computer 
function originalPath = dataDirectory(hostname)
originalPath = pwd;
    if nargin==0
        [~,hostname]= system('hostname');
    end    

    if ispc         
        if strcmp(hostname(1:5), 'DARTH')
            cd 'D:\Dropbox\UCI RESEARCH\FINGER\FINGER_wadsworth\data'
        else
            error('missing path for Lab PC')
        end
    else
        cd '/Users/Sum/Dropbox/UCI RESEARCH/FINGER/FINGER_wadsworth/Data/'        
    end                     
end
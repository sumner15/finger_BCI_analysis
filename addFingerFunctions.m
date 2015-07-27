function addFingerFunctions
%addFingerFunctions
%
% Adds FINGER relevant functions to the current working directory

dir = pwd;

% BCI2000 = input('Are you using BCI2000? (type y or n -- press ''enter'')\n','s');
if exist('C:\BCI2000\tools','dir') || exist('../../Documents/BCI2000/tools','dir')
    BCI2000 = 'y';
else
    BCI2000 = 'n';
    disp('BCI2000 directories not found. Skipping.');
end

%loading happens here for PC systems
if ispc == 1
    addpath(genpath(strcat(dir,'\Finger_Functions')));    
    if BCI2000 == 'y'
        try %sometimes 'tools' is nested
            cd C:\BCI2000\tools\tools;
        catch
            cd C:\BCI2000\tools;
        end
        disp('Loading BCI2000 tools.');
        addpath(genpath(strcat(pwd,'\matlab')));
        addpath(genpath(strcat(pwd,'\mex')));
        cd(dir);
    end
%otherwise, on a unix system...
else
    addpath(genpath(strcat(dir,'/Finger_Functions')));
    if BCI2000 == 'y'
        cd ../../Documents/BCI2000/tools;
        disp('Loading BCI2000 tools.');
        addpath(genpath(strcat(pwd,'/matlab')));
        addpath(genpath(strcat(pwd,'/mex')));    
        cd(dir);
    end
end
disp('FINGER function library added successfully.');

end
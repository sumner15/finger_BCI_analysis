function addFingerFunctions
%addFingerFunctions
%
% Adds FINGER relevant functions to the current working directory
%

dir = pwd;

BCI2000 = input('Are you using BCI2000? (type y or n -- press ''enter'')\n','s');
%BCI2000 = 'n';

if ispc == 1
    addpath(genpath(strcat(dir,'\Finger_Functions')));    
    if BCI2000 == 'y'
        try
            cd C:\BCI2000\tools\tools;
        catch
            cd C:\BCI2000\tools;
        end
        addpath(genpath(strcat(pwd,'\matlab')));
        addpath(genpath(strcat(pwd,'\mex')));
        cd(dir);
    end
else
    addpath(genpath(strcat(dir,'/Finger_Functions')));
    if BCI2000 == 'y'
        cd ../../Documents/BCI2000/tools;
        addpath(genpath(strcat(pwd,'/matlab')));
        addpath(genpath(strcat(pwd,'/mex')));    
        cd(dir);
    end
end

disp('FINGER function library added.');

end
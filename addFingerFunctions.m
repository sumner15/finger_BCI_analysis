function addFingerFunctions
%addFingerFunctions
%
% Adds FINGER relevant functions to the current working directory
%

dir = pwd;

if ispc == 1
    addpath(genpath(strcat(dir,'\Finger_Functions')));
    cd C:\BCI2000\tools;
    addpath(genpath(strcat(pwd,'\matlab')));
    addpath(genpath(strcat(pwd,'\mex')));
    cd(dir);
else
    addpath(genpath(strcat(dir,'/Finger_Functions')));
    cd ../../Documents/BCI2000/tools;
    addpath(genpath(strcat(pwd,'/matlab')));
    addpath(genpath(strcat(pwd,'/mex')));
    
    cd(dir);
end

disp('FINGER function library added.');

end
function addFingerFunctions
% function addFingerFunctions
% Adds FINGER relevant functions to the current working directory
dir = pwd;

% BCI2000 = input('Are you using BCI2000? (type y or n -- press ''enter'')\n','s');
BCI2000 =  exist('C:\BCI2000\tools','dir') || ...
           exist('../../Documents/BCI2000/tools','dir');

% cbmspc(Nenadic) code
CBMSPC = exist('C:\Users\Sumner\Desktop\MATLAB\cbmspccode','dir');

%loading happens here for PC systems
if ispc
    % adding finger functions
%     addpath(genpath(strcat(dir,'\Finger_Functions')));   
    addpath(genpath(dir));
    disp('FINGER function library added successfully.');
    
    % adding BCI2000 dirs
    if BCI2000 
        try %sometimes 'tools' is nested
            cd C:\BCI2000\tools\tools;
        catch
            cd C:\BCI2000\tools;
        end        
        addpath(genpath(strcat(pwd,'\matlab')));
        addpath(genpath(strcat(pwd,'\mex')));
        disp('BCI2000 tools loaded.');        
    else
        disp('BCI2000 directories not found. Skipping.');
    end    
    
    % loading CBMSPC dirs
    if CBMSPC
        cd('C:\Users\Sumner\Desktop\MATLAB\cbmspccode');
        addpath(genpath(pwd));       
        disp('CBMSPC directories added.');
    else
        disp('CBMSPC directory not found. Skipping.');
    end
    
%otherwise, on a unix system...
else
    % adding finger functions
    addpath(genpath(strcat(dir,'/Finger_Functions')));
    disp('FINGER function library added successfully.');
    
    % adding BCI2000 dirs
    if BCI2000 
        cd ../../Documents/BCI2000/tools;
        disp('Loading BCI2000 tools.');
        addpath(genpath(strcat(pwd,'/matlab')));
        addpath(genpath(strcat(pwd,'/mex')));            
    else
        disp('BCI2000 directories not found. Skipping.');
    end
end

cd(dir)
end
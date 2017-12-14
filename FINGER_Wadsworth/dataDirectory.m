%% function to change directory according to computer 
function originalPath = dataDirectory(returnPath,hostname)
    originalPath = pwd;
    if ~exist('hostname','var')
        [~,hostname]= system('hostname');
    end    
    
    %% return to code path
    if nargin>=1
        if returnPath
            if ispc && strcmp(hostname(1:5), 'DARTH') || strcmp(hostname(1:7), 'Caltech')
                    cd 'D:\Dropbox\UCI RESEARCH\FINGER\Finger_BCI_DATA matlab processing\FINGER_Wadsworth'                
            else
                cd '/Users/Sum/Dropbox/UCI RESEARCH/FINGER/Finger_BCI_DATA matlab processing/FINGER_Wadsworth'            
            end                 
           return 
        end
    end   

    %% go to data path
    if ispc                 
        cd 'D:\Dropbox\UCI RESEARCH\FINGER\FINGER_wadsworth\data'
    else
        cd '/Users/Sum/Dropbox/UCI RESEARCH/FINGER/FINGER_wadsworth/Data/'        
    end                     
end
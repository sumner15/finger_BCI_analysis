%% function to change directory according to computer 
function originalPath = dataDirectory(returnPath,hostname)
    originalPath = pwd;
    if ~exist('hostname','var')
        [~,hostname]= system('hostname');
    end    
    
    %% return to code path
    if nargin>=1
        if returnPath
            if ispc         
                if strcmp(hostname(1:5), 'DARTH')
                    cd 'D:\Dropbox\UCI RESEARCH\FINGER\Finger_BCI_DATA matlab processing\Finger_Functions\FINGER_Wadsworth'
                elseif strcmp(hostname(1:5), 'LABPC')
                    cd 'C:\Users\Sumner\Desktop\finger_bci_data_processing\Finger_Functions\FINGER_Wadsworth'
                end
            else
                cd '/Users/Sum/Dropbox/UCI RESEARCH/FINGER/Finger_BCI_DATA matlab processing/finger_Functions/FINGER_Wadsworth'            
            end                 
           return 
        end
    end   

    %% go to data path
    if ispc         
        if strcmp(hostname(1:5), 'DARTH')
            cd 'D:\Dropbox\UCI RESEARCH\FINGER\FINGER_wadsworth\data'
        elseif strcmp(hostname(1:5), 'LABPC')
            cd 'D:\FINGER_Wadsworth\DATA'
        end
    else
        cd '/Users/Sum/Dropbox/UCI RESEARCH/FINGER/FINGER_wadsworth/Data/'        
    end                     
end
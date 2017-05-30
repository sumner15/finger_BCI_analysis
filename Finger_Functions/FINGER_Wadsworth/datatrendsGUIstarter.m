clear all
fprintf('Subject List: MCCL VANT MAUA HATA PHIC CHEA RAZT TRUL\n')

while ~exist('T','var')
    try   
        subID = input('Which subject would you like to view? ','s');
        if ispc
            cd 'C:\Users\Sumner\Dropbox\UCI RESEARCH\FINGER\FINGER_wadsworth\Data\'
        else
            cd '/Users/Sum/Dropbox/UCI RESEARCH/FINGER/FINGER_wadsworth/Data/'        
        end
        startDir = pwd;
        cd(subID)
        T = load([subID 'Table']);
    catch me
        warning('Could not find data set or could not load')
    end
end

datatrendsGUI(T)

clear
fprintf('Subject List: MCCL VANT MAUA HATA PHIC CHEA RAZT TRUL\n')

while ~exist('T','var')
    try   
        subID = input('Which subject would you like to view? ','s');        
        T = createSubjectTable(subID);
    catch me
        warning('Could not find data set or could not load')
    end
end

datatrendsGUI2(T)

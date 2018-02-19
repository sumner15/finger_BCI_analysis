clear; clc;
fprintf('Subject List: MCCL VANT MAUA HATA PHIC CHEA RAZT TRUL\n')

while ~exist('T','var')
    choice = input('across-subject analysis (1) or within (2)?  ','s');
    if choice=='2'
        try     
            subID = input('Which subject would you like to view? ','s');    
            try 
                dataDirectory();
                load(subID)
                T = subData;
            catch me
                T = createSubjectTable(subID);
            end
        catch me
            warning('Could not find data set or could not load')
        end
    else        
        T = load('ClinicalDataContinuous.mat');        
        T = T.clinicalDataContinuous;        
    end
end

datatrendsGUI2(T)
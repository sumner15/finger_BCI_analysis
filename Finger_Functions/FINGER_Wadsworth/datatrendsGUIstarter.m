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

plotGoodResults()

function plotGoodResults(T)    
%% plot useful results
    set(figure,'Position',[100 20 600 500])
    set(0,'defaultlinelinewidth',4)
    
    lm = fitlm(T.BBTscreenI,T.changeBBT,'linear');
    plot([min(T.BBTscreenI) max(T.BBTscreenI)],...
        [lm.Coefficients{2,1}*(min(T.BBTscreenI))+lm.Coefficients{1,1} ...
         lm.Coefficients{2,1}*(max(T.BBTscreenI))+lm.Coefficients{1,1}],...
         'color',[0 0.447 0.741],'Linewidth',2)
    hold on
    
    plot(T.BBTscreenI,T.changeBBT,'ok')    
    plot(T.BBTscreenI('MCCL'),T.changeBBT('MCCL'),'or')
    plot(T.BBTscreenI('MAUA'),T.changeBBT('MAUA'),'or')

    xlabel('Box & Blocks at Screening')
    ylabel('Box & Blocks change')
    grid on
    
    legend(['R^2 = ' num2str(lm.Rsquared.Ordinary) ...
        ',  p = ' num2str(lm.Coefficients.pValue(2))],...
        'location','best')
end
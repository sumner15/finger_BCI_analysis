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

plotGoodResults(T)

function plotGoodResults(T)    
%% plot useful results
    set(figure,'Position',[100 20 600 500])
    set(0,'defaultlinelinewidth',4)
    
    goodSubs = {'CHEA','RAZT','TRUL','VANT'};
    noControl = {'MCCL','MAUA'};
    emgControl = {'HATA','PHIC'};
    
    lm = fitlm(T.BBTscreenI(goodSubs),T.changeBBT(goodSubs),'linear');
    plot([min(T.BBTscreenI) max(T.BBTscreenI)],...
        [lm.Coefficients{2,1}*(min(T.BBTscreenI))+lm.Coefficients{1,1} ...
         lm.Coefficients{2,1}*(max(T.BBTscreenI))+lm.Coefficients{1,1}],...
         'color',[0 0.447 0.741],'Linewidth',2)
    hold on
    
    plot(T.BBTscreenI,T.changeBBT,'ok')    
    plot(T.BBTscreenI(noControl),T.changeBBT(noControl),'or')        
    plot(T.BBTscreenI(emgControl),T.changeBBT(emgControl),'ob')

    xlabel('Box & Blocks at Screening')
    ylabel('Box & Blocks change')
    grid on
    ylim([0 10])
    
    legend(['R^2 = ' num2str(round(lm.Rsquared.Ordinary,3)) ...
        ',  p = ' num2str(round(lm.Coefficients.pValue(2),3))],...
        'location','best')
end
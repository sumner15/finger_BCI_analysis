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
%%  % plot BBT at baseline vs. change in BBT
    set(figure,'Position',[100 20 600 500])
    set(0,'defaultlinelinewidth',2)
    % define subjects
    goodSubs = {'CHEA','RAZT','TRUL','VANT'};
        %noControl = {'MCCL','MAUA'};
        %emgControl = {'HATA','PHIC'};
    % create and plot fit line
    lm = fitlm(T.BBTscreenI(goodSubs),T.changeBBT(goodSubs),'linear');
    plot([min(T.BBTscreenI) max(T.BBTscreenI)],...
        [lm.Coefficients{2,1}*(min(T.BBTscreenI))+lm.Coefficients{1,1} ...
         lm.Coefficients{2,1}*(max(T.BBTscreenI))+lm.Coefficients{1,1}],...
         'color',[0 0.447 0.741],'Linewidth',2)
    hold on   
    % sort to plot in order
    T = sortrows(T,'RowNames');
    code = {'-ok','-ob','-or','-xr','-xb','-xk','-*k','-+k'};
    % plot each subject
    for sub = 1:size(T,1)
        plot(T.BBTscreenI(sub),T.changeBBT(sub),code{sub})
    end
    % set type
    xlabel('Box & Blocks at Screening')
    ylabel('Box & Blocks change')
    grid on    
    set(findall(gcf,'-property','FontSize'),'FontSize',20)
    set(findall(gcf,'-property','FontName'),'FontName','Times New Roman')
    % set legend
    l1 = legend(['R^2 = ' num2str(round(lm.Rsquared.Ordinary,3)) ...
        ',  p = ' num2str(round(lm.Coefficients.pValue(2),3))],...        
        'location','best');
    set(l1,'FontSize',15)
    
    
%%% % plot BBT at baseline vs. change in BBT
plotData = {T.changeLatIndexUF, T.changeLatMiddleUF, T.changeLatBothUF};
goodSubs = [1 6 7 8];
labels = {'\delta latency index','\delta latency middle','\delta latency both'};
for i = 1:length(plotData)    
    set(figure,'Position',[100 20 600 500])            
    % create and plot fit line
    lm = fitlm(T.BBTscreenI(goodSubs),plotData{i}(goodSubs),'linear');
    plot([min(T.BBTscreenI) max(T.BBTscreenI)],...
        [lm.Coefficients{2,1}*(min(T.BBTscreenI))+lm.Coefficients{1,1} ...
         lm.Coefficients{2,1}*(max(T.BBTscreenI))+lm.Coefficients{1,1}],...
         'color',[0 0.447 0.741],'Linewidth',2)
    hold on   
    % plot     
    for sub = 1:size(T,1)
        plot(T.BBTscreenI(sub),plotData{i}(sub),code{sub})
    end
    % set type
    xlabel('Box & Blocks at Screening')
    ylabel(labels(i))
    grid on    
    set(findall(gcf,'-property','FontSize'),'FontSize',20)
    set(findall(gcf,'-property','FontName'),'FontName','Times New Roman')
    % set legend
    l1 = legend(['R^2 = ' num2str(round(lm.Rsquared.Ordinary,3)) ...
        ',  p = ' num2str(round(lm.Coefficients.pValue(2),3))],...        
        'location','best');
    set(l1,'FontSize',15)
end
    
    
end
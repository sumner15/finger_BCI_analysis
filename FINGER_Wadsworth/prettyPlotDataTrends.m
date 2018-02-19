[~] = dataDirectory(true);

if ~exist('T','var')
    disp('loading clinical data from file')
    T = load('ClinicalDataContinuous.mat');        
    T = T.clinicalDataContinuous;        
end

close all
%%  % plot BBT at baseline vs. change in BBT



set(figure,'Position',[100 20 600 500])
set(0,'defaultlinelinewidth',2)
% define subjects
goodSubs = {'CHEA','RAZT','TRUL','VANT'};
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

setType('BBT Change (blocks)', lm)
% axis([0 30 0 10])
    
    
%% % plot BBT at baseline vs. finger movement latency
meanChangeLat = mean([T.changeLatIndexUF T.changeLatMiddleUF T.changeLatBothUF],2);
plotData = {meanChangeLat};
goodSubs = [1 6 7 8];
% goodSubs = 1:8;
labels = {'\delta latency index','\delta latency middle','\delta latency both','\delta latency'};

set(figure,'Position',[100 20 600 500])            
% create and plot fit line
lm = fitlm(T.BBTscreenI(goodSubs),meanChangeLat(goodSubs),'linear');
plot([min(T.BBTscreenI) max(T.BBTscreenI)],...
    [lm.Coefficients{2,1}*(min(T.BBTscreenI))+lm.Coefficients{1,1} ...
     lm.Coefficients{2,1}*(max(T.BBTscreenI))+lm.Coefficients{1,1}],...
     'color',[0 0.447 0.741],'Linewidth',2)
hold on   
% plot     
for sub = 1:size(T,1)
    plot(T.BBTscreenI(sub),meanChangeLat(sub),code{sub})
end

setType('\delta latency (sec)', lm)

%% function to set type
function setType(yAxisLabel, lm)
    xlabel('BBT Baseline (blocks)')
    ylabel(yAxisLabel)
    grid on    
    set(findall(gcf,'-property','FontSize'),'FontSize',20)
    set(findall(gcf,'-property','FontName'),'FontName','Arial')
    
    % set legend
    l1 = legend(['R^2 = ' num2str(round(lm.Rsquared.Ordinary,3)) ...
        ',  p = ' num2str(round(lm.Coefficients.pValue(2),3))],...        
        'location','best');
    set(l1,'FontSize',15)    
end
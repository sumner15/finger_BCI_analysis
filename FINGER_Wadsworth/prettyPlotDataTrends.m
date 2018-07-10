[~] = dataDirectory(true);

if ~exist('T','var')
    disp('loading clinical data from file')
    T = load('ClinicalDataContinuous.mat');        
    T = T.clinicalDataContinuous;        
end

close all
%%  % plot BBT at baseline vs. change in BBT

% T.changeBBT = mean([T.BBT4I T.BBT3I],2)-mean([T.BBT1I T.BBTscreenI],2);

set(figure,'Position',[100 20 600 500])
set(0,'defaultlinelinewidth',2)
% define subjects
goodSubs = {'CHEA','RAZT','TRUL','VANT'};
% create fit line (pearson correlation - assumes linear!)
lm = fitlm(T.BBTscreenI(goodSubs),T.changeBBT(goodSubs),'linear');
% getting spearman correlation values (assumes ordinal monotonically increasing)
[RHO,PVAL] = corr(T.BBTscreenI,T.changeBBT,'Type','Spearman');
fprintf('Spearman Correlation (BBT screen | BBT change for all subjects):\t\t\trho = %1.3f\tp = %1.3f \n',RHO, PVAL)
[RHO,PVAL] = corr(T.BBTscreenI(goodSubs),T.changeBBT(goodSubs),'Type','Spearman');
fprintf('Spearman Correlation (BBT screen | BBT change for BCI-control subjects):\trho = %1.3f\tp = %1.3f \n',RHO, PVAL)

% plotting
h0 = plot([min(T.BBTscreenI) max(T.BBTscreenI)],...
    [lm.Coefficients{2,1}*(min(T.BBTscreenI))+lm.Coefficients{1,1} ...
     lm.Coefficients{2,1}*(max(T.BBTscreenI))+lm.Coefficients{1,1}],...
     'color',[0 0.447 0.741],'Linewidth',2);
hold on   
% sort to plot in order
T = sortrows(T,'RowNames');
code = {'-ok','-ob','-or','-xr','-xb','-xk','-*k','-+k'};
% plot each subject
for sub = 1:size(T,1)
    plot(T.BBTscreenI(sub),T.changeBBT(sub),code{sub},'MarkerSize',15)
end

setType('BBT Change (blocks)', lm)
grid minor
% axis([0 30 0 10])
set(h0,'visible','off')
    
    
%% % plot BBT at baseline vs. finger movement latency
meanChangeLat = mean([T.changeLatIndexUF T.changeLatMiddleUF T.changeLatBothUF],2);
plotData = {meanChangeLat};
goodSubs = [1 6 7 8];
% goodSubs = 1:8;
labels = {'\delta latency index','\delta latency middle','\delta latency both','\delta latency'};

set(figure,'Position',[100 20 600 500])            
% create fit line (pearson correlation - assumes linear!)
lm = fitlm(T.BBTscreenI(goodSubs),meanChangeLat(goodSubs),'linear');
% getting spearman correlation values (assumes ordinal monotonically increasing)
[RHO,PVAL] = corr(T.BBTscreenI,meanChangeLat,'Type','Spearman');
fprintf('Spearman Correlation (BBT screen | latency change for all subjects):\t\t\trho = %1.3f\tp = %1.3f \n',RHO, PVAL)
[RHO,PVAL] = corr(T.BBTscreenI(goodSubs),meanChangeLat(goodSubs),'Type','Spearman');
fprintf('Spearman Correlation (BBT screen | latency change for BCI-control subjects):\trho = %1.3f\tp = %1.3f \n',RHO, PVAL)

ax = subplot(1,1,1);
h1 = plot([min(T.BBTscreenI) max(T.BBTscreenI)],...
    [lm.Coefficients{2,1}*(min(T.BBTscreenI))+lm.Coefficients{1,1} ...
     lm.Coefficients{2,1}*(max(T.BBTscreenI))+lm.Coefficients{1,1}],...     
     'color',[0 0.447 0.741],'Linewidth',2);
hold on   
% plot     
for sub = 1:size(T,1)
    plot(T.BBTscreenI(sub),meanChangeLat(sub),code{sub},'MarkerSize',15)
end

setType('latency change (s)', lm)
ax.XMinorGrid = 'on'; %turns on the minor grid.
ax.YGrid = 'on';
set(h1,'visible','off')

%% function to set type
function setType(yAxisLabel, lm)
    xlabel('BBT Baseline (blocks)')
    ylabel(yAxisLabel)
%     grid on
    set(findall(gcf,'-property','FontSize'),'FontSize',20)
    set(findall(gcf,'-property','FontName'),'FontName','Arial')
    
    % set legend
    l1 = legend(['R^2 = ' num2str(round(lm.Rsquared.Ordinary,3)) ...
        ',  p = ' num2str(round(lm.Coefficients.pValue(2),3))],...        
        'location','best');
    set(l1,'FontSize',15)    
    legend off
end
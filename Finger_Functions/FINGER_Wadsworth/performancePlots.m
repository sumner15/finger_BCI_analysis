clear; clc; close all
subjects = {'MCCL','VANT','MAUA','HATA','PHIC','CHEA','RAZT','TRUL'};
nSubs = length(subjects);

%% load hit Rate performance
dataDirectory();

[ERDp, ERDR2, hitRate] = deal(cell(nSubs,1));
for sub = 1:nSubs
   load(subjects{sub}) 
   
   ERDp{sub} = subData.ERDp;
   ERDR2{sub} = subData.ERDR2;
   hitRate{sub} = subData.hitRate;
end

%% plot results
plotOverSession(ERDp, 'ERD p-val', subjects)
plotOverSession(ERDR2, 'ERD (R^2)', subjects)
plotOverSession(hitRate, 'hit rate (%', subjects)
%% CODED variable table 
% FIRST LETTER 
% b - baseline
% p - post
% c - change (change = post - baseline)
%
% SECOND LETTER 
% h - hit (all grips included)
% i - index
% m - middle
%
% THIRD LETTER(S) 
% r - hit rate (percentage of notes hit for a particular grip)
% lat - latency (mean timing of a grip compared to actual note timing)
% std - standard deviation of latency (all grips)

addpath(cd);
cd D:\FINGER_therapy\MusicGloveData\summary

subjects = {'DEGW','JOHG','MCCL','VANT','ESCH','YAMK','CROD','NGUT',...
            'LOUW','BROR','CORJ','LEUW','AGUJ','HAAN','GONA','FLOA',...
            'WILJ','WHIL','RITJ','SARS','WRIJ','WARG','ARRS','CHIB',...
            'POOJ','LAMK','KILB','PRIJ','MALJ','MITG'};
nSubs = length(subjects);   

[bhr,phr,chr,bir,pir,cir,bmr,pmr,cmr,bLat,pLat,cLat,bStd,pStd,cStd] =...
    deal(NaN(nSubs,1));

%% organizing data
for sub = 1:nSubs     
    % loading file
    try 
        subname = subjects{sub};       
        filename = celldir([subname '*.csv']);                        
        disp(['Loading ' filename{1} '...']);
        importfile(filename{1})  
    catch me 
        warning([subname ': No data found for this subject']);
        clear data textdata
    end    
    % filling data 
    try
        songTitles = textdata(:,3);
        sunshineInds = find(ismember(songTitles,'Sunshine Day'))-1;
        speedInds = find(ismember(songTitles,'Speed Test'))-1;  
        baseInds = [sunshineInds(1);speedInds(1)];
        postInds = [sunshineInds(2);speedInds(2)];
        
        allHitsBase = sum(sum(data(baseInds,1:5)));
        allHitsPossibleBase = sum(sum(data(baseInds,6:10)));      
        allHitsPost = sum(sum(data(postInds,1:5)));
        allHitsPossiblePost = sum(sum(data(postInds,6:10)));
        
        bhr(sub) = allHitsBase/allHitsPossibleBase*100;  
        phr(sub) = allHitsPost/allHitsPossiblePost*100;       
        
        bir(sub) = sum(data(baseInds,2))/sum(data(baseInds,7))*100;
        pir(sub) = sum(data(postInds,2))/sum(data(postInds,7))*100;
        
        bmr(sub) = sum(data(baseInds,3))/sum(data(baseInds,8))*100;
        pmr(sub) = sum(data(postInds,3))/sum(data(postInds,8))*100;
        
        bLat(sub) = mean(data(baseInds,11));
        pLat(sub) = mean(data(postInds,11));
        
        bStd(sub) = mean(data(baseInds,12));
        pStd(sub) = mean(data(postInds,12));
        
        chr(sub) = phr(sub)-bhr(sub);        
        cir(sub) = pir(sub)-bir(sub);
        cmr(sub) = pmr(sub)-bmr(sub);
        cLat(sub) = pLat(sub)-bLat(sub);
        cStd(sub) = pStd(sub)-bStd(sub);
        
    catch me 
        warning([subname ': Data is badly sized']);
    end
end

%% special cases
for sub = 1:nSubs
    %if they didn't hit a note at baseline, they have no baseline stats 
    %(set to nan) and no change stats
   if bhr(sub)==0      
       bLat(sub) = NaN;
       bStd(sub) = NaN;
       cLat(sub) = NaN;
       cStd(sub) = NaN;
   end
   %if they didn't hit a note at post, they have no post/change stats
   if phr(sub)==0
       pLat(sub) = NaN;
       pStd(sub) = NaN;
       cLat(sub) = NaN;
       cStd(sub) = NaN;
   end
end

%% organize table and save
if strcmp(subjects{13},'AGUJ')    
    subjects{13} = 'ARUJ';
end

MGData = table(bhr,phr,chr,bir,pir,cir,bmr,pmr,cmr,...
    bLat,pLat,cLat,bStd,pStd,cStd,...
    'RowNames',subjects);
TCSV = table(subjects',...
    bhr,phr,chr,bir,pir,cir,bmr,pmr,cmr,bLat,pLat,cLat,bStd,pStd,cStd);

cd ..
save('MusicGloveDataSummary','MGData')
writetable(TCSV,'MusicGloveDataSummary.csv')

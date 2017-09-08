addpath(cd);
subjects = {'DEGW','JOHG','MCCL','VANT','ESCH','YAMK','CROD','NGUT',...
            'LOUW','BROR','CORJ','LEUW','AGUJ','HAAN','GONA','FLOA',...
            'WILJ','WHIL','RITJ','SARS','WRIJ','WARG','ARRS','CHIB',...
            'POOJ','LAMK','KILB','PRIJ','MALJ','MITG'};
nSubs = length(subjects);   
hitRateMatrix = NaN(nSubs,4); % nSubs x (%hitSD[1]%hitSD[2]%hitST[1]%hitST[2])

%% loading data
cd Summary
for sub = 1:nSubs     
    try 
        subname = subjects{sub};       
        filename = celldir([subname '*.csv']);                        
        disp(['Loading ' filename{1} '...']);
        importfile(filename{1})  
    catch me 
        disp([subname ': No data found for this subject']);
    end    
    %% concatenating data
    try
        songTitles = textdata(:,3);
        sunshineInds = find(ismember(songTitles,'Sunshine Day'))-1;
        speedInds = find(ismember(songTitles,'Speed Test'))-1;
        hitRateSD = sum(data(sunshineInds,1:5),2)./sum(data(sunshineInds,6:10),2)*100;
        hitRateST = sum(data(speedInds,1:5),2)./sum(data(speedInds,6:10),2)*100;
        hitRateVector = [hitRateSD; hitRateST]';
        hitRateMatrix(sub,:) = hitRateVector;
    catch me 
        warning([subname ': Data is badly sized']);
    end
end

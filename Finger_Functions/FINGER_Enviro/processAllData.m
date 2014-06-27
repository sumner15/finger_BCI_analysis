clc; clear concatData; 

%subjects = {{'BECC'},{'DIAJ'},{'DIMC'},{'GUIR'},{'LURI'},{'NAVA'},...
%            {'NAZM'},{'POTA'},{'TRAD'},{'TRAT'},{'TRAV'},{'TRUS'}};
subjects = {{'TRAT'}};        

if (~exist('username','var'))
   username = input('Username: ','s'); 
end
        
for currentSub = 1:length(subjects)
    tic
    clear concatData selectData waveletData;
    subname = subjects{currentSub};   
    subname = subname{1};
    
    disp('-------------------------------------');
    disp(['Beginning data processing for ' subname]);
    disp('-------------------------------------');
    
    concatEnviro(username,subname);
    channelSelectEnviro(username,subname);
    waveletEnviro(username,subname);
    toc
end

clear subname concatData selectDat waveletData;

clc; clear concatData; 

%subjects = {{'BECC'},{'DIAJ'},{'DIMC'},{'GUIR'},{'LURI'},{'NAVA'},...
%            {'NAZM'},{'POTA'},{'TRAD'},{'TRAT'},{'TRAV'},{'TRUS'}};
subjects = {{'TRAT'}};        

if (~exist('username','var'))
   username = input('Username: ','s'); 
end
        
for currentSub = 1:length(subjects)
    tic
    clear ans concatData selectData waveletData;
    subname = subjects{currentSub};   
    subname = subname{1};
    
    disp('-------------------------------------');
    disp(['Beginning data processing for ' subname]);
    disp('-------------------------------------');
    
    concatEnviro(username,subname);
    clear ans concatData selectData waveletData
    channelSelectEnviro(username,subname);
    clear ans concatData selectData waveletData
    waveletEnviro(username,subname);
    toc
end

clear ans subname concatData selectData waveletData;

clc; clear concatData; 

subjects = {{'BECC'},{'TRUS'},{'DIMC'},{'GUIR'},{'LURI'},{'NAVA'},...
            {'NAZM'},{'TRAT'},{'TRAV'},{'POTA'},{'DIAJ'},{'TRAD'}};
%subjects = {{'TRAT'}};

if (~exist('username','var'))
   username = input('Username: ','s'); 
end

global waveletData;        

for currentSub = 1:length(subjects)
    tic
    clear ans concatData selectData waveletData;
    subname = subjects{currentSub};   
    subname = subname{1};
    
    disp('-------------------------------------');
    disp(['Beginning data processing for ' subname]);
    disp('-------------------------------------');
    
    
    concatEnviro(username,subname);
    clear ans concatData selectData
    channelSelectEnviro(username,subname);
    clear ans concatData selectData     
    waveletData = waveletEnviro(username,subname);   
    waveletData = SegFingerEnviro(username,subname,waveletData);
    intraSubject(username,subname,waveletData);
    plotSub(username,subname);
    toc
end
plotInterSub
sendEmail;

clear ans subname concatData selectData waveletData;

clc; clear concatData; 

%  subjects = {{'BECC'},{'TRUS'},{'DIMC'},{'GUIR'},{'LURI'},{'NAVA'},...
%              {'NAZM'},{'TRAT'},{'TRAV'},{'POTA'},{'DIAJ'},{'TRAD'}};
subjects = {{''}};

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
    
    
    concatTherapy(username,subname);
    clear ans concatData selectData
    channelSelectTherapy(username,subname);
    clear ans concatData selectData     
    waveletData = waveletTherapy(username,subname);   
    waveletData = SegFingerTherapy(username,subname,waveletData);
    intraSubjectTherapy(username,subname,waveletData);
    %plotSub(username,subname);    
    toc
end
%plotInterSub
sendEmail;

clear ans subname concatData selectData waveletData;

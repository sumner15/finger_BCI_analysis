clc; clear concatData; 

subjects = {{'AGUJ'}};
%       ,{'BROR'},{'CORJ'},{'CROD'},{'ESCH'},{'FLOA'},...
%               {'GONA'},{'HAAN'},{'JOHG'},{'LEUW'},{'NGUT'},{'RITJ'},...
%               {'SARS'},{'WHIL'},{'WILJ'},{'WRIJ'}};         
  
% SUBJECTS NOT YET WORKING (11/20/2014) ------------------------------- %         
%{'ARRS'},{'CHIB'},{'KILB'},{'LAMK'},{'LOUW'},{'MCCL'},{'MILS'},
%{'VANT'},{'YAMK'} 
%
% missing post (not yet done)
% {'ARRS'},{'CHIB'},{'MILS'}
% missing post (shouldn't be missing)
% {'KILB'},{'LAMK'}
% raw data split up (can be fixed)
% {'VANT'},{'YAMK'}
% problem with segmentation (index exceeds matrix
% {'LOUW'}
% problem with channelSelect/filtfilt
% {'MCCL'}
% --------------------------------------------------------------------- %

if (~exist('username','var'))
   username = input('Username: ','s'); 
end

tic
% concatenate data (only needs to be ran once)
concatBool = input('Would you like to Concatenate? Type y or n: ','s');
if concatBool == 'y'
    for currentSub = 1:length(subjects)       
        subname = subjects{currentSub};   
        subname = subname{1};

        disp('-------------------------------------');
        disp(['Data concatenation for ' subname]);
        disp('-------------------------------------');

        clear ans concatData selectData waveletData;
        concatTherapy(username,subname);    %note: saves to file
    end
end
% process all data
for currentSub = 1:length(subjects)
    subname = subjects{currentSub};   
    subname = subname{1};
    
    disp('-------------------------------------');
    disp(['Beginning data processing for ' subname]);
    disp('-------------------------------------');
    
    concatData = preProcessTherapy(username,subname);   clear ans
    waveletData = waveletTherapy(concatData);   
    waveletData = SegFingerTherapy(username,subname,waveletData);
    %intraSubjectTherapy(username,subname,waveletData);
    %plotSub(username,subname);        
end
%plotInterSub
toc
sendEmail;

clear ans subname concatData selectData waveletData;

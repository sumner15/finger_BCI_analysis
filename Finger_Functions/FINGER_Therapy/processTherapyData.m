clc; clear concatData; 

% ------ COMPLETED (01/28/2015 ---------------------------------------- %
% subjects =   {{'AGUJ'},{'BROR'},{'CORJ'},{'CROD'},{'ESCH'},{'FLOA'},...
%               {'GONA'},{'HAAN'},{'JOHG'},{'LEUW'},{'NGUT'},{'RITJ'},...
%               {'SARS'},{'WHIL'},{'WILJ'},{'WRIJ'}};     
%
% ------ COMPLETED (02/23/2015 ---------------------------------------- %
% subjects =   {{'ARRS'},{'CHIB'},{'KILB'},{'LAMK'},...
%               {'POOJ'},{'PRIJ'},{'VANT'},{'YAMK'}};
% --------------------------------------------------------------------- %
% ------ CLEANED   (05/05/2015 ---------------------------------------- %
% subjects =   {{'AGUJ'},{'BROR'},{'CORJ'},{'FLOA'},{'GONA'},{'HAAN'},{'JOHG'},...
%               {'KILB'},{'LAMK'},{'LEUW'},{'NGUT'},{'POOJ'},{'PRIJ'},{'RITJ'},...
%               {'SARS'},{'WHIL'},{'WILJ'},{'WRIJ'},{'YAMK'}}; 
% --------------------------------------------------------------------- %
%
% SUBJECTS NOT YET WORKING (02/23/2014) ------------------------------- %         
%{'LOUW'},{'MALJ'},...
%{'MCCL'},{'MILS'},
%
%{'CROD'},{'ESCH'}
%
% problem with segmentation (index exceeds matrix
% {'LOUW'}
% problem with channelSelect/filtfilt
% {'MCCL'}
% EXCLUDED
% {'MILS'} (corn-rows), {'CROD'} (too noisy)
% problem with cleaning (preprocessing ok)
% {'ESCH'} 
% --------------------------------------------------------------------- %

if (~exist('username','var'))
   username = input('Username: ','s'); 
end

concatBool = input('Would you like to Concatenate? Type y or n: ','s');
processBool = input('Would you like to Process? Type y or n: ','s');
computeBool = input('Would you like to Compute results? Type y or n: ','s');


%% concatenate data 
tic
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

%% process all data
if processBool == 'y'
    for currentSub = 1:length(subjects)
        subname = subjects{currentSub};   
        subname = subname{1};

        disp('-------------------------------------');
        disp(['Beginning data processing for ' subname]);
        disp('-------------------------------------');

        concatData = preProcessTherapy(username,subname);   clear ans
        waveletData = waveletTherapy(concatData);   
        waveletData = SegFingerTherapy(username,subname,waveletData);            
    end
end

%% compute results
if computeBool == 'y'
    clear concatData waveletData 
    disp('-------------------------------');
    disp(' Beginning results computation ');
    disp('-------------------------------');
   for currentSub = 1:length(subjects)
        subname = subjects{currentSub};   
        subname = subname{1};                       
        intraSubjectTherapy(username,subname);
   end
end

%% finish up
toc
sendEmail;
clear ans subname concatData selectData waveletData;

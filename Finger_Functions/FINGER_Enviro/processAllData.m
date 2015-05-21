clc; clear concatData; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Movement Anticipation and EEG: Implications for BCI-robot therapy
subjects = {{'BECC'},{'TRUS'},{'DIMC'},{'GUIR'},{'LURI'},{'NAVA'},...
            {'NAZM'},{'TRAT'},{'TRAV'},{'POTA'},{'DIAJ'},{'TRAD'}};
         
% Cleaned Movement and Anticipation subs (3/18/2015) note: skipping concat
% and preprocessing (channelselect) since that would overwrite the cleaning
% process
% subjects = {{'BECC'},{'TRUS'},{'DIMC'},{'GUIR'},{'LURI'},{'NAVA'},...
%             {'NAZM'},{'TRAT'},{'TRAV'}};

%  Emotiv study:
% subjects = {{'BECC'},{'POTA'},{'TRAT'},{'DIAJ'},{'NAVA'},{'TRAV'}};
% subjects = {{'POTA'},{'TRAT'},{'DIAJ'},{'NAVA'},{'TRAV'}};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (~exist('username','var'))
   username = input('Username: ','s'); 
end      

try
    for currentSub = 1:length(subjects)
        tic
        clear ans concatData selectData waveletData;
        subname = subjects{currentSub};   
        subname = subname{1};

        disp('-------------------------------------');
        disp(['Beginning data processing for ' subname]);
        disp('-------------------------------------');


        concatenatedData = concatEnviro(username,subname);
        clear ans concatData selectData    
        channelSelectEnviro(username,subname,concatenatedData);      
%         waveletData = waveletEnviro(username,subname);   
%         waveletData = SegFingerEnviro(username,subname,waveletData);
%         intraSubject(username,subname,waveletData);
    %     plotSub(username,subname);    
        toc
    end
%     plotInterSub
catch me
    sendEmail(false);
end
sendEmail(true);

clear ans subname concatData selectData waveletData;

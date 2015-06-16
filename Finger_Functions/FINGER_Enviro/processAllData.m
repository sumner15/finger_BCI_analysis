clc; clear; close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Movement Anticipation and EEG: Implications for BCI-robot therapy
% subjects = {{'BECC'},{'TRUS'},{'DIMC'},{'GUIR'},{'LURI'},{'NAVA'},...
%             {'NAZM'},{'TRAT'},{'TRAV'},{'POTA'},{'DIAJ'},{'TRAD'}};         

%  Emotiv study:
% subjects = {{'BECC'},{'POTA'},{'TRAT'},{'DIAJ'},{'NAVA'},{'TRAV'}};
subjects = {{'POTA'},{'TRAT'},{'DIAJ'},{'NAVA'},{'TRAV'}};
% subjects = {{'POTA'}};

% note: double check that setPathEnviro is set to proper study!!
%       emotiv study does not need concatenation

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (~exist('username','var'))
   username = input('Username: ','s'); 
end      

try    
    for currentSub = 1:length(subjects)
        tic
        clear ans concatData waveletData;
        subname = subjects{currentSub};   
        subname = subname{1};

        disp('-------------------------------------');
        disp(['Beginning data processing for ' subname]);
        disp('-------------------------------------');


%         concatenatedData = concatEnviro(username,subname);        
%         concatenatedData = channelSelectEnviro(username,subname,concatenatedData)
%         concatenatedData = channelSelectEnviro(username,subname);      
%         waveletData = waveletEnviro(username,subname,concatenatedData);   
%         waveletData = SegFingerEnviro(username,subname,waveletData);
%         intraSubject(username,subname,waveletData);
        plotSub(username,subname);    
        fprintf('Elapsed time: %3.2f minutes\n',toc/60);
    end
%     plotInterSub


    sendEmail(true);
catch me
    sendEmail(false);    
    fprintf(['error at ' me.stack.name ', line ' num2str(me.stack.line) '\n']);
    error(me.message);
end

clear ans subname concatData selectData waveletData;

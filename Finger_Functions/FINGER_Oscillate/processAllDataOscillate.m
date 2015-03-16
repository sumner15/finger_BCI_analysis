clear; close all; clc; 
subjects = {{'PASK'}};

if (~exist('username','var'))
   username = input('Username: ','s'); 
end

for currentSub = 1:length(subjects)
    tic    
    subname = subjects{currentSub};   
    subname = subname{1};
    
    disp('-------------------------------------');
    disp(['Beginning data processing for ' subname]);
    disp('-------------------------------------');
       
    subData = datToMatOscillate(username,subname); 
    subData = preProcessOscillate(subData);
    subData = segFingerOscillate(subData);    
    subData = fourierOscillate(subData);
    save(strcat(subname,'_subData'),'subData');
    %plotSubOscillate(username,subname);
    fprintf('\n'); toc
end
%sendEmail;
% clear; close all; clc; tic    
subjects = {'PASK'}; 

successBool = true;

if (~exist('username','var'))
   username = input('Username: ','s'); 
end

for currentSub = 1:length(subjects)    
    subname = subjects{currentSub};       
    
    disp('-------------------------------------');
    disp(['Beginning data processing for ' subname]);
    disp('-------------------------------------');
     
    try
    %     subData = datToMatOscillate(username,subname); 
    %     subData = preProcessOscillate(subData,true,username,subname);
        subData = segFingerOscillate(subData,false,username,subname);    
        subData = fourierOscillate(subData,true,username,subname);    
        plotSubOscillate(username,subname,subData);
        fprintf('\n'); toc
    catch me
        successBool = false;
    end
end
sendEmail(successBool);
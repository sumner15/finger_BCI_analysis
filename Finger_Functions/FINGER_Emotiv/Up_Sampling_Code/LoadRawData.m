%%                                             %%
% LoadRawData.m : Takes csv output              %
%    file from Emotiv EPOC testbench software   %
%    and formats it into a SAMPLESx15 array.    %
%                                               %
% Author: Camilo Aguilar                        %
%                                               %
% Modification History:                         %
% 01/13/15 CA Initial Version                   %               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function[RawData] = LoadRawData(Emotivfile,CHANNELS)       
    %LOAD DATA FROM A DIFERENT DIRECTORY
    newData = importdata(Emotivfile);
    RawData = newData.data;

    %GET RID OF FIRST TWO COLUMNS FROM CSV FILE
    for i=1:2
        RawData(:,1) = [];
    end
    
    %GET RID OF LAST 18 COLUMNS FROM CSV FILE
    for i = CHANNELS+1:33
        RawData(:,CHANNELS+1) = [];
    end
    
end
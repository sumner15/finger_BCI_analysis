%%                                             %%
% AddTrial.m : Receives a file name,            %
%              calls function to open CSV       %
%              calls function to interpolate    %
%              returns Channel Data and Marker D%
%                                               %
% Input:  file  : filename string               %
%         NEW_FS: new sampling freq             %
%         OLD_FS: old sampling freq             %
%         nChans: number of channels            %
% Output: ChannelData: NxCHANNELS matrix        %
%         MarkerData: Nx1 matrix with markers   %
%                                               %
% Author: Camilo Aguilar                        %
%                                               %
% Modification History:                         %
% 01/13/15 CA Initial Version                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 
function[ChannelData, MarkerData] = AddTrial(file, NEW_FS, OLD_FS,nChans) 

    SCALE_FOR_MARKERS = 100;
    
    %LOAD DATA    
    disp(['Loading:' file '...']);
    data = LoadRawData(file,nChans);
    disp('SUCCESS: Data Loaded');
    clear text

    %INTERPOLATE DATA
    disp('Interpolating Data...');
    up_data  = UpSampleData(data, NEW_FS, OLD_FS,nChans);
    disp('SUCCESS: Data Upsampled');
    clear data
    
    %SPLITTING UP CHANNEL/MARKER DATA 
    ChannelData = up_data(:,1:14)';
    MarkerData = up_data(:,15)';
    MarkerData = MarkerData * SCALE_FOR_MARKERS;
end
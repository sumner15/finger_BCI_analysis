%%                                             %%
%    UpSampleData.m :                           %
%    Takes SAMPLESx15 matrix with a frequency   %
%    and linearly interpolates the data to a    %
%    new sampling frequency                     %
%                                               % 
% Input: NxM matrix (N samples, M channels)     %
% Output: SxM UpSampledData matrix              %
% Author: Camilo Aguilar                        %
%                                               %
% Modification History:                         %
% 01/13/15 CA Initial Version                   % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function up_sampled_data = UpSampleData(in_data,NEW_FS,OLD_FS,nChans)  
    %channel size check
    if size(in_data,2) ~= (nChans+1)
        error('channel space doesn''t match');
    end

    %NEW POINTS FOR UPSAMPLED VECTOR
    nSampsIn = size(in_data,1);
    nSampsOut = nSampsIn*NEW_FS/OLD_FS;
    new_points = linspace(1,nSampsIn,nSampsOut);
    
    %INTERPOLATE COLUMNS ONE BY ONE
    up_sampled_data = NaN(nSampsOut,nChans);
    for currentChan = 1:(nChans+1)
        channelVector = in_data(:,currentChan);
        up_sampled_data(:,currentChan) = interp1(channelVector, new_points,'spline')';
    end    
end
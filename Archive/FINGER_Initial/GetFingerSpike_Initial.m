function [spike_loc] = GetFingerSpike_Initial(markers)
%[spike_loc] = GetFingerSpike(markers)
%
% Returns a vector of the sample at which the note passed over the goal
% line

[~,loc1] = findpeaks(double(markers.GuitarString1TimeToNote));
[~,loc2] = findpeaks(double(markers.GuitarString2TimeToNote));
[~,loc3] = findpeaks(double(markers.GuitarString3TimeToNote));

spike_loc = sort(cat(1,loc1,loc2,loc3));

spike_loc(1:3) = [];
%%                                   %%
% EmotivHeadModel.m: Emotiv Head Model%
%                                     %
% Modification History:               %
% 04/08/15 OS Initial Version         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%Specs
%load('egihc256redhm');

%%
%Common Variables
close all;
%Emotiv Positions:AF3, F7, F3, FC5, T7, P7, O1, O2, P8, T8, FC6, F4, F8,AF4
%Hydrocel Mapping: 34, 47, 36,  49, 69, 96,116,150,170,202, 213,224,  2, 12
emotivPositions = [2, 12, 34, 36, 47, 49, 69, 96,116,150,170,202, 213,224];

% rename data here according to emotiv/geodesic specifically
EGIHC256RED
eval(['EMOTIV14RED =' 'EGIHC256RED']);
EMOTIV14RED.ChansUsed = emotivPositions;

%Find which indices in current egi headmodel correspond to emotiv positions
%We know that the electrodes we want already exist in the egi model and are
%being used
%Output: Logical Array
egiIndices = zeros(size(EGIHC256RED.ChansUsed,2), 1);
unusedElec = [];
for i = 1:size(EGIHC256RED.ChansUsed,2)
    count = 0;
    for j = 1:size(emotivPositions,2);
        if EGIHC256RED.ChansUsed(1,i) == emotivPositions(j)
            egiIndices(i,1) = 1;
            count = 1;
        end
    end
    if count == 0
        unusedElec = [unusedElec i];
    end
end

%Only keep the electrodes from emotiv
EMOTIV14RED.Electrode.CoordOnSphere = EMOTIV14RED.Electrode.CoordOnSphere(egiIndices == 1,:);
EMOTIV14RED.Electrode.Coord2D = EMOTIV14RED.Electrode.Coord2D(egiIndices == 1,:);

%Append unused electrodes
EMOTIV14RED.ChansDeleted = [EMOTIV14RED.ChansDeleted unusedElec];

%Change Scaling Factor to fit model
EMOTIV14RED.Electrode.Scaling2D = 2.3;
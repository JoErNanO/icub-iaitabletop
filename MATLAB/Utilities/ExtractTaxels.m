function [res] = ExtractTaxels(data, finger)
%EXTRACTTAXELS Extracts the skin value corresponding to the given finger
%thus removing other values from the data array.
%
% Input:
%           data - data structure with the following fields:
%               hand - string identifying the hand 'left' or 'right'
%               trial - trial number
%               ft - data from the Force/Torque sensor embodied in the arm
%               nano - data from the external Nano17 Force/Torque sensor
%               pos - data from the robot hand position encoders
%               skin - data from the robot hand skin sensors
%               wbd - data from the WholeBodyDynamics wrench calculation
%
%           finger - integer identifing the finger
%                       0 - Index,      1 - Middle,     2 - Ring,       3 - Little,     4 - Thumb
%
% Output:
%       
%       res - result data structures with the following fields:
%               hand - string identifying the hand 'left' or 'right'
%               trial - trial number
%               ft - data from the Force/Torque sensor embodied in the arm
%               nano - data from the external Nano17 Force/Torque sensor
%               pos - data from the robot hand position encoders
%               skin - data from the robot hand skin sensors
%               wbd - data from the WholeBodyDynamics wrench calculation

%% Find taxels corresponding to finger
taxelIndex = finger*12+3:finger*12+14;
% Extract skin data and for those taxels only
data.skinRaw = data.skinRaw(:, [1, taxelIndex]);
data.skinComp = data.skinComp(:, [1, taxelIndex]);

%% Build result structure
res = data;

end


function [ res ] = GenerateExperimentParamsSpatialResolutionLinearPath(fitType)
%GENERATEEXPERIMENTPARAMSSPATIALRESOLUTIONLINEARPATH Generate the parameters for the
%spatial resolution experimentand stores them in an experiment descriptor
%file (.ini).
%
%
% INPUT:
%       taxel - string representing the taxel on which to press. Can be 
%           either 'L' or 'R'
%
% OUTPUT:
%       res - m-by-n array of experiment parameters where m is the number
%           of steps and n is the number of parameters for each step
%


%% Fingertip parameters
% Slope angle for point of fingertip '''\
theta = 53.7;
% Lookup table for y and z - this was measured empirically
coords = zeros(15, 2);
coords(1, :) = [77816, 88560];
coords(2, :) = [76816, 88560];
coords(3, :) = [75816, 88560];
coords(4, :) = [74816, 88560];
coords(5, :) = [73816, 88760];
coords(6, :) = [72816, 88760];      % End of taxel 1
coords(7, :) = [71816, 88860];
coords(8, :) = [70816, 89060];
coords(9, :) = [69816, 89160];
coords(10, :) = [68816, 89360];     % End of taxel 2
coords(11, :) = [67816, 89760];
coords(12, :) = [66816, 90060];
coords(13, :) = [65816, 90560];
coords(14, :) = [64816, 91060];
coords(15, :) = [63816, 92460];

%% Experiment parameters
% Position time
t = 15;
% Velocity
vel.x = 20;
vel.y = 20;
vel.z = 20;
% Acceleration
acc.x = 20;
acc.y = 20;
acc.z = 20;
% Deceleration
dec.x = 20;
dec.y = 20;
dec.z = 20;

% Total length
totLength = 12000;

% Starting positions
start.x = 20224;


%% Extract fitting type
if strcmp(fitType, 'exp1')
    FitFn = @FitFnExp1;
elseif strcmp(fitType, 'exp2')
    FitFn = @FitFnExp2;
elseif strcmp(fitType, 'linearinterp')
    FitFn = @FitFnLinearInterp;
elseif strcmp(fitType, 'cubicinterp')
    FitFn = @FitFnCubicInterp;
elseif strcmp(fitType, 'power1')
    FitFn = @FitFnPower1;
elseif strcmp(fitType, 'power2')
    FitFn = @FitFnPower2;
elseif strcmp(fitType, '')
    fprintf('No fitting function specified. Using measured fingertip parameters. \n');
else
    erorr('GenerateSpatialResolutionExperimentParams:UnknownFitType', ['Cannot process the specified fit type: ', fitType, '.']);
end
    
    

% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate path coordinates with lookup table
% Depth
maxDepth = 400;
depth.increment = 50;
depth.steps = maxDepth / depth.increment;
% Path
path.length = 1000;
path.increment = 100;
path.direction = 'decr';
steps = cell(size(coords, 1), 1);
for i = 1:size(coords, 1)
    % Get starting y and x from lookup table
    path.start = coords(i, 1);
    depth.start = coords(i, 2);
    
    % Generate steps
    steps{i} = GenerateSpatialResolutionPath(path, depth);
end

%% Store full path
pathCoordinates = cell2mat(steps);
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% %% Step 1 - first 2 taxels
% % Depth
% depth.start = 88560;
% depth.steps = 4;
% depth.increment = 100;
% % Path
% path.start = 77816;
% path.length = 2000;
% path.increment = 100;
% 
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Generate path coordinates
% step1 = GenerateSpatialResolutionPath(path, depth);
% 
% %% Step 2 - all other taxels
% chunkSize = 1000;
% steps = cell((totLength - path.length) / chunkSize + 1,1);
% steps{1} = step1;
% for i = 2:size(steps, 1)
%     % Depth
%     depth.start = 88560 + (2 * i * depth.increment);
%     depth.steps = 4;
%     depth.increment = 100;
%     % Path
%     path.start = path.start - path.length;
%     path.length = chunkSize;
%     path.increment = 100;
%     
%     steps{i} = GenerateSpatialResolutionPath(path, depth);
% end
% 
% pathCoordinates = cell2mat(steps);
%     

% %% Step 2 - last taxel has a curved surface
% % Depth
% % depth2.start = depth.start;
% depth2.start = 88660;
% depth2.steps = 4;
% depth2.increment = 100;
% % Path
% path2.start = step1(end, 1) - path.increment;
% % path2.length = totLength - path.length;
% path2.increment = 100;
% path2.length = path2.increment;
% path2.pos = path2.start:path2.increment:(path2.start + totLength - path.length);       % Vector of Y positions to be reached during step 2
% 
% deltaY = 0;
% ndepths = depth2.steps*2 + 1;
% step2 = zeros(numel(path2.pos) * ndepths, 2);
% j = 1;
% for i = 1:numel(path2.pos)
%     % Increment depth proportionally to fingertip slope
% %     depth2.start = round(depth2.start + (deltaY * tan(theta)));
%     depth2.start = round(depth2.start + FitFn(deltaY))
%     step2(j:1:j+ndepths-1, :) = GenerateSpatialResolutionPath(path2, depth2);
%     j = j + ndepths;
%     deltaY = i * path2.increment;
%     path2.start = path2.start - path2.increment;
% end
% 
% 
% %% Store full path
% pathCoordinates = zeros(size(step1, 1) + size(step2, 1), 2);
% pathCoordinates(1:size(step1, 1), :) = step1;
% pathCoordinates(size(step1, 1)+1:end, :) = step2;
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Full path is generated using fitting!
% path.length = path.increment;
% % Vector of y positions
% path.pos = path.start:path.increment:(path.start + totLength);
% deltaY = 0;
% ndepths = depth.steps*2 + 1;
% step = zeros(numel(path.pos) * ndepths, 2);
% j = 1;
% for i = 1:numel(path.pos)
%     % Increment depth proportionally to fingertip slope
% %     depth2.start = round(depth2.start + (deltaY * tan(theta)));
%     depth.start = round(depth.start + FitFnExp1(deltaY))
%     step(j:1:j+ndepths-1, :) = GenerateSpatialResolutionPath(path, depth);
%     j = j + ndepths;
%     deltaY = i * path.increment;
%     path.start = path.start - path.increment;
% end
% 
% 
% %% Store full path
% pathCoordinates = step;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Initialise result structure
res = zeros(size(pathCoordinates, 1) + 1, 13);
% Add no load step to compute baseline
res(1, :) = [start.x, pathCoordinates(1, 1), pathCoordinates(1, 2) - 400, vel.x, vel.y, vel.z, acc.x, acc.y, acc.z, dec.x, dec.y, dec.z, 15];
res(2:end, 1) = 20224;
res(2:end, 2:3) = pathCoordinates;
res(2:end, 4:end) = repmat([vel.x, vel.y, vel.z, acc.x, acc.y, acc.z, dec.x, dec.y, dec.z, t], size(res, 1) - 1, 1);


%% Store data in file
GenerateExperimentDescriptorFile('confIAITableTopExperiment-ReceptiveField-LinearPath.ini', res, 'recfield');


end


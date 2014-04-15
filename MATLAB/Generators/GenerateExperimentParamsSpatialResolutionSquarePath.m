function res = GenerateExperimentParamsSpatialResolutionSquarePath()

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


%% Set x and y
x = 18700:1000:27700;
y = 70536:1000:76536;
zx = [92600, 92000, 91800, 91600, 91300, 91300, 91500, 91800, 92300, 93100; ...
    92700, 91800, 91400, 91300, 91300, 91200, 91500, 91600, 91900, 92200];
zy = [92200, 92000, 92100, 92500, 92400, 92400, 92800; ...
    93300, 93000, 93000, 93000, 93000, 93000, 92700];



%% Declare path steps arrays
nlsl = zeros(numel(x), 3);
slsr = zeros(numel(y), 3);
srnr = zeros(size(nlsl));
nrnl = zeros(size(slsr));


%% Set arrays
nlsl(:, 1) = x; nlsl(:, 2) = y(end); nlsl(:, 3) = zx(1, :);
slsr(:, 1) = x(end); slsr(:, 2) = sort(y, 'descend'); slsr(:, 3) = zy(2, :);
srnr(:, 1) = sort(x, 'descend'); srnr(:, 2) = y(1); srnr(:, 3) = zx(2, :);
nrnl(:, 1) = x(1); nrnl(:, 2) = y; nrnl(:, 3) = zy(1, :);
exploration = {nlsl, slsr, srnr, nrnl};

% %% Plot path
% figure(1);
% clf;
% 
% plot3(nlsl(:, 2), nlsl(:, 1), nlsl(:, 3), '.');
% hold all;
% plot3(slsr(:, 2), slsr(:, 1), slsr(:, 3), '.');
% plot3(srnr(:, 2), srnr(:, 1), srnr(:, 3), '.');
% plot3(nrnl(:, 2), nrnl(:, 1), nrnl(:, 3), '.');
% set(gca, 'YDir', 'reverse');
% set(gca, 'XDir', 'reverse');
% 
% legend({'NL -> SL', 'SL -> SR', 'SR -> NR', 'NR -> NL'}, 'Location', 'Best');


% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate path coordinates with lookup table
% Depth
maxDepth = 400;
depth.increment = 50;
depth.steps = maxDepth / depth.increment;
% Path
path.length = 1000;
path.increment = 100;
pathCoordinates = cell(numel(exploration), 1);
for j = 1:numel(exploration)
    % Generate depth profiles for all substeps in the current step
    steps = cell(size(exploration{j}, 1), 1);
    for i = 1:size(exploration{j}, 1)
        % Get starting x y z from lookup table
        if mod(j, 2) == 0
            % Change y
            path.start = exploration{j}(i, 2);
            val = exploration{j}(i, 1);
        else
            % Change x
            path.start = exploration{j}(i, 1);
            val  = exploration{j}(i, 2);
        end
        depth.start = exploration{j}(i, 3);
        
        % Get path direction
        switch j
            case 1
                path.direction = 'incr';
            case 2
                path.direction = 'decr';
            case 3
                path.direction = 'decr';
            case 4
                path.direction = 'incr';
        end

        % Generate steps
        tmpPath = GenerateSpatialResolutionPath(path, depth);
        if mod(j, 2) == 0
            % Change y
            steps{i} = [repmat(val, size(tmpPath, 1), 1), tmpPath];
        else
            % Change x
            steps{i} = [tmpPath(:, 1), repmat(val, size(tmpPath, 1), 1), tmpPath(:, 2)];
        end
    end
    
    % Store tmp path
    pathCoordinates{j} = cell2mat(steps);
end

%% Store full path
fullpath = cell2mat(pathCoordinates);
clear pathCoordinates;


%% Initialise result structure
res = zeros(size(fullpath, 1) + 1, 13);
% Add no load step to compute baseline
res(1, :) = [fullpath(1, 1), fullpath(1, 2), fullpath(1, 3) - 400, vel.x, vel.y, vel.z, acc.x, acc.y, acc.z, dec.x, dec.y, dec.z, 15];
res(2:end, 1:3) = fullpath;
res(2:end, 4:end) = repmat([vel.x, vel.y, vel.z, acc.x, acc.y, acc.z, dec.x, dec.y, dec.z, t], size(res, 1) - 1, 1);


%% Store data in file
GenerateExperimentDescriptorFile('confIAITableTopExperiment-ReceptiveField-SquarePath.ini', res, 'recfield');

% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
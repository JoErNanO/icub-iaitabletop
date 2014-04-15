function SaveTableTopPlots(trialRange, expType, imgType)
%SAVEFINGERTIPSPLOTS Loads, generates the plots and saves the figures of
%the given trial.
%
% Input:
%
%       trialRange - the range of trials. Can be either a single trial or a
%                   vector in the form start:end (for example 2:4)
%
%       expType - string representing the type of trial. Accepted values are 'progdepth',
%           'recfield'.
%
%       imgType - string representing the file type to use when saving the
%           image. Accepted values are 'png', 'fig', 'pngfig'.
%


%% Check input parameters
% Trial range
if isempty(trialRange)
    error('SaveTableTopPlots:InvalidTrialRange', ['Cannot save the plots for the given trial range.']);
end
% Experiment type
if ~(strcmpi(expType, 'progdepth') || strcmpi(expType, 'recfield'))
    error('SaveTableTopPlots:UnknownExperimentType', ['Cannot save the plots for the given trial type: ', expType, '.']);
end
% Image type
% Build parser
p = inputParser;
defaultImg = 'png';
validImg = {'png', 'fig', 'pngfig'};
checkImg = @(x) any(validatestring(x, validImg));
addOptional(p, 'Img', defaultImg, checkImg);
% Parse
parse(p, imgType);
% if ~(strcmpi(imgType, 'png') || strcmpi(imgType, 'fig'))
%     error('SaveTableTopPlots:UnknownImageType', ['Cannot save the plots in the given image file type: ', imgType, '.']);
% end


%% Create directories if needed
dirpath = ['Images'];
if ~exist(dirpath, 'dir')
    mkdir(dirpath)
end


%% Load and plot data in the given trial range
for plot = 1:size(trialRange, 2)
    %% Load and plot data
    PlotTableTopAll(trialRange(plot), expType, 'Visible', 'off', 'Filter', 'on', 'PosAxis', 'z');
    
    %% Save plots
    fprintf('Saving plots as images. \n');
    trialpath = ['/trial_', sprintf('%05d', trialRange(plot))];
    filepath = [dirpath, trialpath];
    if ~exist(filepath, 'dir')
        mkdir(filepath);
    end
    
    % Save to file
	if strcmp(expType, 'progdepth')
        imgPath = {[filepath '/SkinNano17'], [filepath '/Hystheresis'], [filepath '/SkinPos']};
	elseif strcmp(expType, 'recfield')
        imgPath = {[filepath '/SkinNano17'], [filepath '/ReceptiveField']};
    end
    
    % Pick right filetype
    if strcmp(p.Results.Img, 'png')
        SaveTableTopPlotsPNG(imgPath);
    elseif strcmp(p.Results.Img, 'fig')
        SaveTableTopPlotsFIG(imgPath);
    elseif strcmp(p.Results.Img, 'pngfig')
        SaveTableTopPlotsPNG(imgPath);
        SaveTableTopPlotsFIG(imgPath);
    end
    
    fprintf('Done. \n');
end
end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save the plots as PNG
function SaveTableTopPlotsPNG(path)
%SAVETABLETOPPLOTSPNG Save the plots as PNG format.
    %% Output image parameters
    r = 150; % pixels per inch
    imgSize = [0 0 2000 1080];

    %% Loop all paths and save the images
    for i = 1:size(path, 2)
        set(i, 'PaperUnits', 'inches', 'PaperPosition', imgSize ./ r);
        print(i, ['-d', 'png'], path{i}, sprintf('-r%d',r));
    end
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save the plots as FIG
function SaveTableTopPlotsFIG(path)
%SAVETABLETOPPLOTSFIG Save the plots as FIG format.
    %% Loop all paths and save the images
    for i = 1:size(path, 2)
            saveas(i, path{i}, 'fig');
    end
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%This script sets visual stimulus parameters, determines a random order of
%presentation, and sends display commands to the MouseGoggles monocular
%display. 
%list of experiment names
%rfm0 (12.5 mins)
%d0 (6 mins)
%t0 (8 mins)
%c0


%% open connection to controller
clear vs %clear "vis-struct"
vs.port = 'COM3'; %change this to whichever COM port the monocular display is connected to (use serialportlist("available") to see COM ports)
vs.directory = 'C:\Users\VR2 V1 imaging\mouse1'; %set this to the desired save directory
vs = teensyComm(vs, 'Connect');


%% set experiment parameters
vs.expname = 'VR2_1'; %name of experiment
vs.trial_duration = 4; %duration of next trial
vs.randomize = 1; %1=randomize order of conditions, 0=don't randomize

% for tuning experiments
angles = 0:30:330; %degrees, for direction tuning (default is primary_angle, below)
frequencies = [0.5 1 2 4 8 12]; %Hz, for temporal frequency tuning (default is 1)
contrasts = 0:20:80; %percent, for sontrast tuning (default is 100)
barwidths = [2 5 10 20 40]; %width of bright/dark bars in gratings, for spatial frequency tuning (default is 20)
primary_angle = 90;

% for receptive field mapping
positions_x_0 = [-24 -12 0 12 24]; %x position (in pixels) for centers of grid stimuli
positions_x_60 = [36 48 60 72 84]; %alternative x positions (unused)
positions_y = [-24 -12 0 12 24]; %y position (in pixels) for centers of grid stimuli

% set starting/default grating parameters
param.patterntype = 1; %1 = square-gratings, 2 = sine-gratings, 3 = flicker
param.bar1color = [0 0 30]; %RGB color values of bar 1 [R=0-31, G=0-63, B=0-31]
param.bar2color = [0 0 0]; %RGB color values of bar 2
param.backgroundcolor = [0 0 15]; %RGB color values of background
param.barwidth = 20; % width of each bar (pixels)
param.numgratings = 1; % number of bright/dark bars in grating
param.angle = primary_angle; % angle of grating (degrees) [0=drifting right, positive angles rotate clockwise]
param.frequency = 1; % temporal frequency of grating (Hz) [0.1-25]
param.position = [0,0]; % x,y position of grating relative to display center (pixels)
param.predelay = 0; % delay after start command sent before grating pattern begins (s) [0.1-25.5]
param.duration = 1; % duration that grating pattern is shown (s) [0.1-25.5]
param.trigger = 0; % tells the teensy whether to wait for an input trigger signal (TTL) to start or not

defaultparam = param;


%% search for active neurons at [0,0] [gratings]
%this section is used to periodically send small grating stimuli while V1 is
%being navigated with the live view of the microscope to find active
%neurons with receptive fields roughly positioned in the center of the
%stimlus window

param = defaultparam;
param.barwidth = 12;
param.numgratings = 1;
parame.frequency = 1;
param.angle = 0;
param.duration = 1;
param.position = [0, 0];
vs.trial_duration = 6;
cbx = uicheckbox('Position',[200 200 200 200]);
cbx.Text = 'check when done';
while 1
    for a = [90 180 270 0]
        param.angle = a;
        tic
        vs = teensyComm(vs, 'Start-Pattern', param); %send pattern parameters and display the pattern
        fprintf(['grating ' num2str(a) ' deg\n']);
        while toc<vs.trial_duration %delay until next trial
            pause(0.001);
        end
        vs = teensyComm(vs, 'Get-Data'); %retrieve data sent from teensy about displayed pattern
        if cbx.Value
            cbx.Text = 'complete';
            return;
        end
    end
end



%% run receptive field mapping around [0,0] ~12.5 mins
%after a good FOV of active neurons has been found, this section displays
%stimuli for receptive field mapping, presenting small bar sweeps (half of
%a drifting grating) in one of 25 (5x5) areas of a grid, presented in a
%random order

param = defaultparam;
param.barwidth = 6;
param.numgratings = 1;
param.frequency = 1;
param.angle = 0;
param.duration = 0.5;
param.position = [0, 0];
vs.trial_duration = 6;
vs.num_reps = 5;
order_of_positions_0 = [repmat(positions_x_0',[5 1]), kron(positions_y',ones(5,1))];
vs.num_trials = length(order_of_positions_0);

full_order_of_positions_0 = nan(vs.num_trials,2,vs.num_reps);

fprintf([num2str(vs.num_trials) ' trials, ' num2str(vs.trial_duration) ' s duration, ' num2str(vs.num_reps) ' reps (' num2str(vs.num_reps*vs.num_trials*vs.trial_duration/60) ' mins)\n']);
for rep = 1:vs.num_reps
    trial_order = 1:vs.num_trials;
    if vs.randomize==1
        trial_order = randperm(vs.num_trials);
    end
    order_of_positions_0 = order_of_positions_0(trial_order,:);
    full_order_of_positions_0(:,:,rep) = order_of_positions_0;
    fprintf(['rep ' num2str(rep) '\n']);

    for t = 1:vs.num_trials
        param.position = order_of_positions_0(t,:);
        fprintf(['position [' num2str(param.position) '], angle ' num2str(param.angle) '\n']);

        tic
        param.angle = 90;
        vs = teensyComm(vs, 'Start-Pattern', param); %send pattern parameters and display the pattern
        pause(param.duration);
        param.angle = 180;
        vs = teensyComm(vs, 'Start-Pattern', param); %send pattern parameters and display the pattern
        pause(param.duration);
        param.angle = 270;
        vs = teensyComm(vs, 'Start-Pattern', param); %send pattern parameters and display the pattern
        pause(param.duration);
        param.angle = 0;
        vs = teensyComm(vs, 'Start-Pattern', param); %send pattern parameters and display the pattern

        while toc<vs.trial_duration %delay until next trial
            pause(0.001);
        end
        vs = teensyComm(vs, 'Get-Data'); %retrieve data sent from teensy about displayed pattern
    end
end


%% run direction tuning
%this section displays stimuli for direction tuning, presenting a large
%drifting grating rotated at many angles, presented in a random order

param = defaultparam;
param.barwidth = 20;
param.numgratings = 2;
parame.frequency = 1;
param.angle = primary_angle;
param.duration = 1;
param.position = [0, 0];
vs.trial_duration = 6;
vs.num_reps = 5;
order_of_angles_dir = angles;
vs.num_trials = length(order_of_angles_dir);
full_order_of_angles_dir = nan(vs.num_trials,vs.num_reps);

fprintf([num2str(vs.num_trials) ' trials, ' num2str(vs.trial_duration) ' s duration, ' num2str(vs.num_reps) ' reps (' num2str(vs.num_reps*vs.num_trials*vs.trial_duration/60) ' mins)\n']);

for rep = 1:vs.num_reps
    trial_order = 1:vs.num_trials;
    if vs.randomize==1
        trial_order = randperm(vs.num_trials);
    end
    order_of_angles_dir = order_of_angles_dir(trial_order);
    full_order_of_angles_dir(:,rep) = order_of_angles_dir;
    
    for t = 1:vs.num_trials
        param.angle = order_of_angles_dir(t);
        fprintf(['rep ' num2str(rep) ' angle ' num2str(param.angle) '\n']);
        tic
        vs = teensyComm(vs, 'Start-Pattern', param); %send pattern parameters and display the pattern
%         fprintf(['position [' num2str(param.position) '], angle ' num2str(param.angle) '\n']);
        while toc<vs.trial_duration %delay until next trial
            pause(0.001);
        end
        vs = teensyComm(vs, 'Get-Data'); %retrieve data sent from teensy about displayed pattern
    end
end


%% run contrast, spatial, and frequency tuning along 1 direction
%this section runs a combined protocol for contrast tuning, spatial
%frequency tuning, and temporal frequency tuning, using a single direction
%of a drifting grating. Stimuli are presented in a random order

param = defaultparam;
param.barwidth = 20;
param.numgratings = 2;
param.frequency = 1;
param.angle = primary_angle;
param.duration = 2;
param.position = [0, 0];
vs.trial_duration = 8;
vs.num_reps = 5;
%tuning_types = [1 2 3] = [contrast, spatial, frequency]
order_of_tuning_values = [contrasts barwidths frequencies];
order_of_tuning_types = [ones(size(contrasts)) 2*ones(size(barwidths)) 3*ones(size(frequencies))];
vs.num_trials = length(order_of_tuning_types);
full_order_of_tuning_values = nan(vs.num_trials,vs.num_reps);
full_order_of_tuning_types = nan(vs.num_trials,vs.num_reps);
contrasts = 0:20:80;
% [0=15/15, 20=12/18, 40=9/21, 60=6'24, 80=3/27]
lowvals = [15 12 9 6 3];
highvals = [15 18 21 24 27];
fprintf([num2str(vs.num_trials) ' trials, ' num2str(vs.trial_duration) ' s duration, ' num2str(vs.num_reps) ' reps (' num2str(vs.num_reps*vs.num_trials*vs.trial_duration/60) ' mins)\n']);

for rep = 1:vs.num_reps
    trial_order = 1:vs.num_trials;
    if vs.randomize==1
        trial_order = randperm(vs.num_trials)
    end
    order_of_tuning_values = order_of_tuning_values(trial_order);
    order_of_tuning_types = order_of_tuning_types(trial_order);
    
    full_order_of_tuning_values(:,rep) = order_of_tuning_values';
    full_order_of_tuning_types(:,rep) = order_of_tuning_types';
    
    for t = 1:vs.num_trials
        if order_of_tuning_types(t)==1
            c = order_of_tuning_values(t);
            cind = find(contrasts==c);
            param.bar1color = [0 0 highvals(cind)];
            param.bar2color = [0 0 lowvals(cind)];
            param.barwidth = 20;
            param.numgratings = 2;
            param.frequency = 1;
            fprintf(['rep ' num2str(rep) ' contrast ' num2str(c) '\n']);
        elseif order_of_tuning_types(t)==2
            param.bar1color = [0 0 30];
            param.bar2color = [0 0 0];
            param.backgroundcolor = [0 0 15];
            param.barwidth = order_of_tuning_values(t);
            param.numgratings = 40/param.barwidth;
            param.frequency = 1;
            fprintf(['rep ' num2str(rep) ' barwidth ' num2str(param.barwidth) ' pixels\n']);
        else
            param.bar1color = [0 0 30];
            param.bar2color = [0 0 0];
            param.barwidth = 20;
            param.numgratings = 2;
            param.frequency = order_of_tuning_values(t);
            fprintf(['rep ' num2str(rep) ' frequency ' num2str(param.frequency) ' Hz\n']);
        end
        tic
        vs = teensyComm(vs, 'Start-Pattern', param); %send pattern parameters and display the pattern
        while toc<vs.trial_duration %delay until next trial
            pause(0.001);
        end
        vs = teensyComm(vs, 'Get-Data'); %retrieve data sent from teensy about displayed pattern
    end
end



%% run RGB test
%this section display flickers in red, green, and blue colors, which can be
%used to measure light contamination levels into different imaging color
%channels

param = defaultparam;
param.patterntype = 3; %1 = square-gratings, 2 = sine-gratings, 3 = flicker
param.barwidth = 80; % width of each bar (pixels)
param.numgratings = 1; % number of bright/dark bars in grating
param.duration = 3;

%red
param.bar1color = [30 0 0]; %RGB color values of bar 1 [R=0-31, G=0-63, B=0-31]
param.bar2color = [0 0 0]; %RGB color values of bar 2
param.backgroundcolor = [15 0 0]; %RGB color values of background
vs = teensyComm(vs, 'Start-Pattern', param); %send pattern parameters and display the pattern
pause(4);
vs = teensyComm(vs, 'Get-Data'); %retrieve data sent from teensy about displayed pattern

%green
param.bar1color = [0 60 0]; %RGB color values of bar 1 [R=0-31, G=0-63, B=0-31]
param.bar2color = [0 0 0]; %RGB color values of bar 2
param.backgroundcolor = [0 30 0]; %RGB color values of background
vs = teensyComm(vs, 'Start-Pattern', param); %send pattern parameters and display the pattern
pause(4);
vs = teensyComm(vs, 'Get-Data'); %retrieve data sent from teensy about displayed pattern

%blue
param.bar1color = [0 0 30]; %RGB color values of bar 1 [R=0-31, G=0-63, B=0-31]
param.bar2color = [0 0 0]; %RGB color values of bar 2
param.backgroundcolor = [0 0 15]; %RGB color values of background
vs = teensyComm(vs, 'Start-Pattern', param); %send pattern parameters and display the pattern
pause(4);
vs = teensyComm(vs, 'Get-Data'); %retrieve data sent from teensy about displayed pattern



%% save data for current experiment
filename = [datestr(now,'yyyy-mm-dd HH-MM-SS') ' ' vs.expname ' vs.mat'];
if ~exist(vs.directory,'dir')
    [pathstr,newfolder,~] = fileparts(vs.directory);
    mkdir(pathstr,newfolder);
end
trial_orders.full_order_of_positions_0 = full_order_of_positions_0;
trial_orders.full_order_of_angles_dir = full_order_of_angles_dir;
trial_orders.full_order_of_tuning_values = full_order_of_tuning_values;
trial_orders.full_order_of_tuning_types = full_order_of_tuning_types;
save(fullfile(vs.directory,filename),'vs','trial_orders');


%% close connection
vs = teensyComm(vs, 'Disconnect'); %close connection to controller


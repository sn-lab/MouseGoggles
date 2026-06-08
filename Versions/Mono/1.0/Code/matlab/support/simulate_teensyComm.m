function vs = simulate_teensyComm(vs, command, param)
% FUNCTION vs = simulate_teensyComm(vs, command, param)
%
% Function to simulate the Teensy display behavior in MATLAB using figures.
% Accepts the same parameters as teensyComm but displays patterns in a MATLAB figure
% instead of communicating with hardware. 
%
% Note: Drawing in Matlab is much slower than drawing on the Teensy display, 
% so you will see more hiccups and many more dropped frames in this simulation. 
% The best way to see what how a stimulus actually looks on the display is 
% to look at the real display!
%
% LIST OF COMMANDS:
% 'Connect': opens simulated display in a figure window
% 'Disconnect': closes the figure window
% 'Start-Pattern': display pattern with current parameters (same as teensyComm)
% 'Send-Parameters': sets next pattern parameters (same as teensyComm)
% 'Reset-Background': fills screen with last used background color
% 'Get-Data': return simulated data (same structure as teensyComm)
% 'Demo-On': runs demo sequence
% 'Demo-Off': turns off demo mode
%
% INPUTS:
% vs: "vis-struct", container for teensy and data info
% command: instruction which tells matlab what to do next
% param: parameters of pattern to be displayed (only used for 'Start-Pattern' and 'Send-Parameters')

fprintf('!simulated display - timing is not accurate!\n')

    switch command
        case 'Connect'
            % Initialize figure and display parameters
            vs.fig_handle = figure('Name', 'Teensy Display Simulator', ...
                'NumberTitle', 'off', ...
                'Position', [100 100 480 420]); % Scale 2x for visibility
            
            % Create axes for display
            vs.ax_handle = axes('Parent', vs.fig_handle, ...
                'Position', [0.1 0.15 0.8 0.75], ...
                'XLim', [0 210], ...
                'YLim', [0 240], ...
                'YDir', 'reverse', ...
                'DataAspectRatio', [210 240 1], ...
                'Box', 'on');
            
            % Initialize data structure
            vs.data = [];
            vs.datanames = {};
            vs.starttime_num = now;
            vs.starttime_str = datestr(now, 'dd-mm-yyyy HH:MM:SS FFF');
            vs.programversion = 9307.1;
            
            % Initialize pattern parameters with defaults
            vs.currentPattern.patterntype = 1;
            vs.currentPattern.bar1color = [0 0 30];
            vs.currentPattern.bar2color = [0 0 0];
            vs.currentPattern.backgroundcolor = [0 0 15];
            vs.currentPattern.barwidth = 20;
            vs.currentPattern.numgratings = 4;
            vs.currentPattern.angle = 0;
            vs.currentPattern.frequency = 1;
            vs.currentPattern.position = [0, 0];
            vs.currentPattern.predelay = 0;
            vs.currentPattern.duration = 1;
            vs.currentPattern.trigger = 0;

            % Set background color
            bgColor = vs.currentPattern.backgroundcolor;
            bgColor_normalized = [bgColor(1)/31, bgColor(2)/63, bgColor(3)/31];
            set(vs.ax_handle, 'Color', bgColor_normalized);
            
            % Draw black circular cutout
            blackoutBeyondDisplay(vs.ax_handle)
            
            vs.numPatternsDisplayed = 0;
            
            % Add text display for pattern information
            vs.info_handle = uicontrol('Parent', vs.fig_handle, ...
                'Style', 'text', ...
                'Units', 'normalized', ...
                'Position', [0.05 0.02 0.9 0.08], ...
                'HorizontalAlignment', 'left', ...
                'FontSize', 10);
            
            drawnow;
            
        case 'Disconnect'
            if isfield(vs, 'fig_handle') && ishandle(vs.fig_handle)
                close(vs.fig_handle);
            end
            
        case 'Reset-Background'
            if isfield(vs, 'ax_handle') && ishandle(vs.ax_handle)
                cla(vs.ax_handle);
                bgColor = vs.currentPattern.backgroundcolor;
                bgColor_normalized = [bgColor(1)/31, bgColor(2)/63, bgColor(3)/31];
                set(vs.ax_handle, 'Color', bgColor_normalized);
                blackoutBeyondDisplay(vs.ax_handle)
                drawnow;
            end
            
        case 'Start-Pattern'
            % Copy parameters to current pattern
            vs.currentPattern = param;
            
            % Validate parameters (same checks as matlab2teensy)
            validateParameters(param);
            
            % Draw pattern on display
            if isfield(vs, 'ax_handle') && ishandle(vs.ax_handle)
                drawPattern(vs, param);
            end
            
            % Record pattern information
            vs.numPatternsDisplayed = vs.numPatternsDisplayed + 1;
            vs.lastPatternStartTime = now;
            vs.lastPatternData = param;
            
        case 'Send-Parameters'
            % Update parameters without displaying yet
            vs.currentPattern = param;
            validateParameters(param);
            
            % Update background color only
            if isfield(vs, 'ax_handle') && ishandle(vs.ax_handle)
                bgColor = param.backgroundcolor;
                bgColor_normalized = [bgColor(1)/31, bgColor(2)/63, bgColor(3)/31];
                set(vs.ax_handle, 'Color', bgColor_normalized);
                drawnow;
            end
            
        case 'Get-Data'
            % Return structure similar to what hardware would send
            if isfield(vs, 'lastPatternData')
                % Create simulated data response
                % This would normally contain timing and pattern info from the Teensy
                if ~isfield(vs, 'data')
                    vs.data = [];
                end
            end
            
        case 'Demo-On'
            % Run a demo sequence
            runDemo(vs);
            
        case 'Demo-Off'
            % Just acknowledge (no-op in simulation)
            
        otherwise
            error(['Command "' command '" not recognized. Type "help simulate_teensyComm" for list of valid commands']);
    end

end


function validateParameters(param)
    % Validate pattern parameters (same as matlab2teensy)
    
    % Check pattern type
    assert(param.patterntype >= 1 && param.patterntype <= 4, ...
        'pattern type must be 1, 2, 3, or 4');
    
    % Check color ranges for 16-bit color
    assert(all(param.bar1color(1) >= 0 & param.bar1color(1) < 32), ...
        'red value of bar 1 must be between 0-31');
    assert(all(param.bar1color(2) >= 0 & param.bar1color(2) < 64), ...
        'green value of bar 1 must be between 0-63');
    assert(all(param.bar1color(3) >= 0 & param.bar1color(3) < 32), ...
        'blue value of bar 1 must be between 0-31');
    
    assert(all(param.bar2color(1) >= 0 & param.bar2color(1) < 32), ...
        'red value of bar 2 must be between 0-31');
    assert(all(param.bar2color(2) >= 0 & param.bar2color(2) < 64), ...
        'green value of bar 2 must be between 0-63');
    assert(all(param.bar2color(3) >= 0 & param.bar2color(3) < 32), ...
        'blue value of bar 2 must be between 0-31');
    
    assert(all(param.backgroundcolor(1) >= 0 & param.backgroundcolor(1) < 32), ...
        'red value of background must be between 0-31');
    assert(all(param.backgroundcolor(2) >= 0 & param.backgroundcolor(2) < 64), ...
        'green value of background must be between 0-63');
    assert(all(param.backgroundcolor(3) >= 0 & param.backgroundcolor(3) < 32), ...
        'blue value of background must be between 0-31');
    
    % Check bar width
    assert(mod(param.barwidth, 1) == 0 && param.barwidth > 0, ...
        'bar width must be an integer > 0');
    
    % Check number of gratings
    assert(mod(param.numgratings, 1) == 0 && param.numgratings > 0, ...
        'num gratings must be an integer > 0');
    
    % Check angle
    assert(param.angle >= 0 && param.angle <= 360, ...
        'angle must be between 0-360');
    
    % Check frequency
    assert(param.frequency > 0, 'frequency must be > 0');
    
    % Check position
    assert(abs(param.position(1)) <= 120 && abs(param.position(2)) <= 120, ...
        'position is not centered in viewable area (240 pixel diameter)');
    
    % Check duration
    assert(param.duration >= 0 && param.duration <= 25.5, ...
        'duration must be between 0-25.5 seconds');
    
    % Check pre delay
    assert(param.predelay >= 0 && param.predelay <= 25.5, ...
        'predelay must be between 0-25.5 seconds');
    
    % Check trigger
    assert(param.trigger == 0 || param.trigger == 1, ...
        'trigger must be 0 or 1');

end


function drawPattern(vs, param)
    % Draw the pattern on the simulated display
    
    % Clear axes
    cla(vs.ax_handle);
    
    % Set background color
    bgColor = param.backgroundcolor;
    bgColor_normalized = [bgColor(1)/31, bgColor(2)/63, bgColor(3)/31];
    set(vs.ax_handle, 'Color', bgColor_normalized);
    
    % Convert colors to normalized RGB
    bar1_rgb = [param.bar1color(1)/31, param.bar1color(2)/63, param.bar1color(3)/31];
    bar2_rgb = [param.bar2color(1)/31, param.bar2color(2)/63, param.bar2color(3)/31];
    
    % Calculate grating geometry
    angle_rad = deg2rad(param.angle);
    numlines = param.numgratings*param.barwidth*2;
    
    % Create coordinate system rotated by angle
    centerX = 120 + param.position(1);
    centerY = 120 + param.position(2);
    
    % Generate line endpoints for rotated grating
    dx = numlines * cos(angle_rad);
    dy = numlines * sin(angle_rad);
    perp_dx = -sin(angle_rad);
    perp_dy = cos(angle_rad);
    
    switch param.patterntype
        case 1  % Square-wave grating
            drawSquareWaveGrating(vs.ax_handle, centerX, centerY, dx, dy, perp_dx, perp_dy, ...
                param.barwidth, param.numgratings, bar1_rgb, bar2_rgb);
            
        case 2  % Sine-wave grating
            drawSineWaveGrating(vs.ax_handle, centerX, centerY, dx, dy, perp_dx, perp_dy, ...
                param.barwidth, param.numgratings, bar1_rgb, bar2_rgb);
            
        case 3  % Flicker stimulus
            drawFlicker(vs.ax_handle, centerX, centerY, bar1_rgb, bar2_rgb, param.barwidth, ...
                param.numgratings);
            
        case 4  % Placeholder for pattern type 4
            % Pattern type 4 - can be defined later
            drawSquareWaveGrating(vs.ax_handle, centerX, centerY, dx, dy, perp_dx, perp_dy, ...
                param.barwidth, param.numgratings, bar1_rgb, bar2_rgb);
    end
    
    % Update info display
    info_text = sprintf('Pattern %d | Type: %d | Freq: %.1f Hz | Angle: %.0f° | Dur: %.1f s', ...
        vs.numPatternsDisplayed, param.patterntype, param.frequency, param.angle, param.duration);
    set(vs.info_handle, 'String', info_text);
    
    drawnow;
    
    % Animate pattern for duration
    if param.duration > 0
        t_start = now;
        t_end = t_start + seconds(param.duration);
        
        while now < t_end
            elapsed_seconds = (now - t_start) * 86400; % Convert from days to seconds
            
            % Shift pattern based on actual elapsed time
            phase_shift = mod(elapsed_seconds * param.frequency, 1);

            % Redraw with phase shift
            cla(vs.ax_handle);
            set(vs.ax_handle, 'Color', bgColor_normalized);
            
            switch param.patterntype
                case 1
                    drawSquareWaveGrating(vs.ax_handle, centerX, centerY, dx, dy, perp_dx, perp_dy, ...
                        param.barwidth, param.numgratings, bar1_rgb, bar2_rgb, phase_shift);
                case 2
                    drawSineWaveGrating(vs.ax_handle, centerX, centerY, dx, dy, perp_dx, perp_dy, ...
                        param.barwidth, param.numgratings, bar1_rgb, bar2_rgb, phase_shift);
                case 3
                    if mod(floor(frame / 15), 2) == 0
                        set(vs.ax_handle, 'Color', bar1_rgb);
                    else
                        set(vs.ax_handle, 'Color', bar2_rgb);
                    end
            end
            blackoutBeyondDisplay(vs.ax_handle)
            
            drawnow;
            pause(0.01); %
        end
    end
    
    % Return to background color
    cla(vs.ax_handle);
    set(vs.ax_handle, 'Color', bgColor_normalized);
    blackoutBeyondDisplay(vs.ax_handle)
    drawnow;

end


function drawSquareWaveGrating(ax, centerX, centerY, dx, dy, perp_dx, perp_dy, barwidth, numgratings, color1, color2, varargin)
    % Draw square-wave grating pattern
    
    phase_shift = 0;
    if nargin > 10
        phase_shift = varargin{1};
    end
    
    bar_period = 2 * barwidth; % One full period (bar1 + bar2)
    total_width = bar_period * numgratings;
    
    % Generate line segments perpendicular to grating direction
    num_lines = ceil(sqrt(dx^2 + dy^2) / 2);
    
    hold(ax, 'on');
    set(ax, 'NextPlot', 'add');
    
    for i = 0:num_lines-1
        % Position along perpendicular direction
        pos = i - num_lines/2;
        phase_offset = mod(pos / barwidth + phase_shift, 2);
        
        % Determine color for this line
        if phase_offset < 1
            color = color1;
        else
            color = color2;
        end
        
        % Calculate line endpoints
        x0 = centerX + pos * perp_dx - (total_width/2) * cos(atan2(dy, dx));
        y0 = centerY + pos * perp_dy - (total_width/2) * sin(atan2(dy, dx));
        x1 = x0 + dx;
        y1 = y0 + dy;
        
        % Clip to display boundaries
        [x0, y0, x1, y1] = clipLine(x0, y0, x1, y1, 0, 210, 0, 240);
        
        if ~isnan(x0)
            line(ax, [x0 x1], [y0 y1], 'Color', color, 'LineWidth', 1);
        end
    end
    
    % hold(ax, 'off');

end


function drawSineWaveGrating(ax, centerX, centerY, dx, dy, perp_dx, perp_dy, barwidth, numgratings, color1, color2, varargin)
    % Draw sine-wave grating pattern
    
    phase_shift = 0;
    if nargin > 11
        phase_shift = varargin{1};
    end
    
    num_lines = ceil(sqrt(dx^2 + dy^2));
    bar_period = 2 * barwidth;
    total_width = bar_period*numgratings;
    
    hold(ax, 'on');
    set(ax, 'NextPlot', 'add');
    
    for i = 0:num_lines-1
        pos = i - num_lines/2;
        
        % Create sine-wave interpolation between colors
        phase = mod(pos / barwidth * pi + phase_shift * pi, 2*pi);
        intensity = (sin(phase) + 1) / 2; % 0 to 1
        
        % Interpolate color
        color = color1 * intensity + color2 * (1 - intensity);
        color = max(0, min(1, color)); % Clamp to valid range
        
        % Calculate line endpoints
        x0 = centerX + pos * perp_dx - (total_width/2) * cos(atan2(dy, dx));
        y0 = centerY + pos * perp_dy - (total_width/2) * sin(atan2(dy, dx));
        x1 = x0 + dx;
        y1 = y0 + dy;
        
        % Clip to display boundaries
        [x0, y0, x1, y1] = clipLine(x0, y0, x1, y1, 0, 210, 0, 240);
        
        if ~isnan(x0)
            line(ax, [x0 x1], [y0 y1], 'Color', color, 'LineWidth', 1);
        end
    end
    
    % hold(ax, 'off');

end


function drawFlicker(ax, centerX, centerY, color1, color2, barwidth, numgratings)
    % Draw flicker stimulus (filled rectangle)
    
    total_width = barwidth * numgratings * 2;
    x_min = max(0, centerX - total_width/2);
    x_max = min(210, centerX + total_width/2);
    y_min = max(0, centerY - total_width/2);
    y_max = min(240, centerY + total_width/2);
    
    rectangle(ax, 'Position', [x_min, y_min, x_max-x_min, y_max-y_min], ...
        'FaceColor', color1, 'EdgeColor', 'none');

end


function [x0, y0, x1, y1] = clipLine(x0, y0, x1, y1, xmin, xmax, ymin, ymax)
    % Simple line clipping to display boundaries (Cohen-Sutherland)
    
    % For simplicity, just check if line is within bounds
    if (x0 < xmin && x1 < xmin) || (x0 > xmax && x1 > xmax) || ...
       (y0 < ymin && y1 < ymin) || (y0 > ymax && y1 > ymax)
        x0 = NaN;
        y0 = NaN;
        x1 = NaN;
        y1 = NaN;
        return;
    end
    
    % Clip endpoints to bounds
    x0 = max(xmin, min(xmax, x0));
    x1 = max(xmin, min(xmax, x1));
    y0 = max(ymin, min(ymax, y0));
    y1 = max(ymin, min(ymax, y1));

end

function blackoutBeyondDisplay(ax)

    % Draw black circular cutout
    theta = linspace(0, 2*pi, 100);
    radius = 120; % Example radius for the cutout
    x = radius * cos(theta) + 120;
    y = radius * sin(theta) + 120;
    plot(ax, x, y, 'w','LineWidth',2)
    plot(ax, x, y, '--k','LineWidth',2)
    xlim([0 210])
    ylim([0 240])

end


function runDemo(vs)
    % Run a demo sequence of different patterns
    
    if ~isfield(vs, 'ax_handle') || ~ishandle(vs.ax_handle)
        return;
    end
    
    % Demo sequence with different pattern types
    demo_params = struct();
    
    % Sine-wave grating at 0.5 Hz
    demo_params(1).patterntype = 2;
    demo_params(1).bar1color = [0 0 30];
    demo_params(1).bar2color = [0 0 0];
    demo_params(1).backgroundcolor = [0 0 15];
    demo_params(1).barwidth = 40;
    demo_params(1).numgratings = 3;
    demo_params(1).angle = 0;
    demo_params(1).frequency = 0.5;
    demo_params(1).position = [0, 0];
    demo_params(1).predelay = 0;
    demo_params(1).duration = 2;
    demo_params(1).trigger = 0;
    
    % Square-wave grating at 5 Hz
    demo_params(2).patterntype = 1;
    demo_params(2).bar1color = [0 0 30];
    demo_params(2).bar2color = [0 0 0];
    demo_params(2).backgroundcolor = [0 0 15];
    demo_params(2).barwidth = 40;
    demo_params(2).numgratings = 3;
    demo_params(2).angle = 0;
    demo_params(2).frequency = 5;
    demo_params(2).position = [0, 0];
    demo_params(2).predelay = 0;
    demo_params(2).duration = 2;
    demo_params(2).trigger = 0;
    
    for i = 1:length(demo_params)
        drawPattern(vs, demo_params(i));
        pause(1);
    end

end

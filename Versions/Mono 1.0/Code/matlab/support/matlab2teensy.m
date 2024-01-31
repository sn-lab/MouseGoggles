function vs = matlab2teensy(vs, param)
%FUNCTION vs = matlab2teensy(vs, param)
%
% Function to send grating parameters from Matlab to Teensy.
%
% Parameter list
% command 101: set parameters:
%       parameter 1: pattern type (1 data byte)
%       parameter 2: bar1 color [R G B] (3 data bytes)
%       parameter 3: bar2 color [R G B] (3 data bytes)
%       parameter 4: background color [R G B] (3 data bytes)
%       parameter 5: bar width (# of pixels), depending on number of gratings) (1 data byte)
%       parameter 6: number of gratings (bar1 + bar2 = 1 grating) (1 data byte)
%       parameter 7: angle (0-360) (2 data bytes)
%       parameter 8: frequency (Hz) (1 data byte)
%       parameter 9: position [x, y] of grating center (pixels) (2 data bytes)
%       parameter 10: pre delay (s) (1 data byte)
%       parameter 11: duration (s) (1 data byte)
%       parameter 12: input trigger option (1 data byte)
%       total bytes: 20


%% check for errors in parameters
%check that pattern type is within allowed range
assert(param.patterntype==1 | param.patterntype==2 | param.patterntype==3,'pattern type must be 1, 2, or 3');

%check that color values are integers within range for 16-bit color
assert(param.bar1color(1)>=0 & param.bar1color(1)<32,'red value of bar 1 must be between 0-31');
assert(param.bar1color(2)>=0 & param.bar1color(2)<64,'green value of bar 1 must be between 0-63');
assert(param.bar1color(3)>=0 & param.bar1color(3)<32,'blue value of bar 1 must be between 0-31');
assert(param.bar2color(1)>=0 & param.bar2color(1)<32,'red value of bar 2 must be between 0-31');
assert(param.bar2color(2)>=0 & param.bar2color(2)<64,'green value of bar 2 must be between 0-63');
assert(param.bar2color(3)>=0 & param.bar2color(3)<32,'blue value of bar 2 must be between 0-31');
assert(param.backgroundcolor(1)>=0 & param.backgroundcolor(1)<32,'red value of background must be between 0-31');
assert(param.backgroundcolor(2)>=0 & param.backgroundcolor(2)<64,'green value of background must be between 0-63');
assert(param.backgroundcolor(3)>=0 & param.backgroundcolor(3)<32,'blue value of background must be between 0-31');
assert(all(logical(mod(param.bar1color,1))==0),'bar 1 color values must be integers');
assert(all(logical(mod(param.bar2color,1))==0),'bar 2 color values must be integers');
assert(all(logical(mod(param.backgroundcolor,1))==0),'background color values must be integers');

%check that bar width is within allowed range
assert(mod(param.barwidth,1)==0 & param.barwidth>0,'bar width must be an integer > 0')

%check that number of gratings is within allowed range
assert(mod(param.numgratings,1)==0 & param.numgratings>0,'num gratings must be an integer > 0')

%check that angle is within range
assert(param.angle>=0 & param.angle<=360,'angle must be an integer between 0-360');
if (mod(param.angle,1)>0)
    param.angle = round(param.angle);
    fprintf(['angle rounded to ' num2str(param.angle) ' degrees']);
end
if param.angle==360
    param.angle=0; 
end

%separate angle into 2 bytes
param.angle2b = [min([180 param.angle]), max([0 param.angle-180])];

%check that frequency is within range
assert(param.frequency>0,'frequency must be > 0');
if (mod(param.frequency*10,1)>0)
    param.frequency = max([round(param.frequency*10)/10 0.1]);
    fprintf(['frequency rounded to ' num2str(param.frequency) ' Hz (nearest 0.1 Hz)']);
end

%check that position is within allowed range
assert(abs(param.position(1))<=120 & abs(param.position(2))<=105,'position is not centered in viewable area (240x210)');

%check that duration is within range
assert(param.duration>=0&param.duration<=25.5,'duration must be between 0-25.5 seconds');
if (mod(param.duration*10,1)>0)
    param.duration = round(param.duration*10)/10;
    fprintf(['duration rounded to ' num2str(param.duration) ' s (nearest 0.1 ms)']);
end

%check that pre delay is within range
assert(param.predelay>=0&param.predelay<=25.5,'predelay must be between 0-25.5 seconds');
if (mod(param.predelay*10,1)>0)
    param.predelay = round(param.predelay*10)/10;
    fprintf(['predelay rounded to ' num2str(param.predelay) ' s (nearest 0.1 ms)']);
end

%check that trial duration is longer than display duration
if isfield(vs,'trial_duration')
    assert(vs.trial_duration>param.predelay+param.duration,'trial duration must be longer than predelay + duration');
end

%check that trigger option is either 0 or 1
assert(param.trigger==0 | param.trigger==1,'trigger must be 0 or 1');


%% send parameters to controller if no errors found
fwrite(vs.controller,param.patterntype,'uint8'); 
fwrite(vs.controller,param.bar1color,'uint8');
fwrite(vs.controller,param.bar2color,'uint8');
fwrite(vs.controller,param.backgroundcolor,'uint8');
fwrite(vs.controller,param.barwidth,'uint8');
fwrite(vs.controller,param.numgratings,'uint8');
fwrite(vs.controller,param.angle2b,'uint8');
fwrite(vs.controller,param.frequency*10,'uint8'); %converts frequency to units of 100 mHz for uint8 data transfer
fwrite(vs.controller,param.position+128,'uint8'); %puts [0,0] at [128,128] to accommodate negative numbers in uint8
fwrite(vs.controller,param.predelay*10,'uint8'); %converts pre delay to units of 100 ms for uint8 data transfer
fwrite(vs.controller,param.duration*10,'uint8'); %converts duration to units of 100 ms for uint8 data transfer
fwrite(vs.controller,param.trigger,'uint8');
    

end
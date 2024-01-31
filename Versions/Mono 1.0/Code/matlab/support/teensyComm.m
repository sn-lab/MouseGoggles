function vs = teensyComm(vs, command, param)
% FUNCTION vs = teensyComm(vs, command, param)
%
% Function to manage serial communication between Matlab and Arduino.
%
% LIST OF COMMANDS:
% 'Connect': opens serial connection to Arduino
% 'Disconnect': closes serial connection to Arduino
% 'Start-Pattern': start pattern with the current pattern parameters (ID [101 1])
% 'Send-Parameters': sets next pattern parameters -- updates background but doesn't immediately start pattern (ID [101 0])
% 'Reset-Background': fills screen with last used background color (ID 131)
% 'Get-Data': retrieve data sent back from controller 
% 'Demo-On': turns teensy demo mode on (ID 111)
% 'Demo-Off': turns teensy demo mode off (ID 110)
%
% INPUTS:
% vs: "vis-struct", container for teensy and data info
% command: instruction which tells matlab/teensy what to do next
% param: parameters of pattern to be displayed (only used for 'Start-Pattern' and 'Send-Parameters')

switch command
    case 'Connect'
        for i=1:length(vs)
            vs(i).controller = serial(vs(i).port,'BaudRate',9600); %define serial port
            fopen(vs(i).controller); %open connection to serial port
        end
        pause(3) %wait for connection(s) to be established
        for i=1:length(vs)
            vs(i).data = []; %create empty data structure
            vs(i).datanames = {};
            
            %check if teensy is already running (if it is, assume it's in demo mode)
            if vs(i).controller.BytesAvailable>0
                fprintf(['Teensy ' num2str(i) ' is running in demo mode. Turning off... ']);
                teensyComm(vs(i),'Demo-Off'); %turn demo mode off
                fprintf('done.\n')
            end
            
            %synchronize arduino and PC clock (i.e. calculate system clock timestamp when teensy clock began)
            fwrite(vs(i).controller,121,'uint8'); %begin handshake
            bytes = fread(vs.controller,4,'uint8')'; %read timestamp bytes
            teensytime = typecast(uint8(bytes),'uint32'); %current teensy timestamp (measured in ms from teensy start)
            pctime = now; %serial pc timestamp (ms precision)
            pctime = pctime - seconds(teensytime/1000); %subtract teensy time seconds from pctime
            vs(i).starttime_num = pctime; %approx. serial pc system time when teensy clock began (within 1 ms precision)
            vs(i).starttime_str = datestr(pctime,'dd-mm-yyyy HH:MM:SS FFF'); %string version (easier to read by humans)
            
            %get teensy program version #
            fwrite(vs(i).controller,0,'uint8'); %command to send back version number
            bytes = fread(vs(i).controller,4,'uint8')';
            versionID = typecast(uint8(bytes),'single');
            vs(i).programversion = versionID;
            
            %reset teensy background
            teensyComm(vs(i),'Reset-Background');
        end
        
    case 'Find-Ports'
        splist = serialportlist("available");
        vs.foundports = {};
        for port=1:length(splist)
            try
                controller = serial(port,'BaudRate',9600); %define serial port
                fopen(controller); %open connection to serial port
                fwrite(controller,0,'uint8'); %command to send back version number
                bytes = fread(controller,4,'uint8')';
                versionID = typecast(uint8(bytes),'single');
                if floor(versionID)==9307
                    vs.foundports = [vs.port;port];
                end
            end
        end
        
    case 'Disconnect'
        for i=1:length(vs)
            vs(i) = teensy2matlab(vs(i)); %get serial data from teensy if any still available
            fclose(vs(i).controller); %close connection to teensy
        end
        
    case 'Reset-Background'
        for i=1:length(vs)
            fwrite(vs(i).controller,131,'uint8'); %command to fill screen with backgroundcolor
        end
        
    case 'Start-Pattern'
        for i=1:length(vs)
            fwrite(vs(i).controller,101,'uint8'); %command to send pattern parameters to teensy
            fwrite(vs(i).controller,1,'uint8'); %display pattern right away
            vs(i) = matlab2teensy(vs(i), param(min([i length(param)]))); 
        end
        
    case 'Send-Parameters'
        for i=1:length(vs)
            fwrite(vs(i).controller,101,'uint8'); %command to send pattern parameters to teensy
            fwrite(vs(i).controller,0,'uint8'); %DON'T display pattern right away
            vs(i) = matlab2teensy(vs(i), param(min([i length(param)])));
        end
        
    case 'Get-Data'
        for i=1:length(vs)
            vs(i) = teensy2matlab(vs(i)); %get data from teensy     
        end
        
    case 'Demo-On'
        for i=1:length(vs)
            fwrite(vs(i).controller,111,'uint8'); %command to turn demo mode on
        end
        
    case 'Demo-Off'
        for i=1:length(vs)
            demoMode = 1;
            fwrite(vs(i).controller,110,'uint8'); %command to turn demo mode off
            %keep reading until message recieved that demo mode is off
            while demoMode
                msg1 = fread(vs(i).controller,1,'uint8');
                if msg1==112 
                    msg2 = fread(vs(i).controller,1,'uint8');
                    if msg2==212
                        demoMode = 0;
                    end
                end
            end
        end
        
    otherwise
        error(['Command "' command '" not recognized. Type "help teensyComm" for list of valid commands'])

end
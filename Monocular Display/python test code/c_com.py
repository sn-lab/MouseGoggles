def c_com(command, cs, ser, param =0 ):
    '''
    FUNCTION cs = c_com(cs, command)

    Function to manage serial communication between Matlab and Arduino.

    LIST OF COMMANDS:
    'Connect': opens serial connection to Arduino
    'Disconnect': closes serial connection to Arduino
    'Get-Version': gets Arduino program version number (ID 0)
    'Send-Parameters': sets current grating parameters (ID 101)
    'Fill-Background': fills screen with background color (ID 102):
    'Backlight-Off': turns off backlight (ID 103)
    'Backlight-On': turns on backlight (ID 104)
    'Start-Display': start current grating (ID 105)
    'Start-Flicker': flicker backlight at current frequency (ID 106)
    'Get-Data': retrieve data sent back from controller 
    '''
    #set-up
    from Grating_C2M import grating_C2M
    from Grating_M2C import grating_M2C


    import time
    
    if command == 'Start-Gratings':
        ser.write(bytearray([105])) #start gratings of current parameters
    elif command == 'Backlight-Off':
        ser.write(bytearray([103])) #turns display backlight off
    elif command == 'Backlight-On':
        ser.write(bytearray([104])) #turns display backlight on
    elif command == 'Connect':
        ser.write(bytearray([0])) #command to send back version number
        return grating_C2M(cs,ser) #read version number
    elif command == 'Disconnect':
        ser.write(bytearray([103])) #turn backlight off
        return grating_C2M(cs,ser) #get data from controller  %collect serial data if any still available
    elif command == 'Send-Parameters':
        ser.write(bytes([101])) #send grating parameter values to controller
        grating_M2C(cs,ser,param) 
    elif command == 'Fill-Background':
        ser.write(102) #fill display with background color
        time.sleep(1) #wait for display to fill
    elif command == 'Start-Flicker':
        ser.write(bytearray([106])) #start gratings of current parameters
    elif command == 'Get-Data':
        return grating_C2M(cs,ser) #get data from controller      
    else:
        raise ValueError(f"Command {command} not recognized. Type \"help Controller_stimcomm\" for list of valid commands")
    
    return cs

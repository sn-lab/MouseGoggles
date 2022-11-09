def grating_C2M(cs,ser):
  
    #Function to retrieve serial communication data from Arduino.

    import numpy as np 

    #Retrieve all serial data waiting in the cache
    while ser.in_waiting >0 :
        msgtype = int.from_bytes(ser.read(1),"big")  
        if msgtype == 200 : #version number
            Bytes = ser.read(4)
            versionID = np.uint32(Bytes)
            print(f"Arduino program version ID: {versionID}  \n")
        elif msgtype == 201 : #display start; record parameters and timestamp
            Bytes = ser.read(4)
            counter = int.from_bytes(Bytes,"little") #counter for number of controller starts
            Bytes = ser.read(4)
            time = int.from_bytes(Bytes,"little") #start timestamp from controller
            readdelay = int.from_bytes(ser.read(1),"little")
            bar1color = np.empty(3, dtype=object) 
            bar2color = np.empty(3, dtype=object)
            backgroundcolor = np.empty(3, dtype=object) 
            position = np.empty(2, dtype=object) 
            bar1color[0] = int.from_bytes(ser.read(1), "little")
            bar1color[1] = int.from_bytes(ser.read(1),"little")
            bar1color[2] = int.from_bytes(ser.read(1),"little")
            #print(bar1color[0])
            #print(bar1color[1])
            #print(bar1color[2])
            bar2color[0] = int.from_bytes(ser.read(1),"little")
            bar2color[1] = int.from_bytes(ser.read(1),"little")
            bar2color[2] = int.from_bytes(ser.read(1),"little")
            #print(bar2color[0])
            #print(bar2color[1])
            #print(bar2color[2])
            backgroundcolor[0] = int.from_bytes(ser.read(1),"little")
            backgroundcolor[1] = int.from_bytes(ser.read(1),"little")
            backgroundcolor[2] = int.from_bytes(ser.read(1),"little")
            #print(backgroundcolor[0])
            #print(backgroundcolor[1])
            #print(backgroundcolor[2])
            barwidth = int.from_bytes(ser.read(1),"little")
            numgratings = int.from_bytes(ser.read(1),"little")
            print(numgratings)
            angle2b = int.from_bytes(ser.read(2),"little")
            frequency = int.from_bytes(ser.read(1),"little")/10
            position[0] = int.from_bytes(ser.read(1),"little")
            position[1] = int.from_bytes(ser.read(1),"little")
            predelay =int.from_bytes( ser.read(1),"little")/10
            duration = int.from_bytes(ser.read(1),"little")/10
            output = int.from_bytes(ser.read(1),"little")*5/255
            angle = int.from_bytes(np.sum(angle2b),"little")
            Bytes = ser.read(4)
            benchmark = int.from_bytes(Bytes,"little")
            
            #for flicker, change all irrelevant parameters to empty
            if numgratings==0 :
                bar1color = [-1,-1,-1]
                bar2color = [-1,-1,-1]
                
                barwidth = -1
                position = [-1,-1]
                angle = -1
                benchmark = -1  
            #save current data and parameters
            if hasattr(cs,'trial')==True:
                trial = cs.trial
            else:
                trial = 0
                        
            if hasattr(cs,'rep')==True:
                rep = cs.rep
            else:
                rep = 0
               # print(bar1color[0])
                
            
            print(bar1color)           
            addData = np.array([counter, time, 
            trial, rep, readdelay, bar1color[0], bar1color[1], bar1color[2], bar2color[0], bar2color[1], bar2color[2], 
            backgroundcolor[0], backgroundcolor[1], backgroundcolor[2], barwidth, numgratings, angle, frequency, position[0],position[1], 
            predelay, duration, output, benchmark]) 
            
           
            if cs.data is None:
                cs.data = addData
            else:
                cs.data = np.append(cs.data, addData,axis=0)
        elif msgtype == 225 :
            ID = ser.read(1)
            print(int.from_bytes(ser.read(1),"big") )
            raise ValueError(f"message type ID ({ID}) not recognized by controller cache cleared.")
        else:
            cache = {}
            while ser.in_waiting > 0 :
                cache = [cache , ser.read(1)]
                #import sys
                #if type(cache) is dict:
                #    cache = 777 
                #intmess = int.from_bytes(msgtype, byteorder='little')
                #intcache = int.from_bytes(cache, byteorder='little')        
            raise ValueError(f"message type from controller not recognized ({msgtype}). cache cleared ({cache}).")
    return cs

   
    

    
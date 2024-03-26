import cv2
import socket
import struct
import io
import numpy as np
import time
import tkinter as tk
from tkinter import Scale
import threading
from pynput import keyboard
from tkinter import Button
import configparser
from tkinter import filedialog
from tkinter import Checkbutton
from tkinter import ttk
import scipy.io
import pandas as pd
import traceback
import matplotlib.pyplot as plt
from tkinter import Scale
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import glob
from datetime import datetime
from matplotlib.figure import Figure


#initial sleep parameter
#size and location of ellipse roi

################################################################
test_position=False
save_video=True
Fast_run=False
filter_size=2 #median filter_size
basepath = r'D:\SN Lab\VR\EyeR\Gap 2-19-24\mouse5'
input_folder = r'\raw video'
output_folder = r'\processed video'
video_name = r'\Right_gap5'
video_path = basepath + input_folder + video_name + r'.h264'
now = datetime.now()
date_string = now.strftime('%Y-%m-%d')
time_string = now.strftime('%H-%M')
start_frame = 0
frame_output_file = basepath + output_folder + video_name + rf'_blueframe_{date_string}_{time_string}.avi' # Where to save labelled video
roi_output_file = basepath + output_folder + video_name + rf'_redroi_{date_string}_{time_string}.avi'
csv_path = basepath + output_folder + video_name + rf'_bluemean_{date_string}_{time_string}.csv'


############################################
# Global variables to hold the parameters
roi_center = (375,375)  # roi_center[0]: adjust y   roi_center[1]: adjust x  
#left 1: (425,275)
#right 1: (350, 400)
#left 2: (375,300)
#right 2: (350,350)
#left 3: (325,275)
#right 3: (325,375)
#left 4: (400,300)
#right 4: (400,375)
#left 5: (375,325)
#right 5: (375,375)
roi_size1 = (250, 250)  # roi_size[0]: adjust height roi_size[1]: adjust width
frame_size = (800,800) # height, width of frame
roi_center1 = roi_center
roi_size = roi_size1
red_scale = 1
red_offset = 0

if save_video:
    #fourcc = cv2.VideoWriter_fourcc(*'MJPG')
    fourcc = cv2.VideoWriter_fourcc(*'XVID')
    fps = 30
    frame_out = cv2.VideoWriter(frame_output_file, fourcc, fps, frame_size, 0)
    frame_size = (roi_size[0]*2, roi_size[1]*2)
    roi_out = cv2.VideoWriter(roi_output_file, fourcc, fps, frame_size, 0)



# Read and process each frame
frame_count = 0
progress_interval = 500

cap = cv2.VideoCapture(video_path) # Replace 100 with the frame number you want to start from
cap.set(cv2.CAP_PROP_POS_FRAMES, start_frame)
if Fast_run:
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    

if __name__ == "__main__":
    data_list = []
    frame_count = 0
    last_frame_count = 0

    last_process_time = 0
    try:
        while True:

            ret, frame = cap.read()
            if ret is False:
                break

            #tracking start
            try:
                blue_frame = frame[:,:,0]
                frame_out.write(blue_frame)
                
                blue_mean = cv2.mean(blue_frame)
                blue_mean = blue_mean[0]
                
                roi = frame[(roi_center[0] - roi_size1[0]):(roi_center[0] + roi_size1[0]),
                      (roi_center[1] - roi_size1[1]):(roi_center[1] + roi_size1[1])]
                red_roi = roi[:,:,2]
                red_roi = red_roi*red_scale - red_offset
                red_roi = red_roi.astype('uint8') 
                
                roi_out.write(red_roi)
                
                #count frames
                frame_count += 1
                
                data_list.append({
                    'FrameCounts': frame_count,
                    'blue_mean':blue_mean,
                })

                if (frame_count - last_frame_count) >= progress_interval:
                    last_frame_count += progress_interval
                    print(f"frame: {frame_count:.2f}")
                    # Save the DataFrame to CSV
                    df = pd.DataFrame(data_list)
                    df.to_csv(csv_path,mode='a',index=False)
                    # Clear the list after saving
                    data_list.clear()

                    if test_position:
                        break
                    
                #if not Fast_run:
                    #cv2.imshow("red roi", red_roi)

                #########################################################################################################

            except Exception as e:
            # Handle the error here (you can also choose to ignore it)
            # For example, you can print the error message:
                print("An error occurred:", traceback.extract_tb(e.__traceback__)[0].lineno, ":", e)
                
        
    except KeyboardInterrupt:
        # Save any remaining data when the loop is interrupted
        roi_out.release()
        frame_out.release()
        if data_list:
            df = pd.DataFrame(data_list)
            df.to_csv(csv_path, mode='a',index=False)

    print(f"frame: {frame_count:.2f}")
    # Save the DataFrame to CSV
    df = pd.DataFrame(data_list)
    df.to_csv(csv_path,mode='a',index=False)
    # Clear the list after saving
    data_list.clear()
    
    roi_out.release()
    frame_out.release()
    cv2.destroyAllWindows()
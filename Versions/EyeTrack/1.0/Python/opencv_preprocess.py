import cv2
import pandas as pd
import traceback
from datetime import datetime


################################################################
#settings
test_position=False #set true to create a short test video, to see if the roi size and position is correct
save_video=True #set true to save .avi videos
basepath = r'D:\videos'
input_folder = r'\raw video'
output_folder = r'\processed video'
video_name = r'\test'
video_path = basepath + input_folder + video_name + r'.h264'
now = datetime.now()
date_string = now.strftime('%Y-%m-%d')
time_string = now.strftime('%H-%M')
start_frame = 0
frame_output_file = basepath + output_folder + video_name + rf'_blueframe_{date_string}_{time_string}.avi' # Where to save labelled video
roi_output_file = basepath + output_folder + video_name + rf'_redroi_{date_string}_{time_string}.avi'
csv_path = basepath + output_folder + video_name + rf'_bluemean_{date_string}_{time_string}.csv'


############################################
# manunally set the center coordinates of the mouse eye
roi_center = (375,375)  # roi_center[0]: adjust y   roi_center[1]: adjust x  
roi_size = (250, 250)  # roi_size[0]: adjust height roi_size[1]: adjust width
frame_size = (800,800) # height, width of original frame
red_scale = 1
red_offset = 0

if save_video:
    #fourcc = cv2.VideoWriter_fourcc(*'MJPG')
    fourcc = cv2.VideoWriter_fourcc(*'XVID')
    fps = 30
    frame_out = cv2.VideoWriter(frame_output_file, fourcc, fps, frame_size, 0)
    frame_size = (roi_size[0]*2, roi_size[1]*2)
    roi_out = cv2.VideoWriter(roi_output_file, fourcc, fps, frame_size, 0)



##############################################
# Read and process each frame
frame_count = 0
progress_interval = 500
cap = cv2.VideoCapture(video_path) # Replace 100 with the frame number you want to start from
cap.set(cv2.CAP_PROP_POS_FRAMES, start_frame)

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

            #video conversion start
            try:
                #get the blue channel of the input video
                blue_frame = frame[:,:,0]
                frame_out.write(blue_frame)
                
                #calculate the average brightness of the blue frame
                blue_mean = cv2.mean(blue_frame)
                blue_mean = blue_mean[0]
                
                #get the red channel of the ROI
                roi = frame[(roi_center[0] - roi_size[0]):(roi_center[0] + roi_size[0]),
                      (roi_center[1] - roi_size[1]):(roi_center[1] + roi_size[1])]
                red_roi = roi[:,:,2]
                red_roi = red_roi*red_scale - red_offset
                red_roi = red_roi.astype('uint8') 
                roi_out.write(red_roi)
                
                #count frames
                frame_count += 1
                
                #save the blue frame brightness (useful for identifying frames of the looming stimuli, where the blue frame goes darker)
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
import numpy as np
import cv2

video_filename = "test_frames.bin"

# script to load and display cam0 and cam1 video saved in the binary file specified above.
# video is displayed at ~20 fps
# press "q" to exit script early
#
# The binary file is all uint8 bytes organized into a header + imagedata for every
# captured frame. The header is 9 bytes, and the imagedata size depends on the image
# resolution (e.g. for 250x250 resolution images, imagedata is 250*250=62500 bytes)
# the header consists of the following information:
#
#   9 bytes (0-8): header
#   e.g. header = f.read(9) <- header is first 9 bytes of each frame in file "f"

#   4 bytes (0-3): timestamp (in ms)
#   e.g.: timestamp = int.from_bytes(header[3:0:-1], 'little')
#
#   1 byte (4): camera index (0 or 1)
#   e.g. cam_idx = header[4]
#
#   2 bytes (5:6): height of image (in pixels)
#   e.g. height = int.from_bytes(header[6:5:-1], 'little')
#
#   2 bytes (7:8): height of image (in pixels)
#   e.g. width = int.from_bytes(header[8:7:-1], 'little')


def display_frames(binary_file):
    with open(binary_file, 'rb') as f:
        frames = []
        num_frames = 0
        while True:
            # read header
            header = f.read(9)
            if not header:
                break
            timestamp = int.from_bytes(header[3:0:-1], 'little')
            cam_idx = header[4]
            height = int.from_bytes(header[6:5:-1], 'little')
            width = int.from_bytes(header[8:7:-1], 'little')
            
            # read frame data
            frame_size = width * height
            frame_data = np.frombuffer(f.read(frame_size), dtype=np.uint8)
            frame = frame_data.reshape((height, width))
            frames.append((timestamp, cam_idx, frame))
            num_frames+=1 #number of frames read
            
    num_frames/=2 #number of frame pairs
    num_frames=round(num_frames)
    
    print(f"file loaded ({height}x{width}x2x{num_frames})")
    frame_dict = {}
    for ts, cam_idx, frame in frames:
        if ts not in frame_dict:
            frame_dict[ts] = {}
        frame_dict[ts][cam_idx] = frame
    
    # display frames
    cv2.namedWindow('Dual Camera View', cv2.WINDOW_NORMAL)  # create window

    for ts in sorted(frame_dict.keys()):
        if len(frame_dict[ts]) != 2:  # skip if we don't have both cameras (should never happen)
            continue
            
        # get frames
        cam0 = frame_dict[ts][0]
        cam1 = frame_dict[ts][1]
        
        # convert to color
        cam0_color = cv2.cvtColor(cam0, cv2.COLOR_GRAY2BGR)
        cam1_color = cv2.cvtColor(cam1, cv2.COLOR_GRAY2BGR)
        
        # add timestamp text
        font = cv2.FONT_HERSHEY_SIMPLEX
        cv2.putText(cam0_color, f"{ts}ms", (10, 30), font, 0.7, (0, 255, 0), 2)
        cv2.putText(cam1_color, f"{ts}ms", (10, 30), font, 0.7, (0, 255, 0), 2)
        
        # display frames side-by-side
        combined = np.hstack((cam0_color, cam1_color))
        cv2.imshow('Dual Camera View', combined)
        
        # wait 50ms or until 'q' is pressed
        if cv2.waitKey(50) & 0xFF == ord('q'):
            break
    
    cv2.destroyAllWindows()


if __name__ == "__main__":
    display_frames(video_filename)

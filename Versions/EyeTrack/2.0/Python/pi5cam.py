#!/usr/bin/env python3
"""
Live red?channel viewer for two Raspberry Pi cameras.
All camera settings (crop, exposure, gain, FPS, resolution) are defined
in the CONFIGURATION section below.
Use this script to find the best settings, then copy them to pi5cam_udp.py.

Press 'q' in any display window to quit.
"""

import cv2
import time
import numpy as np
from picamera2 import Picamera2

# ============================================================
# CONFIGURATION
# ============================================================

# --- Directory ---
# Hardcoded directory of the current Godot project log folder (where camera videos will be saved)
base_log_dir = "/home/mg2/MouseGoggles/Godot/MouseVR Godot Project V2.2/logs"

# --- Output resolution ---
# Size of the captured/saved frame in pixels (width, height).
# Keep at or below 250x250 to fit a single UDP packet for the "F" command.
CAPTURE_SIZE = (250, 250)

# --- Crop window (region of interest on the sensor) ---
# Selects a sub-region of the full sensor to capture, then scales it to CAPTURE_SIZE.
# CROP_WIDTH and CROP_HEIGHT are shared across both cameras; CROP_X and CROP_Y are
# set independently per camera so each lens can be centered individually.
CROP_ENABLED  = False  # CROP_ENABLED = False uses the camera's default full-sensor view
CROP_WIDTH    = 1000   # width of crop window (pixels) — shared by both cameras
CROP_HEIGHT   = 1000   # height of crop window (pixels) — shared by both cameras
CAM0_CROP_X   = 796    # cam 0 left boundary of the crop window (pixels)
CAM0_CROP_Y   = 472    # cam 0 top boundary of the crop window (pixels)
CAM1_CROP_X   = 796    # cam 1 left boundary of the crop window (pixels)
CAM1_CROP_Y   = 472    # cam 1 top boundary of the crop window (pixels)
# (for reference) Spy camera resolution = 2592 x 1944

# --- Exposure & gain (brightness) ---
# Auto-exposure is DISABLED so brightness stays fixed across every frame. Adjust these values instead:
EXPOSURE_TIME_US  = 8000  # shutter duration (microseconds). Lower = darker. Must be < 1000000/TARGET_FPS (can't expose longer than one frame period).
CAM0_ANALOGUE_GAIN = 1.0  # cam 0 sensor amplification; 1.0–16.0. 1.0 = minimum noise; increase only if exposure alone is too dark
CAM1_ANALOGUE_GAIN = 1.0  # cam 1 sensor amplification

# --- Frame rate ---
# Attempts to lock the camera to a rate for consistent inter-frame timing. Though, the actual framerate
# can be different; timestamps in the .bin file are the ground truth for timing analysis.
TARGET_FPS = 30  # target frame rate (frames per second)


# ============================================================
# END OF CONFIGURATION
# ============================================================

_FRAME_DURATION_US = 1_000_000 // TARGET_FPS
_CAM_CROP_X = [CAM0_CROP_X, CAM1_CROP_X]
_CAM_CROP_Y = [CAM0_CROP_Y, CAM1_CROP_Y]
_CAM_GAIN   = [CAM0_ANALOGUE_GAIN, CAM1_ANALOGUE_GAIN]

def apply_controls(cam, cam_idx):
    """Apply crop and exposure controls after camera start."""
    controls = {
        "AeEnable":     False,
        "AwbEnable":    False,
        "ExposureTime": EXPOSURE_TIME_US,
        "AnalogueGain": _CAM_GAIN[cam_idx],
        "FrameDurationLimits": (_FRAME_DURATION_US, _FRAME_DURATION_US),
    }
    if CROP_ENABLED:
        controls["ScalerCrop"] = (_CAM_CROP_X[cam_idx], _CAM_CROP_Y[cam_idx],
                                  CROP_WIDTH, CROP_HEIGHT)
    cam.set_controls(controls)

def main():
    # Initialise both cameras
    picam0 = Picamera2(0)
    picam1 = Picamera2(1)

    # Configure video mode with desired output size
    config0 = picam0.create_video_configuration(main={"size": CAPTURE_SIZE})
    config1 = picam1.create_video_configuration(main={"size": CAPTURE_SIZE})
    picam0.configure(config0)
    picam1.configure(config1)

    # Start cameras (required before setting ScalerCrop)
    picam0.start()
    picam1.start()

    # Apply all controls (crop, exposure, gain, FPS limits)
    apply_controls(picam0, 0)
    apply_controls(picam1, 1)

    print("Live view – red channel only (grayscale)")
    print("Press 'q' in any window to quit.")
    print(f"Resolution: {CAPTURE_SIZE[0]}x{CAPTURE_SIZE[1]}")
    if CROP_ENABLED:
        print(f"Crop enabled: {CROP_WIDTH}x{CROP_HEIGHT} from sensor")
    else:
        print("Crop disabled – full sensor used")
    print(f"Exposure: {EXPOSURE_TIME_US} µs, Gain0={CAM0_ANALOGUE_GAIN}, Gain1={CAM1_ANALOGUE_GAIN}")

    try:
        while True:
            # Capture RGB arrays
            rgb0 = picam0.capture_array("main")
            rgb1 = picam1.capture_array("main")

            # Extract red channel only (index 0) -> 2D grayscale
            red0 = rgb0[:, :, 0]
            red1 = rgb1[:, :, 0]

            # Display (cv2 expects colour images, but we feed single?channel grayscale)
            cv2.imshow("Camera 0 (red channel)", red0)
            cv2.imshow("Camera 1 (red channel)", red1)

            # Quit on 'q' key
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break

            # Optional: small sleep to prevent 100% CPU usage
            time.sleep(0.005)

    finally:
        # Cleanup
        picam0.stop()
        picam1.stop()
        cv2.destroyAllWindows()
        print("Cameras stopped.")

if __name__ == "__main__":
    main()
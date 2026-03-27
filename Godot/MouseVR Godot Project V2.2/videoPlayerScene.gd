#get common settings
extends "res://commonSettings.gd"

#video player parameters
export var scene_duration = 150 #max duration of the scene
export var trial_duration = 15 #max duration of each trial
export var scene_name = "videoplayer"
export var num_reps = 5 #max number of trials 
export var track_length = 1.0

#screen and video parameters
export var video_file = "res://videos/cat_in_field_royaltyfree.ogv" #video file must be in OGV format (MP4, AVI don't work)
export var screen_position = Vector3(0, 0, 1)  # x(left/right), y(up/down), z(forward/back)
export var floor_position = Vector3(0, -1, 0)
export var screen_width = 5.3
export var screen_height = 3.0
export var transparent_black = false #interpret fully-black pixels as transparent
export var allow_movement = true #whether the user is allowed to move away from the screen
export var play_on_load = false #start the video as soon as it's loaded; otherwise, have to manually start using "video_screen.start_video()"
export var loop = false #loop the video when finished; otherwise, it will go to the default screen color
export var default_screen_color = Color(0, 0, 0.5) #color of screen when video not playing

#headkinbody viewport nodes
onready var lefthead = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/TextureRect/Viewport/LeftEyeBody")
onready var righthead = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/TextureRect/Viewport/RightEyeBody")
onready var lefteye = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/TextureRect/Viewport/LeftEyeBody/LeftEyePivot")
onready var righteye = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/TextureRect/Viewport/RightEyeBody/RightEyePivot")
onready var colorrect = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/ColorRect")
onready var fpslabel = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/Label")
onready var overlay = get_node("HeadKinBody/Control/Overlay")
onready var video_screen = $videoPlayer  # Use the existing node
onready var floor_node = $floor  # Use the existing node

#head/eye position variables
var head_yaw = 0
var head_thrust = 0
var head_slip = 0
var head_x = 0
var head_z = 0
var head_y = 0
var head_yaw_angle = 0

#logging/saving stuff
var current_rep = 1
var current_frame = 0
var dataNames = ['head_yaw', 'head_thrust', 'head_slip', 'head_x', 'head_z', 'head_yaw_angle', 'ms_now']

func _ready():
	experimentName = timestamp + "_" + scene_name
	
	#head positions
	head_y = 0.01 + head_radius
	head_yaw_angle = 180
	head_x = 0
	head_z = 0
	
	#floor position
	floor_node.translation = floor_position
	
	#configure existing video screen node
	if video_screen:
		video_screen.video_file = video_file
		video_screen.screen_width = screen_width
		video_screen.screen_height = screen_height
		video_screen.transparent_black = transparent_black
		video_screen.play_on_load = play_on_load
		video_screen.loop = loop
		video_screen.default_screen_color = default_screen_color
		
		#set position
		video_screen.translation = screen_position
		
		#make sure it's initialized
		video_screen._ready()
		
		video_screen.set_default_color(default_screen_color) 
		video_screen.start_video()
	else:
		print("Error: VideoPlayer node not found!")
	
	#start experiment
	var experimentDuration = scene_duration
	overlay.color = Color(0, 0, 0, 1-brightness_modulate)
	start_experiment(experimentDuration)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#calculate fps (method 2)
	ms_now = OS.get_ticks_msec() - ms_start
	times.append(ms_now)
	while times.size() > 0 and times[0] <= ms_now - 1000:
		times.pop_front() # Remove frames older than 1 second in the `times` array
	fps = times.size()
	current_frame += 1
	
	#calculate head position
	if allow_movement:
		head_yaw_angle += mouse_gain*yaw_gain*head_yaw
		head_z += mouse_gain*(thrust_gain*head_thrust*cos(deg2rad(head_yaw_angle)) + slip_gain*head_slip*sin(deg2rad(head_yaw_angle)))
		head_x += mouse_gain*(-thrust_gain*head_thrust*sin(deg2rad(head_yaw_angle)) + slip_gain*head_slip*cos(deg2rad(head_yaw_angle)))
		
		#keep head inside of linear track
		if head_z>((track_length/2)-head_radius):
			head_z = (track_length/2)-head_radius
		if head_z<(-(track_length/2)+head_radius):
			head_z = -(track_length/2)+head_radius
		if head_x>((track_length/2)-head_radius):
			head_x = (track_length/2)-head_radius
		if head_x<(-(track_length/2)+head_radius):
			head_x = -(track_length/2)+head_radius
	
	#translate body position
	righthead.translation.z = head_z
	righthead.translation.x = head_x
	righthead.translation.y = head_y
	lefthead.translation.z = head_z
	lefthead.translation.x = head_x
	lefthead.translation.y = head_y
	
	#translate eyes relative to body
	lefteye.translation.z = head_z - inter_eye_distance*sin(deg2rad(head_yaw_angle))
	lefteye.translation.x = head_x - inter_eye_distance*cos(deg2rad(head_yaw_angle))
	righteye.translation.z = head_z + inter_eye_distance*sin(deg2rad(head_yaw_angle))
	righteye.translation.x = head_x + inter_eye_distance*cos(deg2rad(head_yaw_angle))
	
	#rotate eyes relative to body
	lefteye.rotation_degrees.y = -head_yaw_angle+eye_yaw
	lefteye.rotation_degrees.x = eye_pitch
	righteye.rotation_degrees.y = -head_yaw_angle-eye_yaw
	righteye.rotation_degrees.x = eye_pitch
	
	#log data
	dataArray = [head_yaw, head_thrust, head_slip, head_x, head_z, head_yaw_angle, ms_now]
	for i in range(dataArray.size()):
		dataLog.append(dataArray[i])
	
	#update text label
	#fpslabel.text = str(fps) + " FPS" 
#	fpslabel.text = ""
	fpslabel.text = str(head_x) 
	
	#reset inputs
	head_thrust = 0
	head_slip = 0
	head_yaw = 0
	
	#next trial
	if (current_frame > trial_duration*frames_per_second):
		saveUtils.save_logs(current_rep,dataLog,dataNames,experimentName) #save current logged data to a new file
		dataLog = [] #clear saved data
		current_frame = 1
		current_rep += 1
		if (current_rep>num_reps):
			stop_experiment()
		else:
			head_yaw_angle = 180
			head_x = 0
			head_z = 0
			video_screen.start_video() #restart the video

	
func _input(ev):
	if ev is InputEventKey and ev.is_pressed():
		if ev.scancode == KEY_ESCAPE:
			saveUtils.save_logs(current_rep,dataLog,dataNames,experimentName) #save current logged data to a new file
			dataLog = [] #clear saved data
			stop_experiment()
			
	if ev is InputEventMouseMotion:
		head_yaw += ev.relative.x
		head_thrust += ev.relative.y
		
	if ev is InputEventMouseButton:
		if ev.is_pressed():
			if ev.button_index == BUTTON_WHEEL_UP:
				head_slip += 1
			if ev.button_index == BUTTON_WHEEL_DOWN:
				head_slip -= 1


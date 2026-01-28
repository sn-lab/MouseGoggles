#get common settings
extends "res://commonSettings.gd"

#track parameters
export var mouse_num = 1 #ID of mouse (determines which reward loc/track num to use)
export var num_rewards_out_of_10 = 10 #number of trials (per 10) which are rewarded (randomly)
export var lick_in_reward_required = 0 #whether the mouse has to lick in the reward zone first in order to be rewarded
export var scene_name = "lineartrack"
export var track_length = 1.5
export var track_width = 0.1
export var num_reps = 400 #max number of trials 
export var trial_duration = 60 #max duration of each trial
export var reward_dur = 0.05 #duration to open liquid reward valve)
export var mouse_num_reward_loc := 	[-0.25, -0.25, 0.25, 0.25, 0.25] #for mouse [1 2 3 4 5]
export var mouse_num_track_num := 	[2, 2, 2, 2, 2] #for mouse [1 2 3 4 5]
export var track1_xpos = 0 #center x of linear track
export var track2_xpos = 0.5
export var guaranteed_rewards = 3 #number of beginning trials to guarantee rewards
export var track_reward_range = 0.2 #size of reward zone after reward location start

#headkinbody viewport nodes
onready var lefthead = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/TextureRect/Viewport/LeftEyeBody")
onready var righthead = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/TextureRect/Viewport/RightEyeBody")
onready var lefteye = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/TextureRect/Viewport/LeftEyeBody/LeftEyePivot")
onready var righteye = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/TextureRect/Viewport/RightEyeBody/RightEyePivot")
onready var colorrect = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/ColorRect")
onready var fpslabel = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/Label")
onready var overlay = get_node("HeadKinBody/Control/Overlay")

#head/eye position variables
export var max_yaw = 0 #amount of yaw turning allowed
var head_yaw = 0 #degrees; 0 points along -z; 90 points to +x
var head_thrust = 0 #+ points to -z
var head_slip = 0 #+ points to +x
var  head_x = 0
var head_z = 0
var head_y = 0
var head_yaw_angle = 0
var starting_head_yaw = 180
var LeftEyeDirection = Vector3.ZERO #direction the left eye is pointing
var RightEyeDirection = Vector3.ZERO #

#logging/saving stuff
var reward_order := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var scene_duration = 0 #max duration of the scene
var track_num = 0
var track_xpos = 0
var track_reward_loc = 0
var current_rep = 1
var rewarded = 0
var reward_trial = 1
var rewarded_frame = 0
var reward_out = 0
var lick_in = 0
var current_frame = 0
var dataNames = ['head_yaw', 'head_thrust', 'head_slip', 'head_x', 'head_z', 'head_yaw_angle', 'reward_out', 'lick_in', 'ms_now']


# Called when the node enters the scene tree for the first time.
func _ready():	
	experimentName =  timestamp + "_" + scene_name
	
	#determine whether to reward
	for i in range(num_rewards_out_of_10):
		reward_order[i] = 1
	reward_order.shuffle()
	reward_trial = reward_order[current_rep]
	
	track_reward_loc = mouse_num_reward_loc[mouse_num-1]
	track_num = mouse_num_track_num[mouse_num-1]
	if track_num==1:
		track_xpos = track1_xpos;
	if track_num==2:
		track_xpos = track2_xpos;
	
	#head positions
	head_y = head_radius
	head_yaw_angle = starting_head_yaw
	head_x = track_xpos
	head_z = -(track_length/2) + head_radius
	rewarded = 0
	
	scene_duration = num_reps*trial_duration
	
	#start experiment
	var experimentDuration = num_reps*trial_duration
	overlay.color = Color(0, 0, 0, 1-brightness_modulate) #modulate brightness with black overlay transparency 
	start_experiment(experimentDuration)
	if reward_trial || guaranteed_rewards>0:
		print("rep " + String(current_rep))
		reward_trial = 1
	else:
		print("rep " + String(current_rep) + " (no reward)")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#calculate fps (method 2)
	ms_now = OS.get_ticks_msec() - ms_start
	times.append(ms_now)
	while times.size() > 0 and times[0] <= ms_now - 1000:
		times.pop_front() # Remove frames older than 1 second in the `times` array
	fps = times.size()
	current_frame += 1
		
	#calculate head angle
	head_yaw_angle += mouse_gain*yaw_gain*head_yaw
	
	#keep mouse facing forward?
	if head_yaw_angle>(starting_head_yaw+max_yaw):
		head_yaw_angle = starting_head_yaw+max_yaw
	if head_yaw_angle<(starting_head_yaw-max_yaw):
		head_yaw_angle = starting_head_yaw-max_yaw
		
	#calculate head position
	head_z += mouse_gain*(thrust_gain*head_thrust*cos(deg2rad(head_yaw_angle)) + slip_gain*head_slip*sin(deg2rad(head_yaw_angle)))
#	head_x += mouse_gain*(-thrust_gain*head_thrust*sin(deg2rad(head_yaw_angle)) + slip_gain*head_slip*cos(deg2rad(head_yaw_angle)))
	fpslabel.text = str(head_x) 
	
	#keep head inside of linear track
	if head_z>((track_length/2)-head_radius):
		head_z = (track_length/2)-head_radius
	if head_z<(-(track_length/2)+head_radius):
		head_z = -(track_length/2)+head_radius
	if head_x>(track_xpos+(track_width/2)-head_radius):
		head_x = (track_xpos+(track_width/2)-head_radius)
	if head_x<(track_xpos-(track_width/2)+head_radius):
		head_x = (track_xpos-(track_width/2)+head_radius)
		
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
	
	#control color button based on current position
	if reward_trial && (head_z>=track_reward_loc) && (head_z<=(track_reward_loc+track_reward_range)) && rewarded==0:
		if (current_rep<=guaranteed_rewards) || (lick_in_reward_required==0) || (lick_in>0): 
			Input.start_joy_vibration(0,1,1,reward_dur) #for using xinput rumble output
			colorrect.color = Color(1, 1, 1)
			rewarded = 1
			reward_out = 1
			rewarded_frame = current_frame
	else: 
		if reward_trial && (reward_out==1) && ((current_frame-rewarded_frame)>=(reward_dur*frames_per_second)):
			reward_out = 0
			colorrect.color = Color(0, 0, 0)
	
	#log data	
	dataArray = [head_yaw, head_thrust, head_slip, head_x, head_z, head_yaw_angle, reward_out, lick_in, ms_now]
	for i in range(dataArray.size()):
		dataLog.append(dataArray[i])
	
	#update text label
#	fpslabel.text = str(fps) + " FPS" 
	fpslabel.text = str(lick_in) 
#	fpslabel.text = ""
	
	#reset inputs
	head_thrust = 0
	head_slip = 0
	head_yaw = 0
	
	#next trial
	if (head_z == (track_length/2)-head_radius) || (current_frame > trial_duration*frames_per_second):
		saveUtils.save_logs(current_rep,dataLog,dataNames,experimentName) #save current logged data to a new file
		dataLog = [] #clear saved data
		current_frame = 1
		current_rep += 1
		if (current_rep>num_reps):
			stop_experiment()
		else:
			head_yaw_angle = 180
			head_x = track_xpos
			head_z = -(track_length/2) + head_radius
			rewarded = 0
			if (((current_rep-1)%10)==0):
				reward_order.shuffle()
			reward_trial = reward_order[(current_rep-1)%10]
			if reward_trial || current_rep<=guaranteed_rewards:
				print("rep " + String(current_rep))
				reward_trial = 1
			else:
				print("rep " + String(current_rep) + " (no reward)")
			


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
			
	if ev is InputEventJoypadMotion:
		if ev.get_axis()==2:
			lick_in = round(1000*ev.get_axis_value());
		else:
			print("Unexpected button pressed: ",ev.get_button_index(),", ",Input.get_joy_button_string(ev.get_button_index()))
		

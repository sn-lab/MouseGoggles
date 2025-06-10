#get common settings
extends "res://commonSettings.gd"

#optomotor parameters
export var temporal_frequency = 1.5 #grating cycles per second
export var wavelengths = [24, 12, 8, 6, 4, 2, 1]
export var scene_name = "optomotor"
export var trial_duration = 6
export var stim_duration = 2
export var predelay = 4
export var num_trials = 14
export var num_reps = 5

#headkinbody viewport nodes
onready var lefthead = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/TextureRect/Viewport/LeftEyeBody")
onready var righthead = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/TextureRect/Viewport/RightEyeBody")
onready var lefteye = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/TextureRect/Viewport/LeftEyeBody/LeftEyePivot")
onready var righteye = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/TextureRect/Viewport/RightEyeBody/RightEyePivot")
onready var colorrect = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/ColorRect")
onready var fpslabel = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/Label")
onready var overlay = get_node("HeadKinBody/Control/Overlay")

#optomotor variables
var rotation_speed = 0 #degrees per second
var rotation_angle = 0 #degrees
var rotation_direction = 0 #1 or -1, for clockwise/counterclockwise
var cur_wavelength = 0
var cur_wavelength_trial = 0
var start_predelay = 0

#head/eye position variables
var head_yaw = 0 #degrees; 0 points along -z; 90 points to +x
var head_thrust = 0 #+ points to -z
var head_slip = 0 #+ points to +x
var head_yaw_angle = 0
var right_eye_angle = 0
var left_eye_angle = 0
var eye_yaw_angle = 0
var LeftEyeDirection = Vector3.ZERO #direction the left eye is pointing
var RightEyeDirection = Vector3.ZERO #

#logging/saving stuff
var current_trial = 0
var current_condition = 0
var current_rep = 1
var lick_in = 0
var trial_order := []
var statecolor = Color(0, 0, 0)
var current_frame = 0
var dataNames = ['head_yaw', 'head_thrust', 'head_slip', 'cur_wavelength', 'rotation_direction', 'ms_now']


# Called when the node enters the scene tree for the first time.
func _ready():	
	experimentName =  timestamp + "_" + scene_name
	
	# set new eye positions
	eye_pitch = 0 #degrees from the horizontal
	
	#get starting wavelength
	for i in range(num_trials):
		trial_order.append(i)
	trial_order.shuffle()
	current_trial = 0
	current_condition = trial_order[current_trial]
	if ((trial_order[current_trial])>=(num_trials/2)):
		cur_wavelength_trial = current_condition - (num_trials/2)
		rotation_direction = -1
	else:
		cur_wavelength_trial = current_condition
		rotation_direction = 1
	cur_wavelength = 0
	lefteye.translation.z = -3
	righteye.translation.z = -3
	start_predelay = 1
	
	#start experiment
	var experimentDuration = num_reps*num_trials*trial_duration
	overlay.color = Color(0, 0, 0, 1-brightness_modulate) #modulate brightness with black overlay transparency 
	start_experiment(experimentDuration)
	print("trial order " + str(trial_order))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#calculate fps
	ms_now = OS.get_ticks_msec() - ms_start
	times.append(ms_now)
	while times.size() > 0 and times[0] <= ms_now - 1000:
		times.pop_front() # Remove frames older than 1 second in the `times` array
	fps = times.size()
#	fpslabel.text = str(fps) + " FPS" 
	current_frame += 1
	
	#update trial
	if (start_predelay==1) && (current_frame>=(predelay*frames_per_second)):
		start_predelay = 0
		current_frame = 1
		cur_wavelength = wavelengths[cur_wavelength_trial]
		lefteye.translation.z = 3*cur_wavelength_trial
		righteye.translation.z = 3*cur_wavelength_trial
		rotation_speed = cur_wavelength*temporal_frequency
		print("rep " + str(current_rep) + ", trial " + str(current_condition) + ": wavelength " + str(cur_wavelength) + ", direction " + str(rotation_direction))
	if (current_frame == 1+(stim_duration*frames_per_second)):
		cur_wavelength = 0
		lefteye.translation.z = -3
		righteye.translation.z = -3
	
	#calculate eye direction based on spatial wavelength
	rotation_angle += rotation_direction*delta*rotation_speed
	lefteye.rotation_degrees.y = rotation_angle+eye_yaw
	lefteye.rotation_degrees.x = eye_pitch
	righteye.rotation_degrees.y = rotation_angle-eye_yaw
	righteye.rotation_degrees.x = eye_pitch
	
	#log data
	dataArray = [head_yaw, head_thrust, head_slip, cur_wavelength, rotation_direction, ms_now]
	for i in range(dataArray.size()):
		dataLog.append(dataArray[i])
	
	#update text label
	fpslabel.text = str(rotation_direction*cur_wavelength)
#	fpslabel.text = ""
	
	#reset movements
	head_thrust = 0
	head_slip = 0
	head_yaw = 0
	
	#next trial
	if (start_predelay==0) && (current_frame > trial_duration*frames_per_second):
		current_frame = 1
		current_trial += 1
		if (current_trial==num_trials):
			saveUtils.save_logs(current_rep,dataLog,dataNames,experimentName) #save current logged data to a new file
			dataLog = [] #clear saved data
			current_trial = 0
			current_rep += 1
			if (current_rep > num_reps):
				stop_experiment()
			trial_order.shuffle()
			print("trial order " + str(trial_order))
		current_condition = trial_order[current_trial]
		if (current_condition>=(num_trials/2)):
			cur_wavelength_trial = current_condition - (num_trials/2)
			rotation_direction = -1
		else:
			cur_wavelength_trial = current_condition
			rotation_direction = 1
		if (current_rep <= num_reps):
			cur_wavelength = wavelengths[cur_wavelength_trial]
			lefteye.translation.z = 3*(cur_wavelength_trial)
			righteye.translation.z = 3*(cur_wavelength_trial)
			rotation_speed = cur_wavelength*temporal_frequency
			print("rep " + str(current_rep) + ", trial " + str(current_condition) + ": wavelength " + str(cur_wavelength) + ", direction " + str(rotation_direction))
	


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
		

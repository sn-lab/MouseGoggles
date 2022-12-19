extends Spatial

#optomotor constants
export var temporal_frequency = 1.5 #grating cycles per second
export var wavelengths = [24, 12, 8, 6, 4, 2, 1]
export var scene_name = "optomotor"
export var trial_duration = 6
export var stim_duration = 2
export var predelay = 10
export var num_trials = 14
export var num_reps = 5

#optomotor variables
export var rotation_speed = 0 #degrees per second
export var rotation_angle = 0 #degrees
export var rotation_direction = 0 #1 or -1, for clockwise/counterclockwise
export var cur_wavelength = 0
export var cur_wavelength_trial = 0
export var start_predelay = 0

#viewport nodes
onready var lefthead = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/TextureRect/Viewport/LeftEyeBody")
onready var righthead = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/TextureRect/Viewport/RightEyeBody")
onready var lefteye = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/TextureRect/Viewport/LeftEyeBody/LeftEyePivot")
onready var righteye = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/TextureRect/Viewport/RightEyeBody/RightEyePivot")
onready var colorrect = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/ColorRect")
onready var fpslabel = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/Label")

#eye constants
export var inter_eye_distance = 0
export var head_radius = 0.04 #must be large enough to keep eye cameras from getting too close to walls
export var eye_pitch = 0 #degrees from the horizontal
export var eye_yaw = 45 #degrees away from the head yaw

#movement senitivites
export var frames_per_second = 60.0
export var thrust_gain = 1 #meters per step
export var slip_gain = 1 #meters per step
export var yaw_gain = 1 #degrees per step
export var mouse_gain = 0.05

#head/eye position variables
export var head_yaw = 0 #degrees; 0 points along -z; 90 points to +x
export var head_thrust = 0 #+ points to -z
export var head_slip = 0 #+ points to +x
export var head_yaw_angle = 0
export var right_eye_angle = 0
export var left_eye_angle = 0
export var eye_yaw_angle = 0
export var LeftEyeDirection = Vector3.ZERO #direction the left eye is pointing
export var RightEyeDirection = Vector3.ZERO #

#logging/saving stuff
export var current_trial = 0
export var current_rep = 1
export var trial_order := []
export var times := [] # Timestamps of frames rendered in the last second
export var fps := 0 # Frames per second
export var statecolor = Color(0, 0, 0)
export var current_frame = 0
var yawLog := [] 
var pitchLog := [] 
var rollLog := [] 
var waveLog := [] 
var dirLog := [] 
var timeLog := [] 
var timestamp = ""

# Called when the node enters the scene tree for the first time.
func _ready():	
	#get current time
	var td = OS.get_datetime() # time dictionary
	timestamp = String(td.year) + "_" + String(td.month) + "_" + String(td.day) + "_" + String(td.hour) + "_" + String(td.minute) + "_" + String(td.second)
	
	#get starting wavelength
	randomize()
	for i in range(num_trials):
		trial_order.append(i)
	trial_order.shuffle()
	print("trial order " + String(trial_order))
	if ((trial_order[current_trial])>=(num_trials/2)):
		cur_wavelength_trial = trial_order[current_trial] - (num_trials/2)
		rotation_direction = -1
	else:
		cur_wavelength_trial = trial_order[current_trial]
		rotation_direction = 1
	print("cur wavelength trial " + String(cur_wavelength_trial))
	cur_wavelength = 0
	lefteye.translation.z = -3
	righteye.translation.z = -3
	start_predelay = 1
	
	#input setup
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#calculate fps
	var now := OS.get_ticks_msec()
	times.append(now)
	while times.size() > 0 and times[0] <= now - 1000:
		times.pop_front() # Remove frames older than 1 second in the `times` array
	if times.size()>1:
		fps = 1000/average_difference(times)
#	fpslabel.text = str(fps) + " FPS" 
	
	#update trial
	current_frame += 1
	if (start_predelay==1) && (current_frame>=(predelay*frames_per_second)):
		start_predelay = 0
		current_frame = 1
		cur_wavelength = wavelengths[cur_wavelength_trial]
		lefteye.translation.z = 3*cur_wavelength_trial
		righteye.translation.z = 3*cur_wavelength_trial
		rotation_speed = cur_wavelength*temporal_frequency
		print("wavelength " + String(cur_wavelength) + ", direction " + String(rotation_direction))
	if (current_frame == 1+(stim_duration*frames_per_second)):
		cur_wavelength = 0
		lefteye.translation.z = -3
		righteye.translation.z = -3
	fpslabel.text = str(rotation_direction*cur_wavelength)
	
	#calculate eye direction based on spatial wavelength
	rotation_angle += rotation_direction*delta*rotation_speed
	lefteye.rotation_degrees.y = rotation_angle+eye_yaw
	lefteye.rotation_degrees.x = eye_pitch
	righteye.rotation_degrees.y = rotation_angle-eye_yaw
	righteye.rotation_degrees.x = eye_pitch
	
	#save data
	yawLog.append(head_yaw)
	pitchLog.append(head_thrust)
	rollLog.append(head_slip)
	waveLog.append(cur_wavelength)
	dirLog.append(rotation_direction)
	timeLog.append(now)
	
	#reset movements
	head_thrust = 0
	head_slip = 0
	head_yaw = 0
	
	#next trial
	if (start_predelay==0) && (current_frame > trial_duration*frames_per_second):
		current_frame = 1
		current_trial += 1
		if (current_trial==num_trials):
			current_trial = 0
			current_rep += 1
			if (current_rep > num_reps):
				save_logs(yawLog,pitchLog,rollLog,waveLog,dirLog,timeLog)
				get_tree().quit() 
			trial_order.shuffle()
			print("trial order " + String(trial_order))
		if ((trial_order[current_trial])>=(num_trials/2)):
			cur_wavelength_trial = trial_order[current_trial] - (num_trials/2)
			rotation_direction = -1
		else:
			cur_wavelength_trial = trial_order[current_trial]
			rotation_direction = 1
		if (current_rep <= num_reps):
			cur_wavelength = wavelengths[cur_wavelength_trial]
			lefteye.translation.z = 3*(cur_wavelength_trial)
			righteye.translation.z = 3*(cur_wavelength_trial)
			rotation_speed = cur_wavelength*temporal_frequency
			print("wavelength " + String(cur_wavelength) + ", direction " + String(rotation_direction))
	
func _input(ev):
	if ev is InputEventKey and ev.is_pressed():
		if ev.scancode == KEY_ESCAPE:
			get_tree().quit() 
			
	if ev is InputEventMouseMotion:
		head_yaw += ev.relative.x
		head_thrust += ev.relative.y
		
	if ev is InputEventMouseButton:
		if ev.is_pressed():
			if ev.button_index == BUTTON_WHEEL_UP:
				head_slip += 1
			if ev.button_index == BUTTON_WHEEL_DOWN:
				head_slip -= 1

func save_logs(col1,col2,col3,col4,col5,col6):
	var file = File.new()
	if (file.open("res://logs//" + timestamp + "_" + scene_name + "_godotlogs.txt", File.WRITE)== OK):
		for i in range(col1.size()):
			file.store_line(String(col1[i]) + "," + String(col2[i]) + "," + String(col3[i]) + "," + String(col4[i]) + "," + String(col5[i]) + "," + String(col6[i]) + "\r")
		file.close()

func average_difference(numbers: Array) -> float:
	var diff := 0.0
	for i in range(numbers.size()-1):
		diff += numbers[i+1] - numbers[i]
	return diff/(numbers.size()-1)


extends Spatial

#optomotor parameters
export var temporal_frequency = 1.5 #grating cycles per second
export var wavelengths = [24, 12, 8, 6, 4, 2, 1]
export var scene_name = "optomotor"
export var trial_duration = 6
export var stim_duration = 2
export var predelay = 4
export var num_trials = 14
export var num_reps = 5

#eye parameters
export var inter_eye_distance = 0
export var head_radius = 0.04 #must be large enough to keep eye cameras from getting too close to walls
export var eye_pitch = 0 #degrees from the horizontal
export var eye_yaw = 50 #degrees away from the head yaw

#movement parameters
export var frames_per_second = 60.0
export var thrust_gain = -0.01 #meters per step
export var slip_gain = 0.01 #meters per step
export var yaw_gain = 5 #degrees per step
export var mouse_gain = 0.0135

#optomotor variables
var rotation_speed = 0 #degrees per second
var rotation_angle = 0 #degrees
var rotation_direction = 0 #1 or -1, for clockwise/counterclockwise
var cur_wavelength = 0
var cur_wavelength_trial = 0
var start_predelay = 0

#viewport nodes
onready var lefthead = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/TextureRect/Viewport/LeftEyeBody")
onready var righthead = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/TextureRect/Viewport/RightEyeBody")
onready var lefteye = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/TextureRect/Viewport/LeftEyeBody/LeftEyePivot")
onready var righteye = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/TextureRect/Viewport/RightEyeBody/RightEyePivot")
onready var colorrect = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/ColorRect")
onready var fpslabel = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/Label")

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
var times := [] # Timestamps of frames rendered in the last second
var fps := 0 # Frames per second
var statecolor = Color(0, 0, 0)
var current_frame = 0
var dataNames = ['head_yaw', 'head_thrust', 'head_slip', 'cur_wavelength', 'rotation_direction', 'ms_now']
var dataArray := []
var dataLog := []
var timestamp = "_"
var ms_start := OS.get_ticks_msec()
var ms_now := OS.get_ticks_msec()

# Called when the node enters the scene tree for the first time.
func _ready():	
	var td = OS.get_datetime() # time dictionary
	ms_start = OS.get_ticks_msec()
	timestamp = String(td.year) + "_" + String(td.month) + "_" + String(td.day) + "_" + String(td.hour) + "_" + String(td.minute) + "_" + String(td.second)

	#get starting wavelength
	randomize()
	for i in range(num_trials):
		trial_order.append(i)
	trial_order.shuffle()
	current_trial = 0
	current_condition = trial_order[current_trial]
	print("trial order " + str(trial_order))
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
	
	#input setup
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
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
			save_logs(current_rep,dataLog,dataNames) #save current logged data to a new file
			dataLog = [] #clear saved data
			current_trial = 0
			current_rep += 1
			if (current_rep > num_reps):
				get_tree().quit() 
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
			
	if ev is InputEventJoypadMotion:
		if ev.get_axis()==2:
			lick_in = round(1000*ev.get_axis_value());
		else:
			print("Unexpected button pressed: ",ev.get_button_index(),", ",Input.get_joy_button_string(ev.get_button_index()))
		


func save_logs(current_rep,dataLog,dataNames):
	var file = File.new()
	var numColumns = dataNames.size()
	var numRows = dataLog.size()/numColumns
	var n = 0
	if (file.open("res://logs//" + timestamp + "_" + scene_name + "_rep" + String(current_rep) + "_godotlogs.txt", File.WRITE)== OK):
		for i in range(numColumns):
			file.store_string(String(dataNames[i]))
			if i<(numColumns-1):
				file.store_string(",")
		file.store_string("\r")
		for l in range(numRows):
			for i in range(numColumns):
				file.store_string(String(dataLog[n]))
				if i<(numColumns-1):
					file.store_string(",")
				n = n+1
			file.store_string("\r")
		file.close()

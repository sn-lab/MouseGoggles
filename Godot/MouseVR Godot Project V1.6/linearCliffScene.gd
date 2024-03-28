extends Spatial

#cliff parameters
export var scene_name = "linearvisualcliff"
export var num_reps = 5
export var num_trials = 4
export var condition_angles = [0.0, 180.0, 0.0, 180.0]
export var condition_start_positions = [0, 0, 0, 0]
export var condition_eye_distances = [0.0, 0.0, 0.01, 0.01]
export var trial_duration = 600
export var max_z = 1
export var min_z = -1
export var max_x = 0

#eye parameters
export var inter_eye_distance = 0.01
export var head_radius = 0.04 #must be large enough to keep eye cameras from getting too close to walls
export var eye_pitch = 10 #degrees from the horizontal
export var eye_yaw = 60 #degrees away from the head yaw
export var head_roll = 0 #degrees tilted from the horizon

#movement parameters
export var frames_per_second = 60.0
export var thrust_gain = -0.02 #meters per step
export var slip_gain = 0.01 #meters per step
export var yaw_gain = 5 #degrees per step
export var mouse_gain = 0.0135

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
var head_x = 0
var head_z = 0
var head_y = 0
var head_yaw_angle = 0
var LeftEyeDirection = Vector3.ZERO #direction the left eye is pointing
var RightEyeDirection = Vector3.ZERO #

#logging/saving stuff
var trial_order = [0, 1, 2, 3]
var current_rep = 1
var current_trial_counter = 1
var current_trial_index = 0
var lick_in = 0
var times := [] # Timestamps of frames rendered in the last second
var fps := 0 # Frames per second
var statecolor = Color(0, 0, 0)
var current_frame = 0
var dataNames = ['head_yaw', 'head_thrust', 'head_slip', 'head_x', 'head_z', 'head_yaw_angle', 'current_trial_index', 'ms_now']
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

	#constant positions
	head_y = head_radius
	
	#set starting direction
	randomize()
	trial_order.shuffle()
	head_x = 0
	head_yaw_angle = condition_angles[trial_order[0]]
	head_z = condition_start_positions[trial_order[0]]
	current_trial_index = trial_order[current_trial_counter-1];
	
	print("rep " + str(current_rep) + ", trial order: " + str(trial_order))
	if current_trial_index==0:
		print("trial 0: texture stereo")
	elif current_trial_index==1:
		print("trial 1: cliff stereo")
	elif current_trial_index==2:
		print("trial 2: texture mono")
	else:
		print("trial 3: cliff mono")
	
	#rotate eyes relative to body
	lefteye.rotation_degrees.x = eye_pitch
	lefteye.rotation_degrees.y = -head_yaw_angle+eye_yaw
	lefteye.rotation_degrees.z = head_roll
	righteye.rotation_degrees.x = eye_pitch
	righteye.rotation_degrees.y = -head_yaw_angle-eye_yaw
	righteye.rotation_degrees.z = head_roll
	
	#translate head position
	righthead.translation.x = head_x
	righthead.translation.y = head_y
	righthead.translation.z = head_z
	lefthead.translation.x = head_x
	lefthead.translation.y = head_y
	lefthead.translation.z = head_z
	
	#translate eyes relative to head/body
	lefteye.translation.x = head_x - (0.5*inter_eye_distance*cos(deg2rad(head_yaw_angle))*cos(deg2rad(head_roll)))
	lefteye.translation.y = head_y - (0.5*inter_eye_distance*sin(deg2rad(head_roll)))
	lefteye.translation.z = head_z - (0.5*inter_eye_distance*sin(deg2rad(head_yaw_angle))*cos(deg2rad(head_roll)))
	righteye.translation.x = head_x + (0.5*inter_eye_distance*cos(deg2rad(head_yaw_angle))*cos(deg2rad(head_roll)))
	righteye.translation.y = head_y + (0.5*inter_eye_distance*sin(deg2rad(head_roll)))
	righteye.translation.z = head_z + (0.5*inter_eye_distance*sin(deg2rad(head_yaw_angle))*cos(deg2rad(head_roll)))
	
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
	
	#calculate head position
	head_yaw_angle += mouse_gain*yaw_gain*head_yaw
	head_z += mouse_gain*(thrust_gain*head_thrust*cos(deg2rad(head_yaw_angle)) + slip_gain*head_slip*sin(deg2rad(head_yaw_angle)))
	head_x += (-mouse_gain*thrust_gain*head_thrust*sin(deg2rad(head_yaw_angle))) + (mouse_gain*slip_gain*head_slip*cos(deg2rad(head_yaw_angle)))
	
	#keep head close to x-center of floor 
	if head_x>max_x:
		head_x = head_x-(2*max_x);
	if head_x<-max_x:
		head_x = head_x+(2*max_x);
	
	#translate head position
	righthead.translation.z = head_z
	righthead.translation.x = head_x
	lefthead.translation.z = head_z
	lefthead.translation.x = head_x
	
	#rotate eyes relative to body
	lefteye.rotation_degrees.x = eye_pitch
	lefteye.rotation_degrees.y = -head_yaw_angle+eye_yaw
	lefteye.rotation_degrees.z = head_roll
	righteye.rotation_degrees.x = eye_pitch
	righteye.rotation_degrees.y = -head_yaw_angle-eye_yaw
	righteye.rotation_degrees.z = head_roll
	
	#translate eyes relative to head/body
	lefteye.translation.x = head_x - (0.5*inter_eye_distance*cos(deg2rad(head_yaw_angle))*cos(deg2rad(head_roll)))
	lefteye.translation.y = head_y - (0.5*inter_eye_distance*sin(deg2rad(head_roll)))
	lefteye.translation.z = head_z - (0.5*inter_eye_distance*sin(deg2rad(head_yaw_angle))*cos(deg2rad(head_roll)))
	righteye.translation.x = head_x + (0.5*inter_eye_distance*cos(deg2rad(head_yaw_angle))*cos(deg2rad(head_roll)))
	righteye.translation.y = head_y + (0.5*inter_eye_distance*sin(deg2rad(head_roll)))
	righteye.translation.z = head_z + (0.5*inter_eye_distance*sin(deg2rad(head_yaw_angle))*cos(deg2rad(head_roll)))
		
	#log data
	dataArray = [head_yaw, head_thrust, head_slip, head_x, head_z, head_yaw_angle, current_trial_index, ms_now]
	for i in range(dataArray.size()):
		dataLog.append(dataArray[i])
	
	#update text label
#	fpslabel.text = str(fps) + " FPS" # Display FPS in the label
#	fpslabel.text = str(current_frame-reached_cliff_frame)
#	fpslabel.text = str(head_z)
#	fpslabel.text = str(head_yaw_angle)
#	fpslabel.text = ""
	fpslabel.text = str(current_trial_index)
	
	#reset movements
	head_thrust = 0
	head_slip = 0
	head_yaw = 0
	
	#next trial
	current_frame += 1
	if current_frame>=(trial_duration*frames_per_second) || abs(head_z)>max_z:
		current_trial_counter += 1
		current_frame = 1
		if (current_trial_counter>num_trials):
			save_logs(current_rep,dataLog,dataNames) #save current logged data to a new file
			dataLog = [] #clear saved data
			current_trial_counter = 1
			current_rep += 1
			trial_order.shuffle()
			if (current_rep>num_reps):
				get_tree().quit() 
			else: 
				print("rep " + str(current_rep) + ", trial order: " + str(trial_order))
		current_trial_index = trial_order[current_trial_counter-1];
		head_x = 0
		head_yaw_angle = condition_angles[current_trial_index]
		head_z = condition_start_positions[current_trial_index]
		if current_trial_index==0:
			print("trial 0: texture stereo")
		elif current_trial_index==1:
			print("trial 1: cliff stereo")
		elif current_trial_index==2:
			print("trial 2: texture mono")
		else:
			print("trial 3: cliff mono")
		


func _input(ev):
	if ev is InputEventKey and ev.is_pressed():
		if ev.scancode == KEY_ESCAPE:
			get_tree().quit() 
			
	if ev is InputEventMouseMotion:
		#head_yaw += ev.relative.x
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

#get common settings
extends "res://commonSettings.gd"

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
var statecolor = Color(0, 0, 0)
var current_frame = 0
var dataNames = ['head_yaw', 'head_thrust', 'head_slip', 'head_x', 'head_z', 'head_yaw_angle', 'current_trial_index', 'ms_now']


# Called when the node enters the scene tree for the first time.
func _ready():
	experimentName =  timestamp + "_" + scene_name
	
	#constant positions
	head_y = head_radius
	righthead.translation.y = head_y
	lefthead.translation.y = head_y
	
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
	
	#translate eyes relative to body
	lefteye.translation.z = head_z - condition_eye_distances[current_trial_index]*sin(deg2rad(head_yaw_angle))
	lefteye.translation.x = head_x - condition_eye_distances[current_trial_index]*cos(deg2rad(head_yaw_angle))
	righteye.translation.z = head_z + condition_eye_distances[current_trial_index]*sin(deg2rad(head_yaw_angle))
	righteye.translation.x = head_x + condition_eye_distances[current_trial_index]*cos(deg2rad(head_yaw_angle))
	
	#rotate eyes relative to body
	lefteye.rotation_degrees.y = -head_yaw_angle+eye_yaw
	lefteye.rotation_degrees.x = eye_pitch
	righteye.rotation_degrees.y = -head_yaw_angle-eye_yaw
	righteye.rotation_degrees.x = eye_pitch
	
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
			saveUtils.save_logs(current_rep,dataLog,dataNames,experimentName) #save current logged data to a new file
			dataLog = [] #clear saved data
			current_trial_counter = 1
			current_rep += 1
			trial_order.shuffle()
			if (current_rep>num_reps):
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				get_tree().change_scene("res://sceneSelect.tscn")
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
			saveUtils.save_logs(current_rep,dataLog,dataNames,experimentName) #save current logged data to a new file
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().change_scene("res://sceneSelect.tscn")
			
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
		

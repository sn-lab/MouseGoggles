extends Spatial

#linear track constants
export var track_length = 1.5
export var scene_duration = 1800 #max duration of the scene
export var trial_duration = 60 #max duration of each trial
export var scene_name = "openfield"
export var reward_dur = 0.05 #duration to open liquid reward valve)
export var num_reps = 40 #max number of trials 

#track variables
export var reward_xloc = 0.75 #location of reward (start wall = -0.5, end wall = 0.5)
export var reward_zloc = 0.75 #location of reward (start wall = -0.5, end wall = 0.5)
export var min_start_distance = 0.75 #minimum distance the mouse can start from the reward
export var reward_range = 0.15 #maximum distance to the reward before a reward is given
export var after_reward_delay = 3 #time after a reward is given before new trial starts
export var reward_rate = 1.0 #fraction of trials which are rewarded (randomly)
export var guaranteed_rewards = 3 #number of beginning trials to guarantee rewards

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
export var thrust_gain = 0.02 #meters per step
export var slip_gain = 0.1 #meters per step
export var yaw_gain = 5 #degrees per step
export var mouse_gain = 0.05

#head/eye position variables
export var head_yaw = 0 #degrees; 0 points along -z; 90 points to +x
export var head_thrust = 0 #+ points to -z
export var head_slip = 0 #+ points to +x
export var head_x = 0
export var head_z = 0
export var head_y = 0
export var head_yaw_angle = 0
export var LeftEyeDirection = Vector3.ZERO #direction the left eye is pointing
export var RightEyeDirection = Vector3.ZERO #

#logging/saving stuff
export var current_rep = 1
export var rewarded = 0
export var reward_trial = 1
export var rewarded_frame = 0
export var reward_out = 0
export var lick_in = 0
export var distance_to_reward = 0
export var times := [] # Timestamps of frames rendered in the last second
export var fps := 0 # Frames per second
export var current_frame = 0
var now := OS.get_ticks_msec()
var yawLog := [] 
var pitchLog := [] 
var rollLog := [] 
var xLog := [] 
var zLog := [] 
var angLog := []
var rewardLog := []
var lickLog := []
var timeLog := [] 
var timestamp = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	#head positions
	head_y = head_radius
	head_yaw_angle = randf()*360
	head_x = track_length*(randf()-0.5)
	head_z = track_length*(randf()-0.5)
	distance_to_reward = sqrt(((head_x-reward_xloc)*(head_x-reward_xloc)) + ((head_z-reward_zloc)*(head_z-reward_zloc)))
	while (distance_to_reward<min_start_distance):
		head_x = track_length*(randf()-0.5)
		head_z = track_length*(randf()-0.5)
		distance_to_reward = sqrt(((head_x-reward_xloc)*(head_x-reward_xloc)) + ((head_z-reward_zloc)*(head_z-reward_zloc)))
		
	rewarded = 0
	reward_trial = (randf()<=reward_rate) || (current_rep<=guaranteed_rewards)
	if reward_trial:
		print("rep " + String(current_rep))
	else:
		print("rep " + String(current_rep) + " (no reward)")
	
	#get current time
	var td = OS.get_datetime() # time dictionary
	timestamp = String(td.year) + "_" + String(td.month) + "_" + String(td.day) + "_" + String(td.hour) + "_" + String(td.minute) + "_" + String(td.second)
#	timestamp = Time.get_time_string_from_system() # OS.get_datetime deprecated in Godot 4?
	
	#input setup
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#calculate fps (method 2)
	var now := OS.get_ticks_msec()
	times.append(now)
	while times.size() > 0 and times[0] <= now - 1000:
		times.pop_front() # Remove frames older than 1 second in the `times` array
	if times.size()>1:
		fps = 1000/average_difference(times)
	
	#calculate head position
	head_yaw_angle += mouse_gain*yaw_gain*head_yaw
	head_z += (mouse_gain*thrust_gain*head_thrust*cos(deg2rad(head_yaw_angle))) + (mouse_gain*slip_gain*head_slip*sin(deg2rad(head_yaw_angle)))
	head_x += (-mouse_gain*thrust_gain*head_thrust*sin(deg2rad(head_yaw_angle))) + (mouse_gain*slip_gain*head_slip*cos(deg2rad(head_yaw_angle)))
	fpslabel.text = str(head_x) 
	
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
	
	#control color button based on current position
	distance_to_reward = sqrt(((head_x-reward_xloc)*(head_x-reward_xloc)) + ((head_z-reward_zloc)*(head_z-reward_zloc)))
	if reward_trial && (distance_to_reward<=reward_range) && rewarded==0:
		#for using xinput rumble output
		Input.start_joy_vibration(0,1,1,reward_dur)
		colorrect.color = Color(1, 1, 1)
		rewarded = 1
		reward_out = 1
		rewarded_frame = current_frame
	else: 
		if reward_trial && (reward_out==1) && ((current_frame-rewarded_frame)>=(reward_dur*frames_per_second)):
			reward_out = 0
			colorrect.color = Color(0, 0, 0)
	
	#log data
	current_frame += 1
	yawLog.append(head_yaw)
	pitchLog.append(head_thrust)
	rollLog.append(head_slip)
	xLog.append(head_x)
	zLog.append(head_z)
	angLog.append(head_yaw_angle)
	rewardLog.append(reward_out)
	lickLog.append(lick_in)
	timeLog.append(now)
		
	#update text label
#	fpslabel.text = str(fps) + " FPS" 
	fpslabel.text = str(lick_in) 
#	fpslabel.text = ""
	
	#reset inputs
	head_thrust = 0
	head_slip = 0
	head_yaw = 0
	
	#next trial
	if (rewarded && (current_frame-rewarded_frame)>=(after_reward_delay*frames_per_second)) || (current_frame > trial_duration*frames_per_second):
		save_logs(current_rep,yawLog,pitchLog,rollLog,xLog,zLog,angLog,rewardLog,lickLog,timeLog)
		yawLog = [] 
		pitchLog = [] 
		rollLog = [] 
		xLog = [] 
		zLog = [] 
		angLog = []
		rewardLog = []
		lickLog = []
		timeLog = [] 
		current_frame = 1
		current_rep += 1
		if (current_rep>num_reps):
			get_tree().quit() 
		else:
			head_yaw_angle = randf()*360
			head_x = track_length*(randf()-0.5)
			head_z = track_length*(randf()-0.5)
			distance_to_reward = sqrt(((head_x-reward_xloc)*(head_x-reward_xloc)) + ((head_z-reward_zloc)*(head_z-reward_zloc)))
			while distance_to_reward<min_start_distance:
				head_x = track_length*(randf()-0.5)
				head_z = track_length*(randf()-0.5)
				distance_to_reward = sqrt(((head_x-reward_xloc)*(head_x-reward_xloc)) + ((head_z-reward_zloc)*(head_z-reward_zloc)))
			rewarded = 0
			reward_trial = randf()<=reward_rate || (current_rep<=guaranteed_rewards)
			if reward_trial:
				print("rep " + String(current_rep))
			else:
				print("rep " + String(current_rep) + " (no reward)")

	
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
		


func save_logs(current_rep,col1,col2,col3,col4,col5,col6,col7,col8,col9):
	var file = File.new()
	if (file.open("res://logs//" + timestamp + "_" + scene_name + "_rep" + String(current_rep) + "_godotlogs.txt", File.WRITE)== OK):
		for i in range(col1.size()):
			file.store_line(String(col1[i]) + "," + String(col2[i]) + "," + String(col3[i]) + "," + String(col4[i]) + "," + String(col5[i]) + "," + String(col6[i]) + "," + String(col7[i]) + "," + String(col8[i]) + "," + String(col9[i]) + "\r")
		file.close()


func average_difference(numbers: Array) -> float:
	var diff := 0.0
	for i in range(numbers.size()-1):
		diff += numbers[i+1] - numbers[i]
	return diff/(numbers.size()-1)

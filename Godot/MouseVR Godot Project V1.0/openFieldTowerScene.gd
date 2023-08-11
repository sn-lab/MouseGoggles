extends Spatial

#open field parameters
export var track_length = 1.5
export var scene_duration = 1800 #max duration of the scene
export var trial_duration = 60 #max duration of each trial
export var scene_name = "openfieldtower"
export var reward_dur = 0.05 #duration to open liquid reward valve)
export var num_reps = 40 #max number of trials 
export var reward_xloc = 0.75 #location of reward (start wall = -0.5, end wall = 0.5)
export var reward_zloc = 0.75 #location of reward (start wall = -0.5, end wall = 0.5)
export var min_start_distance = 0.75 #minimum distance the mouse can start from the reward
export var reward_range = 0.15 #maximum distance to the reward before a reward is given
export var after_reward_delay = 3 #time after a reward is given before new trial starts
export var reward_rate = 1.0 #fraction of trials which are rewarded (randomly)
export var guaranteed_rewards = 3 #number of beginning trials to guarantee rewards

#eye parameters
export var inter_eye_distance = 0.01
export var head_radius = 0.04 #must be large enough to keep eye cameras from getting too close to walls
export var eye_pitch = 10 #degrees from the horizontal
export var eye_yaw = 45 #degrees away from the head yaw

#movement parameters
export var frames_per_second = 60.0
export var thrust_gain = -0.01 #meters per step
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
var current_rep = 1
var rewarded = 0
var reward_trial = 1
var rewarded_frame = 0
var reward_out = 0
var lick_in = 0
var distance_to_reward = 0
var times := [] # Timestamps of frames rendered in the last second
var fps := 0 # Frames per second
var current_frame = 0
var dataNames = ['head_yaw', 'head_thrust', 'head_slip', 'head_x', 'head_z', 'head_yaw_angle', 'reward_out', 'lick_in', 'ms_now']
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

	#head positions
	randomize()
	head_y = 0.01 + head_radius
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
	
	#input setup
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

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
	head_yaw_angle += mouse_gain*yaw_gain*head_yaw
	head_z += mouse_gain*(thrust_gain*head_thrust*cos(deg2rad(head_yaw_angle)) + slip_gain*head_slip*sin(deg2rad(head_yaw_angle)))
	head_x += mouse_gain*(-thrust_gain*head_thrust*sin(deg2rad(head_yaw_angle)) + slip_gain*head_slip*cos(deg2rad(head_yaw_angle)))
	#fpslabel.text = str(head_x) 
	
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
	if (rewarded && (current_frame-rewarded_frame)>=(after_reward_delay*frames_per_second)) || (current_frame > trial_duration*frames_per_second):
		save_logs(current_rep,dataLog,dataNames) #save current logged data to a new file
		dataLog = [] #clear saved data
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

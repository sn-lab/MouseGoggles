extends Spatial

#track parameters
export var mouse_num = 1 #ID of mouse (determines which reward loc/track num to use)
export var num_rewards_out_of_10 = 10 #number of trials (per 10) which are rewarded (randomly)
export var lick_in_reward_required = 0 #whether the mouse has to lick in the reward zone first in order to be rewarded
export var scene_name = "lineartrackloom"
export var track_length = 1.5
export var track_width = 0.1
export var num_reps = 40 #max number of trials 
export var trial_duration = 60 #max duration of each trial
export var reward_dur = 0.05 #duration to open liquid reward valve)
export var mouse_num_reward_loc := 	[-0.25, -0.25, 0.25, 0.25, 0.25] #for mouse [1 2 3 4 5]
export var mouse_num_track_num := 	[2, 2, 2, 2, 2] #for mouse [1 2 3 4 5]
export var track1_xpos = 0 #center x of linear track
export var track2_xpos = 0.5
export var guaranteed_rewards = 3 #number of beginning trials to guarantee rewards
export var track_reward_range = 0.2 #size of reward zone after reward location start

#loom parameters
export var velocity = 25
export var loom_yaw_angle = 0
export var loom_pitch_angle = 45
export var loom_start_distance = 20
export var loom_stop_distance = 0.5774

#eye parameters
export var inter_eye_distance = 0.01
export var head_radius = 0.04 #must be large enough to keep eye cameras from getting too close to walls
export var eye_pitch = 10 #degrees from the horizontal
export var eye_yaw = 45 #degrees away from the head yaw
export var max_yaw = 0 #amount of yaw turning allowed

#movement parameters
export var frames_per_second = 60.0
export var thrust_gain = -0.01 #meters per step
export var slip_gain = 0.01 #meters per step
export var yaw_gain = 5 #degrees per step
export var mouse_gain = 0.0135

#loom variables
var loom_speed = 0 #meters per second
var loom_step = 0
var loom_cur_distance = 0
var direction = 0
var xscale = 0
var yscale = 0
var zscale = 0
var obj_x_pos = 0
var obj_y_pos = 0
var obj_z_pos = 0
var obj_y_ang = 0
var loom_started = false

#viewport nodes
onready var lefthead = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/TextureRect/Viewport/LeftEyeBody")
onready var righthead = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/TextureRect/Viewport/RightEyeBody")
onready var lefteye = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/TextureRect/Viewport/LeftEyeBody/LeftEyePivot")
onready var righteye = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/TextureRect/Viewport/RightEyeBody/RightEyePivot")
onready var colorrect = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/ColorRect")
onready var fpslabel = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/Label")

#object variables
onready var object = get_node("object")
onready var objectMesh = get_node("object/MeshInstance")
var objectMaterial = SpatialMaterial.new()
var objectColor = 0
var object_xpos = 0.0
var object_ypos = 0.0
var object_zpos = 0.0
var va = 0.0

#head/eye position variables
var head_yaw = 0 #degrees; 0 points along -z; 90 points to +x
var head_thrust = 0 #+ points to -z
var head_slip = 0 #+ points to +x
var head_x = 0
var head_z = 0
var head_y = 0
var head_yaw_angle = 0
var starting_head_yaw = 180
var LeftEyeDirection = Vector3.ZERO #direction the left eye is pointing
var RightEyeDirection = Vector3.ZERO #
var statecolor = Color(0, 0, 0)

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
var times := [] # Timestamps of frames rendered in the last second
var fps := 0 # Frames per second
var current_frame = 0
var dataNames = ['head_yaw', 'head_thrust', 'head_slip', 'head_x', 'head_z', 'head_yaw_angle', 'reward_out', 'lick_in', 'loom_cur_distance', 'ms_now']
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
	righthead.translation.y = head_y
	lefthead.translation.y = head_y
	head_x = 0
	head_yaw_angle = 180
	
	#determine whether to reward
	randomize()
	for i in range(num_rewards_out_of_10):
		reward_order[i] = 1
	reward_order.shuffle()
	reward_trial = reward_order[current_rep]
	if reward_trial || guaranteed_rewards>0:
		print("rep " + String(current_rep))
		reward_trial = 1
	else:
		print("rep " + String(current_rep) + " (no reward)")
	
	#set linear track reward location
	track_reward_loc = mouse_num_reward_loc[mouse_num-1]
	track_num = mouse_num_track_num[mouse_num-1]
	if track_num==1:
		track_xpos = track1_xpos;
	if track_num==2:
		track_xpos = track2_xpos;
	
	#set starting head positions
	head_y = head_radius
	head_yaw_angle = starting_head_yaw
	head_x = track_xpos
	head_z = -(track_length/2) + head_radius
	rewarded = 0
	
	scene_duration = num_reps*trial_duration
	
	#set looming object location and movement parameters
	obj_y_ang = direction*loom_yaw_angle
	loom_cur_distance = loom_start_distance
	loom_step = velocity/frames_per_second
	
	xscale = cos(deg2rad(loom_pitch_angle))*sin((loom_yaw_angle))
	yscale = sin(deg2rad(loom_pitch_angle))
	zscale = cos(deg2rad(loom_pitch_angle))*cos(deg2rad(loom_yaw_angle))
	head_z = 0.0

	#object rotations
	object.rotation_degrees.y = obj_y_ang
	object.rotation_degrees.x = loom_pitch_angle
	
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
	
	#update loom
	if loom_started:
		#update loom object position
		if object_zpos<head_z:
			loom_cur_distance = loom_start_distance + loom_step
			
		if  (loom_cur_distance <= loom_stop_distance):
			object_xpos = 0
			object_ypos = 0
			object_zpos = head_z - 10
			loom_started = false
			
		else:
			loom_cur_distance -= loom_step
			if (loom_cur_distance <= loom_stop_distance):
				loom_cur_distance = loom_stop_distance
			object_xpos = head_x + (direction*loom_cur_distance*xscale)
			object_ypos = head_y + (loom_cur_distance*yscale)
			object_zpos = head_z + (loom_cur_distance*zscale)
		object.translation.x = object_xpos
		object.translation.y = object_ypos
		object.translation.z = object_zpos
		objectMaterial.albedo_color = Color(0,0,0,1)
		objectMaterial.flags_unshaded = true
		objectMesh.material_override = objectMaterial
	
	#log data	
	dataArray = [head_yaw, head_thrust, head_slip, head_x, head_z, head_yaw_angle, reward_out, lick_in, loom_cur_distance, ms_now]
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
		save_logs(current_rep,dataLog,dataNames) #save current logged data to a new file
		dataLog = [] #clear saved data
		current_frame = 1
		current_rep += 1
		if (current_rep>num_reps):
			get_tree().quit() 
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
			get_tree().quit() 
		if ev.scancode == KEY_L:
			loom_started = true
			
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
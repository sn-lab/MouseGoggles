extends Spatial

#track parameters
export var mouse_num = 1 #ID of mouse (determines which reward loc/track num to use)
export var scene_name = "lineargap"
export var track_length = 0.75
export var track_width = 0.1
export var num_reps = 23 #max number of trials 
export var trial_duration = 90 #max duration of each trial

#eye parameters
export var inter_eye_distance = 0.01
export var head_radius = 0.03 #must be large enough to keep eye cameras from getting too close to walls
export var eye_pitch = 10 #degrees from the horizontal
export var eye_yaw = 40 #degrees away from the head yaw
export var max_yaw = 0 #amount of yaw turning allowed

#movement parameters
export var frames_per_second = 60.0
export var thrust_gain = -0.01 #meters per step
export var slip_gain = 0.01 #meters per step
export var yaw_gain = 5 #degrees per step
export var mouse_gain = 0.04 #0.0135

#viewport nodes
onready var lefthead = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/TextureRect/Viewport/LeftEyeBody")
onready var righthead = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/TextureRect/Viewport/RightEyeBody")
onready var lefteye = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/TextureRect/Viewport/LeftEyeBody/LeftEyePivot")
onready var righteye = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/TextureRect/Viewport/RightEyeBody/RightEyePivot")
onready var colorrect = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/ColorRect")
onready var fpslabel = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/Label")

#floor node
onready var gapplane = get_node("GapFloor")

#head/eye position variables
var head_yaw = 0 #degrees; 0 points along -z; 90 points to +x
var head_thrust = 0 #+ points to -z
var head_slip = 0 #+ points to +x
var head_x = 0
var head_z = 0
var head_y = 0
var head_yaw_angle = 0
var starting_head_yaw = 180
var track_xpos = 0
var LeftEyeDirection = Vector3.ZERO #direction the left eye is pointing
var RightEyeDirection = Vector3.ZERO #

#logging/saving stuff
var gap_order := [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3]
var num_guaranteed_nogap = 2
var scene_duration = 0 #max duration of the scene
var track_num = 0
var current_rep = 1
var times := [] # Timestamps of frames rendered in the last second
var fps := 0 # Frames per second
var current_frame = 0
var dataNames = ['head_yaw', 'head_thrust', 'head_slip', 'head_z', 'condition', 'ms_now']
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

	#determine whether to reward
	randomize()
	gap_order.shuffle()
	for i in range(num_guaranteed_nogap):
		gap_order[i] = 0
	
	print("condition orders: " + String(gap_order))
	print("rep " + String(current_rep) + " condition " + String(gap_order[current_rep-1]))
	
	#head positions
	head_y = head_radius
	head_yaw_angle = starting_head_yaw
	head_x = 0
	head_z = -(track_length/2) + head_radius
	
	scene_duration = num_reps*trial_duration
	
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
		#control color button based on current position
	if gap_order[current_rep-1]==0:
		inter_eye_distance = 0.02
		gapplane.translation.y = 0
		head_x = 0.1*track_width*sin(6.28*(10*head_z/track_length))
		
	if gap_order[current_rep-1]==1: 
		inter_eye_distance = 0.02
		gapplane.translation.y = -1
		head_x = 0.1*track_width*sin(6.28*(10*head_z/track_length))
		
	if gap_order[current_rep-1]==2: 
		inter_eye_distance = 0
		gapplane.translation.y = -1
		head_x = 0.1*track_width*sin(6.28*(10*head_z/track_length))
		
	if gap_order[current_rep-1]==3: 
		inter_eye_distance = 0.02
		gapplane.translation.y = -1
		head_x = 0
	
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
	
	#log data	
	dataArray = [head_yaw, head_thrust, head_slip, head_z, gap_order[current_rep-1], ms_now]
	for i in range(dataArray.size()):
		dataLog.append(dataArray[i])
	
	#update text label
#	fpslabel.text = str(fps) + " FPS" 
	fpslabel.text = str(gap_order[current_rep-1]) 
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
			print("rep " + String(current_rep) + " condition " + String(gap_order[current_rep-1]))
			


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
extends Spatial

#habituation parameters
export var scene_name = "habituation"
export var trial_duration = 1800
export var reward_dur = 0.05 #seconds to open the reward valve

#eye parameters
export var inter_eye_distance = 0.01
export var head_radius = 0.04 #must be large enough to keep eye cameras from getting too close to walls
export var eye_pitch = 10 #degrees from the horizontal
export var eye_yaw = 45 #degrees away from the head yaw

#movement parameters
export var frames_per_second = 60.0
export var thrust_gain = -0.02 #meters per step
export var slip_gain = 0.01 #meters per step
export var yaw_gain = 5 #degrees per step
export var mouse_gain = 0.0135
export var head_roll = 0 #degrees tilted from the horizon

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

#logging/saving stuff
var lick_in = 0
var reward_out = 0
var times := [] # Timestamps of frames rendered in the last second
var fps := 0 # Frames per second
var statecolor = Color(0, 0, 0)
var current_frame = 0
var dataNames = ['head_yaw', 'head_thrust', 'head_slip', 'reward_out', 'lick_in', 'ms_now']
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
	head_x = 0
	head_yaw_angle = 180
	
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
	current_frame += 1
	
	#move mouse to simulate forward-walking
	head_z += mouse_gain*(thrust_gain*head_thrust*cos(deg2rad(head_yaw_angle)) + slip_gain*head_slip*sin(deg2rad(head_yaw_angle)))
	if (head_z>0.05):
		head_z -= 0.1
	if (head_z<-0.05):
		head_z += 0.1
		
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
	dataArray = [head_yaw, head_thrust, head_slip, reward_out, lick_in, ms_now]
	for i in range(dataArray.size()):
		dataLog.append(dataArray[i])
	
	#update text label
#	fpslabel.text = str(fps) + " FPS" 
#	fpslabel.text = str(head_z)
	fpslabel.text = "R=reward"
	
	#reset movements
	head_thrust = 0
	head_slip = 0
	head_yaw = 0
	reward_out = 0
	
	#end scene
	if (current_frame%int(60*frames_per_second))==0:
		print(str(round(current_frame/(60*frames_per_second))) + " min elapsed")
	if (current_frame > trial_duration*frames_per_second):
		save_logs(1,dataLog,dataNames) #save current logged data to a new file
		dataLog = [] #clear saved data
		get_tree().quit() 

func _input(ev):
	if ev is InputEventKey and ev.is_pressed():
		if ev.scancode == KEY_ESCAPE:
			save_logs(1,dataLog,dataNames) #save current logged data to a new file
			dataLog = [] #clear saved data
			get_tree().quit() 
		if ev.scancode == KEY_R:
			reward_out = 1
			Input.start_joy_vibration(0,1,1,reward_dur) #for using xinput rumble output
			colorrect.color = Color(1, 1, 1)
			yield(get_tree().create_timer(reward_dur), "timeout")
			colorrect.color = Color(0, 0, 0)
			
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


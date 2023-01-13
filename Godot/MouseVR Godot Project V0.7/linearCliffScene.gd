extends Spatial

#cliff parameters
export var scene_name = "linearvisualcliff"
export var num_reps = 10
export var num_directions = 2
export var starting_angles = [0, 180]
export var trial_duration = 30
export var max_z = 1

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
var current_frame = 1
var current_trial = 1
var lick_in = 0
var times := [] # Timestamps of frames rendered in the last second
var fps := 0 # Frames per second
var statecolor = Color(0, 0, 0)
var yawLog := [] 
var pitchLog := [] 
var rollLog := [] 
var zLog := [] 
var angLog := []
var timeLog := [] 
var td = OS.get_datetime() # time dictionary
var timestamp = String(td.year) + "_" + String(td.month) + "_" + String(td.day) + "_" + String(td.hour) + "_" + String(td.minute) + "_" + String(td.second)
var now := OS.get_ticks_msec()


# Called when the node enters the scene tree for the first time.
func _ready():
	#constant positions
	head_y = head_radius
	righthead.translation.y = head_y
	lefthead.translation.y = head_y
	head_x = 0
	head_z = 0
	
	#set starting direction
	starting_angles.shuffle()
	head_yaw_angle = starting_angles[current_trial-1]
	if head_yaw_angle==0:
		print("rep 1: texture")
	else:
		print("rep 1: cliff")
	
	#input setup
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#calculate fps
	now = OS.get_ticks_msec()
	times.append(now)
	while times.size() > 0 and times[0] <= now - 1000:
		times.pop_front() # Remove frames older than 1 second in the `times` array
	fps = times.size()

	#calculate head position
	#head_yaw_angle += mouse_gain*yaw_gain*head_yaw
	head_z += mouse_gain*(thrust_gain*head_thrust*cos(deg2rad(head_yaw_angle)) + slip_gain*head_slip*sin(deg2rad(head_yaw_angle)))
	#head_x += (-mouse_gain*thrust_gain*head_thrust*sin(deg2rad(head_yaw_angle))) + (mouse_gain*slip_gain*head_slip*cos(deg2rad(head_yaw_angle)))
	
	#translate head position
	righthead.translation.z = head_z
	righthead.translation.x = head_x
	lefthead.translation.z = head_z
	lefthead.translation.x = head_x
	
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
	
	#save data
	current_frame += 1
	yawLog.append(head_yaw)
	pitchLog.append(head_thrust)
	rollLog.append(head_slip)
	zLog.append(head_z)
	angLog.append(head_yaw_angle)
	timeLog.append(now)
		
	#update text label
#	fpslabel.text = str(fps) + " FPS" # Display FPS in the label
#	fpslabel.text = str(current_frame-reached_cliff_frame)
	fpslabel.text = ""
	
	#reset movements
	head_thrust = 0
	head_slip = 0
	head_yaw = 0
	
	#next trial
	current_frame += 1
	if (current_frame/frames_per_second)>=trial_duration || abs(head_z)>max_z:
		save_logs(current_rep,yawLog,pitchLog,rollLog,zLog,angLog,timeLog)
		yawLog = [] 
		pitchLog = [] 
		rollLog = [] 
		zLog = [] 
		angLog = []
		timeLog = [] 
		current_trial += 1
		current_frame = 1
		if (current_trial>num_directions):
			current_trial = 1
			current_rep += 1
			starting_angles.shuffle()
		if (current_rep>num_reps):
			get_tree().quit() 
		else: 
			head_yaw_angle = starting_angles[current_trial-1]
			head_z = 0
			if head_yaw_angle==1:
				print("rep " + str(current_rep) + ": texture")
			else:
				print("rep " + str(current_rep) + ": cliff")



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
		


func save_logs(current_rep,col1,col2,col3,col4,col5,col6):
	var file = File.new()
	if (file.open("res://logs//" + timestamp + "_" + scene_name + "_rep" + String(current_rep) + "_godotlogs.txt", File.WRITE)== OK):
		for i in range(col1.size()):
			file.store_line(String(col1[i]) + "," + String(col2[i]) + "," + String(col3[i]) + "," + String(col4[i]) + "," + String(col5[i]) + "," + String(col6[i]) + "\r")
		file.close()

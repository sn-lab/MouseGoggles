extends Spatial

#cliff constants
export var scene_name = "visualcliff"
export var num_reps = 5
export var max_time_after_cliff = 10
export var max_dist_after_cliff = 0.5

#cliff variables
export var reached_cliff_frame = 0
export var start_next_trial = 0

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
export var frames_per_second = 60
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
export var trial_duration = 30
export var current_rep = 1
export var times := [] # Timestamps of frames rendered in the last second
export var fps := 0 # Frames per second
export var statecolor = Color(0, 0, 0)
export var current_frame = 0
var now := OS.get_ticks_msec()
var yawLog := [] 
var pitchLog := [] 
var rollLog := [] 
var xLog := [] 
var zLog := [] 
var angLog := []
var timeLog := [] 
var timestamp = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	#constant positions
	head_y = head_radius
	righthead.translation.y = head_y
	lefthead.translation.y = head_y
	
	#set starting head angle
	head_yaw_angle = randf()*20 + 170
	print("starting angle " + String(head_yaw_angle))
	
	#get current time
	var td = OS.get_datetime() # time dictionary
	timestamp = String(td.year) + "_" + String(td.month) + "_" + String(td.day) + "_" + String(td.hour) + "_" + String(td.minute) + "_" + String(td.second)
#	timestamp = Time.get_time_string_from_system() # OS.get_datetime deprecated in Godot 4?

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

	#calculate head position
	head_yaw_angle += mouse_gain*yaw_gain*head_yaw
	head_z += (mouse_gain*thrust_gain*head_thrust*cos(deg2rad(head_yaw_angle))) + (mouse_gain*slip_gain*head_slip*sin(deg2rad(head_yaw_angle)))
	head_x += (-mouse_gain*thrust_gain*head_thrust*sin(deg2rad(head_yaw_angle))) + (mouse_gain*slip_gain*head_slip*cos(deg2rad(head_yaw_angle)))
	
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
	xLog.append(head_x)
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
	if (reached_cliff_frame==0) && ((abs(head_x)>=0.45) || (abs(head_z)>=0.45)):
		reached_cliff_frame = current_frame
#	if (reached_cliff_frame==0) && (current_frame > trial_duration*frames_per_second):
#		start_next_trial = 1
	if (abs(head_x)>=(0.5+max_dist_after_cliff)) || (abs(head_z)>=(0.5+max_dist_after_cliff)):
		start_next_trial = 1
	if (reached_cliff_frame > 0) && ((current_frame-reached_cliff_frame)>=(max_time_after_cliff*frames_per_second)):
		start_next_trial = 1
		reached_cliff_frame = 0
		
	if start_next_trial==1:
		current_frame = 1
		current_rep += 1
		reached_cliff_frame = 0
		if (current_rep>num_reps):
			save_logs(yawLog,pitchLog,rollLog,xLog,zLog,angLog,timeLog)
			get_tree().quit() 
		else:
			head_yaw_angle = randf()*20 + 170
			head_x = 0
			head_z = 0
			print("starting angle " + String(head_yaw_angle))
	start_next_trial = 0
	
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
			
	#for testing arduino xinput
	if ev is InputEventJoypadButton and ev.is_pressed():
		print(ev.get_button_index()," ",Input.get_joy_button_string(ev.get_button_index()))
		

func save_logs(col1,col2,col3,col4,col5,col6,col7):
	var file = File.new()
	if (file.open("res://logs//" + timestamp + "_" + scene_name + "_godotlogs.txt", File.WRITE)== OK):
		for i in range(col1.size()):
			file.store_line(String(col1[i]) + "," + String(col2[i]) + "," + String(col3[i]) + "," + String(col4[i]) + "," + String(col5[i]) + "," + String(col6[i]) + "," + String(col7[i]) + "\r")
		file.close()

func average_difference(numbers: Array) -> float:
	var diff := 0.0
	for i in range(numbers.size()-1):
		diff += numbers[i+1] - numbers[i]
	return diff/(numbers.size()-1)

extends Spatial

#linear track constants
export var track_length = 1.0
export var track_width = 0.1
export var scene_duration = 10
export var scene_name = "lineartrackA"
export var reward_loc = 0.15
export var reward_loc_range = 0.05
export var num_reps = 5

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

#serial communication library (not working on Raspberry Pi)
#const SERCOMM = preload("res://addons/GDSerCommDock/bin/GDSerComm.gdns")
#onready var PORT = SERCOMM.new()
#onready var com=$Com
#var port = "COM7"
#var baud = 115200
#var inBytes = PoolByteArray()
#var x1 = 0
#var y1 = 0
#var x2 = 0
#var y2 = 0
#var sq1 = 0
#var sq2 = 0

#logging/saving stuff
export var trial_duration = 10
export var current_rep = 1
export var rewarded = 0
export var reward_out = 0
export var rewarded_frame = 0
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
var timeLog := [] 
var timestamp = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	#head positions
	head_y = head_radius
	head_yaw_angle = 180
	head_x = 0
	head_z = -0.46
	rewarded = 0
	rewarded_frame = 0
	print("rep " + String(current_rep))
	
	#get current time
	var td = OS.get_datetime() # time dictionary
	timestamp = String(td.year) + "_" + String(td.month) + "_" + String(td.day) + "_" + String(td.hour) + "_" + String(td.minute) + "_" + String(td.second)
#	timestamp = Time.get_time_string_from_system() # OS.get_datetime deprecated in Godot 4?

	#set up serial connection
#	set_physics_process(false)
#	PORT.close()
#	PORT.open(port,baud,1000,com.bytesz.SER_BYTESZ_8, com.parity.SER_PAR_NONE, com.stopbyte.SER_STOPB_ONE)
#	PORT.flush()
#	set_physics_process(true)
	#inBytes = [0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0]
	
	#input setup
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
#	#request new serial data for current frame
#	send_text("h")
	
	#calculate fps (method 1)
#	var now := OS.get_ticks_msec()
#	times.append(now)
#	while times.size() > 0 and times[0] <= now - 1000:
#		times.pop_front() # Remove frames older than 1 second in the `times` array
#	fps = times.size()
	
	#calculate fps (method 2)
	var now := OS.get_ticks_msec()
	times.append(now)
	while times.size() > 0 and times[0] <= now - 1000:
		times.pop_front() # Remove frames older than 1 second in the `times` array
	if times.size()>1:
		fps = 1000/average_difference(times)
	
	#get available serial data
	#### TO-DO: currently, this will use the first available set of bytes, if there 
	####  are multiple sets of bytes; switch to using the last set of bytes
#	if PORT != null && PORT.get_available()>23:
#		inBytes = []
#		for _i in range(PORT.get_available()):
#			inBytes.append(PORT.read(1))
#		x1 = array_to_int(inBytes.slice(0,3))
#		y1 = array_to_int(inBytes.slice(4,7))
#		x2 = array_to_int(inBytes.slice(8,11))
#		y2 = array_to_int(inBytes.slice(12,15))
#		sq1 = array_to_int(inBytes.slice(16,19))
#		sq2 = array_to_int(inBytes.slice(20,23))
#
#		#recalculate yaw, thrust, slip
#		head_yaw += yaw_gain*((-x1-x2)/2)
#		head_thrust = thrust_gain*y2
#		head_slip = thrust_gain*y1
	
	#calculate head position
	head_yaw_angle += mouse_gain*yaw_gain*head_yaw
	head_z += (mouse_gain*thrust_gain*head_thrust*cos(deg2rad(head_yaw_angle))) + (mouse_gain*slip_gain*head_slip*sin(deg2rad(head_yaw_angle)))
	head_x += (-mouse_gain*thrust_gain*head_thrust*sin(deg2rad(head_yaw_angle))) + (mouse_gain*slip_gain*head_slip*cos(deg2rad(head_yaw_angle)))
	
	#keep left body inside of linear track
	if head_z>((track_length/2)-head_radius):
		head_z = (track_length/2)-head_radius
	if head_z<(-(track_length/2)+head_radius):
		head_z = -(track_length/2)+head_radius
	if head_x>((track_width/2)-head_radius):
		head_x = (track_width/2)-head_radius
	if head_x<(-(track_width/2)+head_radius):
		head_x = -(track_width/2)+head_radius
		
	#translate head position
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
	if (abs(head_z-reward_loc)<=reward_loc_range) && rewarded==0:
		colorrect.color = Color(1, 1, 1)
		rewarded = 1
		reward_out = 1
		rewarded_frame = current_frame
	else: 
		if (rewarded_frame == 0) || ((current_frame-rewarded_frame)>=frames_per_second):
			reward_out = 0
			colorrect.color = Color(0, 0, 0)
				
	#request new serial data for next frame
	#send_text("h")
	
	#save data
	current_frame += 1
	yawLog.append(head_yaw)
	pitchLog.append(head_thrust)
	rollLog.append(head_slip)
	xLog.append(head_x)
	zLog.append(head_z)
	angLog.append(head_yaw_angle)
	rewardLog.append(reward_out)
	timeLog.append(now)
		
	#update text label
#	fpslabel.text = str(fps) + " FPS" # Display FPS in the label
#	fpslabel.text = str(head_yaw_angle) + "yaw" 
#	fpslabel.text = str((current_frame-rewarded_frame)) + " t"
	fpslabel.text = ""
	
	#reset movements
	head_thrust = 0
	head_slip = 0
	head_yaw = 0
	
	#next trial
	if (current_frame > trial_duration*frames_per_second):
		current_frame = 1
		current_rep += 1
		if (current_rep>num_reps):
			save_logs(yawLog,pitchLog,rollLog,xLog,zLog,angLog,rewardLog,timeLog)
			get_tree().quit() 
		else:
			head_yaw_angle = 180
			head_x = 0
			head_z = -0.46
			rewarded = 0
			rewarded_frame = 0
			print("rep " + String(current_rep))

	
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
		

#func send_text(var outVal):
#	PORT.write(outVal) #write function, please use only ascii

#func array_to_int(ByteArray):
#	var OutInt = ByteArray[0]*1 + ByteArray[1]*256 + ByteArray[2]*65536 + ByteArray[3]*16777216
#	return OutInt
	
func save_logs(col1,col2,col3,col4,col5,col6,col7,col8):
	var file = File.new()
	if (file.open("res://logs//" + timestamp + "_" + scene_name + "_godotlogs.txt", File.WRITE)== OK):
		for i in range(col1.size()):
			file.store_line(String(col1[i]) + "," + String(col2[i]) + "," + String(col3[i]) + "," + String(col4[i]) + "," + String(col5[i]) + "," + String(col6[i]) + "," + String(col7[i]) + "," + String(col8[i]) + "\r")
		file.close()

func average_difference(numbers: Array) -> float:
	var diff := 0.0
	for i in range(numbers.size()-1):
		diff += numbers[i+1] - numbers[i]
	return diff/(numbers.size()-1)

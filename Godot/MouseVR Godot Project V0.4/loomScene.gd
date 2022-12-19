extends Spatial

#loom constants
export var velocities = [12.5, 25.0, 50.0] 
export var loom_yaw_angle = 45
export var loom_pitch_angle = 60
export var loom_start_distance = 20
export var loom_stop_distance = 0.5774
export var scene_name = "loom"
export var trial_duration = 10
export var predelay = 4
export var num_trials = 6
export var num_reps = 5

#loom variables
export var loom_speed = 0 #meters per second
export var loom_step = 0
export var loom_cur_distance = 0
export var lv_direction = 0
export var cur_velocity = 0
export var cur_lv_trial = 0
export var xpos = 0
export var floor_zpos = 0
export var obj_y_ang = 0
export var xscale = 0
export var yscale = 0
export var zscale = 0
export var start_predelay = 0

#loom nodes
onready var object = get_node("object")
onready var floorobj = get_node("floor")

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
export var thrust_gain = 1 #meters per step
export var slip_gain = 1 #meters per step
export var yaw_gain = 1 #degrees per step
export var mouse_gain = 0.05

#head/eye position variables
export var head_yaw = 0 #degrees; 0 points along -z; 90 points to +x
export var head_thrust = 0 #+ points to -z
export var head_slip = 0 #+ points to +x
export var head_yaw_angle = 0
export var right_eye_angle = 0
export var left_eye_angle = 0
export var eye_yaw_angle = 0
export var LeftEyeDirection = Vector3.ZERO #direction the left eye is pointing
export var RightEyeDirection = Vector3.ZERO #

#logging/saving stuff
export var current_trial = 0
export var current_rep = 1
export var trial_order := [0,1,2,3,4,5]
export var times := [] # Timestamps of frames rendered in the last second
export var fps := 0 # Frames per second
export var statecolor = Color(0, 0, 0)
export var current_frame = 0
var yawLog := [] 
var pitchLog := [] 
var rollLog := [] 
var velLog := [] 
var xposLog := [] 
var timeLog := [] 
var timestamp = ""

# Called when the node enters the scene tree for the first time.
func _ready():	
	#get current time
	var td = OS.get_datetime() # time dictionary
	timestamp = String(td.year) + "_" + String(td.month) + "_" + String(td.day) + "_" + String(td.hour) + "_" + String(td.minute) + "_" + String(td.second)
	
	#get starting loom
	randomize()
	trial_order.shuffle()
	if ((trial_order[current_trial])>=(num_trials/2)):
		cur_lv_trial = trial_order[current_trial] - (num_trials/2)
		lv_direction = -1
	else:
		cur_lv_trial = trial_order[current_trial]
		lv_direction = 1
	obj_y_ang = lv_direction*loom_yaw_angle
	cur_velocity = velocities[cur_lv_trial]
	loom_cur_distance = loom_start_distance
	loom_step = cur_velocity/frames_per_second
	xscale = cos(deg2rad(loom_pitch_angle))*sin((loom_yaw_angle))
	yscale = sin(deg2rad(loom_pitch_angle))
	zscale = cos(deg2rad(loom_pitch_angle))*cos(deg2rad(loom_yaw_angle))
	floor_zpos = 75
	print("vel " + String(cur_velocity) + ", direction " + String(lv_direction))
	
	#set eye rotations
	lefteye.rotation_degrees.y = 180+eye_yaw
	lefteye.rotation_degrees.x = eye_pitch
	righteye.rotation_degrees.y = 180-eye_yaw
	righteye.rotation_degrees.x = eye_pitch
	
	#object rotations
	object.rotation_degrees.y = obj_y_ang
	object.rotation_degrees.x = loom_pitch_angle
	
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
#	fpslabel.text = str(fps) + " FPS" 
	if object.translation.z == -10:
		fpslabel.text = ""
	else:
		fpslabel.text = str(round(loom_cur_distance*10)/10)
	
	#update trial
	current_frame += 1
	if (current_frame<(predelay*frames_per_second)) || (loom_cur_distance <= loom_stop_distance):
		cur_velocity = 0
		xpos = 0
		object.translation.z = -10
		object.translation.x = 0
		object.translation.y = 0
	else:
		loom_cur_distance -= loom_step
		if (loom_cur_distance <= loom_stop_distance):
			loom_cur_distance = loom_stop_distance
		xpos = lv_direction*loom_cur_distance*xscale
		object.translation.z = loom_cur_distance*zscale
		object.translation.x = xpos
		object.translation.y = loom_cur_distance*yscale
	
	#move floor to simulate forward-walking in place
	floor_zpos += mouse_gain*thrust_gain*head_thrust
	if (floor_zpos<-25):
		floor_zpos += 100
	floorobj.translation.z = floor_zpos
	
	#save data
	yawLog.append(head_yaw)
	pitchLog.append(head_thrust)
	rollLog.append(head_slip)
	velLog.append(lv_direction*cur_velocity)
	xposLog.append(xpos)
	timeLog.append(now)
	
	#reset movements
	head_thrust = 0
	head_slip = 0
	head_yaw = 0
	
	#next trial
	if (current_frame > trial_duration*frames_per_second):
		current_frame = 1
		current_trial += 1
		if (current_trial==num_trials):
			save_logs(current_rep,yawLog,pitchLog,rollLog,velLog,xposLog,timeLog)
			yawLog = [] 
			pitchLog = [] 
			rollLog = [] 
			velLog = []
			xposLog = []
			timeLog = [] 
			current_trial = 0
			current_rep += 1
			if (current_rep > num_reps):
				get_tree().quit() 
			trial_order.shuffle()
		if ((trial_order[current_trial])>=(num_trials/2)):
			cur_lv_trial = trial_order[current_trial] - (num_trials/2)
			lv_direction = -1
		else:
			cur_lv_trial = trial_order[current_trial]
			lv_direction = 1
		if (current_rep <= num_reps):
			obj_y_ang = lv_direction*loom_yaw_angle
			cur_velocity = velocities[cur_lv_trial]
			loom_cur_distance = loom_start_distance
			loom_step = cur_velocity/frames_per_second
			object.rotation_degrees.y = obj_y_ang
			print("vel " + String(cur_velocity) + ", direction " + String(lv_direction))

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

func save_logs(current_rep,col1,col2,col3,col4,col5,col6):
	var file = File.new()
	if (file.open("res://logs//" + timestamp + "_" + scene_name + "_rep" + String(current_rep) + "_godotlogs.txt", File.WRITE)== OK):
		for i in range(col1.size()):
			file.store_line(String(col1[i]) + "," + String(col2[i]) + "," + String(col3[i]) + "," + String(col4[i]) + "," + String(col5[i]) + "," + String(col6[i]) + "\r")
		file.close()

func average_difference(numbers: Array) -> float:
	var diff := 0.0
	for i in range(numbers.size()-1):
		diff += numbers[i+1] - numbers[i]
	return diff/(numbers.size()-1)


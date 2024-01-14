extends Spatial

#loom parameters
export var velocity = 25
export var loom_yaw_angle = 45
export var loom_pitch_angle = 45
export var loom_start_distance = 20
export var loom_stop_distance = 0.5774
export var scene_name = "loom"
export var predelay = 5
export var postdelay = 5 #duration after loom starts before starting a new trial
export var num_trials = 3
export var num_reps = 3
export var force_first_trial = false
export var forced_first_trial_order := [0, 3, 1, 2] #[moveL, 1=darkL, 2=moveR, 3=darkR]
export var max_movement_before_loom = 100.0 #maximum average movement value before a loom will start
export var min_movement_before_loom = -10.0 #minimum "" 
export var movement_duration_before_loom = 1 #seconds the mouse has to walk slowly before a loom will start

#eye parameters
export var inter_eye_distance = 0.01
export var head_radius = 0.04 #must be large enough to keep eye cameras from getting too close to walls
export var eye_pitch = 10 #degrees from the horizontal
export var eye_yaw = 50 #degrees away from the head yaw

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
var start_predelay = 0
var movement_samples := []
var movement_avg = 0
var movement_total = 0
var movement_current = 0
var loom_started = false
var loom_ongoing = false
var after_loom_frames = 0

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

#logging/saving stuff
var current_trial = 0
var trial_type = 0
var current_rep = 1
var current_condition = 0
var lick_in = 0
var trial_order := [0,1,2]
var times := [] # Timestamps of frames rendered in the last second
var fps := 0 # Frames per second
var statecolor = Color(0, 0, 0)
var current_frame = 0
var dataNames = ['head_yaw', 'head_thrust', 'head_slip', 'current_condition', 'loom_cur_distance', 'ms_now']
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
	
	#get starting loom
	randomize()
	if force_first_trial:
		trial_order = forced_first_trial_order
	else:
		trial_order.shuffle()
	print("rep " + str(current_rep) + ", trial order: " + str(trial_order))
	current_condition = trial_order[current_trial]
	if (current_condition==0):
		direction = 0
	if (current_condition==1):
		direction = 1
	if (current_condition==2):
		direction = -1
	obj_y_ang = direction*loom_yaw_angle
	loom_cur_distance = loom_start_distance
	loom_step = velocity/frames_per_second
	
	xscale = cos(deg2rad(loom_pitch_angle))*sin((loom_yaw_angle))
	yscale = sin(deg2rad(loom_pitch_angle))
	zscale = cos(deg2rad(loom_pitch_angle))*cos(deg2rad(loom_yaw_angle))
	head_z = 0.0
	print("trial " + str(current_condition) + ": type " + str(trial_type) + ", direction " + str(direction))
	
	#rotate eyes relative to body
	lefteye.rotation_degrees.y = -head_yaw_angle+eye_yaw
	lefteye.rotation_degrees.x = eye_pitch
	righteye.rotation_degrees.y = -head_yaw_angle-eye_yaw
	righteye.rotation_degrees.x = eye_pitch
	
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
		
	#calculate current movement
	movement_current = mouse_gain*(abs(head_thrust) + abs(head_slip) + deg2rad(abs(head_yaw)))
	movement_total += movement_current
	movement_samples.append(movement_current)
	while movement_samples.size() > (fps*movement_duration_before_loom):
		movement_total -= movement_samples[0]
		movement_samples.pop_front() # Remove oldest samples
	movement_avg = 100*(movement_total/movement_samples.size())
	
	#move mouse to simulate forward-walking
	head_z += mouse_gain*(thrust_gain*head_thrust*cos(deg2rad(head_yaw_angle)) + slip_gain*head_slip*sin(deg2rad(head_yaw_angle)))
	if (head_z>0.025):
		head_z -= 0.05
	if (head_z<-0.025):
		head_z += 0.05
		
	#translate head position
	righthead.translation.z = head_z
	lefthead.translation.z = head_z
	
	#translate eyes relative to body
	lefteye.translation.z = head_z - inter_eye_distance*sin(deg2rad(head_yaw_angle))
	righteye.translation.z = head_z + inter_eye_distance*sin(deg2rad(head_yaw_angle))
	
	#determine whether to start a new loom
	if loom_started==false: #if it hasn't already started
		if (current_frame>=(predelay*frames_per_second)):
			if (movement_avg<=max_movement_before_loom) && (movement_avg>=min_movement_before_loom):
				loom_started = true
				loom_ongoing = true
	else:
		after_loom_frames += 1
	
	#update loom
	if loom_started && loom_ongoing:
		#update object position (real loom trials)
		
		if object_zpos<head_z:
			loom_cur_distance = loom_start_distance + loom_step
			
		if  (loom_cur_distance <= loom_stop_distance):
			object_xpos = 0
			object_ypos = 0
			object_zpos = head_z - 10
			loom_ongoing = false
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
	dataArray = [head_yaw, head_thrust, head_slip, current_condition, loom_cur_distance, ms_now]
	for i in range(dataArray.size()):
		dataLog.append(dataArray[i])
	
	#update text label
#	fpslabel.text = str(fps) + " FPS" 
#	fpslabel.text = str(round(loom_cur_distance*10)/10) + "dist" 
	fpslabel.text = str(round((movement_avg+0.001)*100)/100) + " mvmnt"
	if (movement_avg<=max_movement_before_loom):
		fpslabel.modulate = Color(0,1,0,1)
	else:
		fpslabel.modulate = Color(1,0,0,1)
#	fpslabel.text = ""

	#reset movements
	head_thrust = 0
	head_slip = 0
	head_yaw = 0
	
	#next trial
	if (loom_started && after_loom_frames > (postdelay*frames_per_second)):
		loom_started = false
		current_frame = 1
		after_loom_frames = 0
		current_trial += 1
		if (current_trial==num_trials):
			save_logs(current_rep,dataLog,dataNames) #save current logged data to a new file
			dataLog = [] #clear saved data
			current_trial = 0
			current_rep += 1
			if (current_rep > num_reps):
				get_tree().quit() 
			trial_order.shuffle()
			print("rep " + str(current_rep) + ", trial order: " + str(trial_order))
		current_condition = trial_order[current_trial]
		if (current_condition==0):
			direction = 0
		if (current_condition==1):
			direction = 1
		if (current_condition==2):
			direction = -1
		if (current_rep <= num_reps):
			obj_y_ang = direction*loom_yaw_angle
			loom_cur_distance = loom_start_distance
			object.rotation_degrees.y = obj_y_ang
			print("trial " + str(current_condition) + ": type " + str(trial_type) + ", direction " + str(direction))


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

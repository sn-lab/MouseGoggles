#get common settings
extends "res://commonSettings.gd"

#habituation parameters
export var scene_name = "movement3D"
export var trial_duration = 300
export var reward_dur = 0.05 #seconds to open the reward valve

#head/eye position variables
export var head_yaw = 0 #degrees; 0 points along -z; 90 points to +x
export var head_pitch = 0
export var head_roll = 0
export var head_ori_x = 0 
export var head_ori_y = 0
export var head_ori_z = 0
var head_lift = 0 #+ points to +y
var head_thrust = 0 #+ points to -z
var head_slip = 0 #+ points to +x
var head_x = 0
var head_z = 0
var head_y = 0

#logging/saving stuff
var lick_in = 0
var reward_out = 0
var statecolor = Color(0, 0, 0)
var current_frame = 0
var dataNames = ['head_yaw', 'head_thrust', 'head_slip', 'reward_out', 'lick_in', 'ms_now']


# Called when the node enters the scene tree for the first time.
func _ready():	
	experimentName =  timestamp + "_" + scene_name
	
	#constant positions
	head_y = head_radius
	righthead.translation.y = head_y
	lefthead.translation.y = head_y
	head_x = 0
	
	#rotate eyes relative to body
	lefteye.rotation_degrees.x = head_pitch+eye_pitch
	lefteye.rotation_degrees.y = -head_yaw+eye_yaw
	lefteye.rotation_degrees.z = head_roll+head_roll
	righteye.rotation_degrees.x = head_pitch+eye_pitch
	righteye.rotation_degrees.y = -head_yaw-eye_yaw
	righteye.rotation_degrees.z = -head_roll+head_roll
	
	#translate head position
	righthead.translation.x = head_x
	righthead.translation.y = head_y
	righthead.translation.z = head_z
	lefthead.translation.x = head_x
	lefthead.translation.y = head_y
	lefthead.translation.z = head_z
	
	#translate eyes relative to body
	lefteye.translation.x = head_x - (0.5*inter_eye_distance*cos(deg2rad(head_yaw))*cos(deg2rad(head_roll)))
	lefteye.translation.y = head_y - (0.5*inter_eye_distance*sin(deg2rad(head_roll)))
	lefteye.translation.z = head_z - (0.5*inter_eye_distance*sin(deg2rad(head_yaw))*cos(deg2rad(head_roll)))
	righteye.translation.x = head_x + (0.5*inter_eye_distance*cos(deg2rad(head_yaw))*cos(deg2rad(head_roll)))
	righteye.translation.y = head_y + (0.5*inter_eye_distance*sin(deg2rad(head_roll)))
	righteye.translation.z = head_z + (0.5*inter_eye_distance*sin(deg2rad(head_yaw))*cos(deg2rad(head_roll)))
	
	
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
	
	#translate mouse position
	#lefthead.translate(Vector3(slip_gain*mouse_gain*head_slip,lift_gain*mouse_gain*head_lift,thrust_gain*mouse_gain*head_thrust))
	#righthead.translate(Vector3(slip_gain*mouse_gain*head_slip,lift_gain*mouse_gain*head_lift,thrust_gain*mouse_gain*head_thrust))
	
	#rotate body based on orientation
	lefthead.rotate_object_local(Vector3(0,1,0),mouse_gain*head_thrust)
	righthead.rotate_object_local(Vector3(0,1,0),mouse_gain*head_thrust)
	
	#log data
	dataArray = [head_yaw, head_thrust, head_slip, reward_out, lick_in, ms_now]
	for i in range(dataArray.size()):
		dataLog.append(dataArray[i])
	
	#update text label
#	fpslabel.text = str(fps) + " FPS"
	#fpslabel.text = "R=reward"
	
	#reset movements
	head_thrust = 0
	head_slip = 0
	#head_yaw = 0 mouse x movement can now set absolute yaw angle, not relative yaw change
	reward_out = 0
	
	#end scene
	if (current_frame%int(60*frames_per_second))==0:
		print(str(round(current_frame/(60*frames_per_second))) + " min elapsed")
	if (current_frame > trial_duration*frames_per_second):
		saveUtils.save_logs(1,dataLog,dataNames,experimentName) #save current logged data to a new file
		dataLog = [] #clear saved data
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene("res://sceneSelect.tscn")

func _input(ev):
	if ev is InputEventKey and ev.is_pressed():
		if ev.scancode == KEY_ESCAPE:
			saveUtils.save_logs(1,dataLog,dataNames,experimentName) #save current logged data to a new file
			dataLog = [] #clear saved data
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().change_scene("res://sceneSelect.tscn")
		if ev.scancode == KEY_R:
			reward_out = 1
			Input.start_joy_vibration(0,1,1,reward_dur) #for using xinput rumble output
			colorrect.color = Color(1, 1, 1)
			yield(get_tree().create_timer(reward_dur), "timeout")
			colorrect.color = Color(0, 0, 0)
			
	if ev is InputEventMouseMotion:
		head_roll = 2*ev.relative.x #rotation sensor sends angle in 2-deg increments
		#head_yaw = 2*ev.relative.x #rotation sensor sends angle in 2-deg increments
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
		

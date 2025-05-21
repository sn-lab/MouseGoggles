#get common settings
extends "res://commonSettings.gd"

#habituation parameters
export var scene_name = "rotation"
export var trial_duration = 300
export var reward_dur = 0.05 #seconds to open the reward valve

#head/eye position variables
export var head_yaw = 0 #degrees; 0 points along -z; 90 points to +x
export var head_pitch = 0
export var head_roll = 0
export var head_yaw_angle = 0 #degrees; 0 points along -z; 90 points to +x
export var head_roll_angle = 0 #degrees; 0 points along -z; 90 points to +x
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
	righteye.translation.y = head_y# + (0.5*inter_eye_distance*sin(deg2rad(head_roll)))
	righteye.translation.z = head_z + (0.5*inter_eye_distance*sin(deg2rad(head_yaw))*cos(deg2rad(head_roll)))
	
	#start experiment
	var experimentDuration = trial_duration
	start_experiment(experimentName, experimentDuration)


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
	lefthead.translation.z = head_z
	
	#rotate eyes relative to body
	lefteye.rotation_degrees.x = eye_pitch
	lefteye.rotation_degrees.y = -head_yaw_angle+eye_yaw
	lefteye.rotation_degrees.z = head_roll_angle+head_roll-90
	righteye.rotation_degrees.x = eye_pitch
	righteye.rotation_degrees.y = -head_yaw_angle-eye_yaw
	righteye.rotation_degrees.z = -head_roll_angle+head_roll-90
	
	#translate eyes relative to body
	head_yaw_angle = head_yaw
	lefteye.translation.z = head_z - inter_eye_distance*sin(deg2rad(head_yaw_angle))
	righteye.translation.z = head_z + inter_eye_distance*sin(deg2rad(head_yaw_angle))
	
	#translate eyes relative to body
	lefteye.translation.x = head_x - (0.5*inter_eye_distance*cos(deg2rad(head_yaw_angle))*cos(deg2rad(head_roll_angle)))
	lefteye.translation.y = head_y - (0.5*inter_eye_distance*sin(deg2rad(head_roll_angle)))
	lefteye.translation.z = head_z - (0.5*inter_eye_distance*sin(deg2rad(head_yaw_angle))*cos(deg2rad(head_roll_angle)))
	righteye.translation.x = head_x + (0.5*inter_eye_distance*cos(deg2rad(head_yaw_angle))*cos(deg2rad(head_roll_angle)))
	righteye.translation.y = head_y + (0.5*inter_eye_distance*sin(deg2rad(head_roll_angle)))
	righteye.translation.z = head_z + (0.5*inter_eye_distance*sin(deg2rad(head_yaw_angle))*cos(deg2rad(head_roll_angle)))
	
	
	#log data
	dataArray = [head_yaw, head_thrust, head_slip, reward_out, lick_in, ms_now]
	for i in range(dataArray.size()):
		dataLog.append(dataArray[i])
	
	#update text label
#	fpslabel.text = str(fps) + " FPS" 
	fpslabel.text = str(head_roll_angle)
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
		stop_experiment(experimentName)


func _input(ev):
	if ev is InputEventKey and ev.is_pressed():
		if ev.scancode == KEY_ESCAPE:
			saveUtils.save_logs(1,dataLog,dataNames,experimentName) #save current logged data to a new file
			dataLog = [] #clear saved data
			stop_experiment(experimentName)
		
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
		

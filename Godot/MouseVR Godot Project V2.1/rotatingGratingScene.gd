#get common settings
extends "res://commonSettings.gd"

#optomotor parameters
export var temporal_frequency = 2.0 #grating cycles per second
export var spatial_wavelength = 24 #degrees per grating cycle
export var scene_name = "rotatingGratings"
export var intertrial_duration = 7.5 #duration before (and between) trials (no motion)
export var grating_duration_1 = 2.0 #duration of grating rotation
export var intergrating_duration = 0.5 #duration of grating rotation
export var grating_duration_2 = 2.0 #duration of grating rotation
export var stim_duration = 0.25 #duration of stimulus (occuring at tail end of grating) (1 s max)
export var camera_trigger_duration = 0.5 #duration of trigger signal to start/stop external eye camera recording
export var exp_phase = 1

#training protocol parameters
export var num_reps_1 = 32
export var trial_angles_1 = [0, 45] #angle change rotational speeds for each trial (day 1)
export var num_reps_2 = 8
export var trial_angles_2 = [0, 0, 0, 0, 5, 10, 22.5, 45] #angle change rotational speeds for each trial (days 2+)

#optomotor variables
var rotation_speed_y = temporal_frequency*spatial_wavelength #degrees per second in y
var rotation_angle_y = 0
var rotation_angle_x = 0 #degrees
var current_trial = 0
var time_elapsed = 0.0
var rotation_phase = 0

#viewport nodes
onready var rotatinggrating = get_node("RotatingGrating")

#head/eye position variables
var head_yaw = 0 #degrees; 0 points along -z; 90 points to +x
var head_thrust = 0 #+ points to -z
var head_slip = 0 #+ points to +x
var head_x = 0
var head_z = 0
var head_y = 0
var head_yaw_angle = 0
var right_eye_angle = 0
var left_eye_angle = 0
var eye_yaw_angle = 0
var stim_out = 0
var LeftEyeDirection = Vector3.ZERO #direction the left eye is pointing
var RightEyeDirection = Vector3.ZERO #
var walking_y = 5
var grating_y = 0
var grey_y = -5

#logging/saving stuff
var trial_angles = [0, 0, 0, 0, 0, 0, 0, 0]
var num_reps = []
var current_angle = 0
var current_rep = 1
var num_trials = 0
var statecolor = Color(0, 0, 0)
var dataNames = ['head_yaw', 'head_thrust', 'head_slip', 'current_trial', 'rotation_phase', 'stim_out', 'ms_now']


# Called when the node enters the scene tree for the first time.
func _ready():    
	experimentName =  timestamp + "_" + scene_name
	
	#set new eye positions
	inter_eye_distance = 0 #put eyes together in the center
	eye_pitch = 10 #degrees from the horizontal
	eye_yaw = 0 #degrees away from the head yaw

	if exp_phase == 1:
		trial_angles = trial_angles_1
		num_reps = num_reps_1
	if exp_phase == 2:
		trial_angles = trial_angles_2
		num_reps = num_reps_2
	num_trials = trial_angles.size()
	trial_angles.shuffle()
	
	#set mouse position to free walking area
	head_y = walking_y + head_radius
	head_x = 0
	head_z = 0
	head_yaw_angle = 180
	#rotate eyes relative to body
	lefteye.rotation_degrees.y = -head_yaw_angle+eye_yaw
	lefteye.rotation_degrees.x = eye_pitch
	righteye.rotation_degrees.y = -head_yaw_angle-eye_yaw
	righteye.rotation_degrees.x = eye_pitch
	#translate head position
	righthead.translation.x = head_x
	righthead.translation.y = head_y
	righthead.translation.z = head_z
	lefthead.translation.x = head_x
	lefthead.translation.y = head_y
	lefthead.translation.z = head_z
	#translate eyes relative to body
	lefteye.translation.z = head_z - inter_eye_distance*sin(deg2rad(head_yaw_angle))
	lefteye.translation.x = head_x - inter_eye_distance*cos(deg2rad(head_yaw_angle))
	righteye.translation.z = head_z + inter_eye_distance*sin(deg2rad(head_yaw_angle))
	righteye.translation.x = head_x + inter_eye_distance*cos(deg2rad(head_yaw_angle))
	
	#start experiment
	var experimentDuration = num_reps*num_trials*(intertrial_duration + grating_duration_1 + intergrating_duration + grating_duration_2)
	start_experiment(experimentName, experimentDuration)
	print("trial order " + str(trial_angles))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#calculate fps
	ms_now = OS.get_ticks_msec() - ms_start
	times.append(ms_now)
	while times.size() > 0 and times[0] <= ms_now - 1000:
		times.pop_front() # Remove frames older than 1 second in the `times` array
	fps = times.size()
	time_elapsed += delta
	
	#log data
	current_angle = trial_angles[current_trial]
	dataArray = [head_yaw, head_thrust, head_slip, current_angle, rotation_phase, stim_out, ms_now]
	for i in range(dataArray.size()):
		dataLog.append(dataArray[i])
	
	#update text label
	fpslabel.text = str(stim_out)
#	fpslabel.text = ""
	
	#control experiment
	if rotation_phase == 0: #intertrial (free walking)
		###control free walking
		#move mouse to simulate forward-walking
		head_z += mouse_gain*(thrust_gain*head_thrust*cos(deg2rad(head_yaw_angle)) + slip_gain*head_slip*sin(deg2rad(head_yaw_angle)))
		if (head_z>0.025):
			head_z -= 0.05
		if (head_z<-0.025):
			head_z += 0.05
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
		
		# Check for time to switch to next phase
		if time_elapsed >= (intertrial_duration/2.0):
			#set mouse position to inside cylinder
			head_y = grating_y
			head_x = 0
			head_z = 0
			head_yaw_angle = 180
			#rotate eyes relative to body
			lefteye.rotation_degrees.y = -head_yaw_angle+eye_yaw
			lefteye.rotation_degrees.x = 0
			righteye.rotation_degrees.y = -head_yaw_angle-eye_yaw
			righteye.rotation_degrees.x = 0
			#translate head position
			righthead.translation.x = head_x
			righthead.translation.y = head_y
			righthead.translation.z = head_z
			lefthead.translation.x = head_x
			lefthead.translation.y = head_y
			lefthead.translation.z = head_z
			#translate eyes relative to body
			lefteye.translation.z = head_z - inter_eye_distance*sin(deg2rad(head_yaw_angle))
			lefteye.translation.x = head_x - inter_eye_distance*cos(deg2rad(head_yaw_angle))
			righteye.translation.z = head_z + inter_eye_distance*sin(deg2rad(head_yaw_angle))
			righteye.translation.x = head_x + inter_eye_distance*cos(deg2rad(head_yaw_angle))
			
			#set cylinder orientation
			rotatinggrating.rotation_degrees.z = 0
			rotatinggrating.rotation_degrees.x = 0
			rotatinggrating.rotation_degrees.y = 0
			
			#increment
			time_elapsed = 0
			rotation_phase += 1
			
	elif rotation_phase == 1: #horizontal grating rotation
		#rotate cylinder
		rotation_angle_y = delta*rotation_speed_y
		rotatinggrating.rotate_object_local(Vector3(0,1,0), rotation_angle_y*3.14/180)
		
		# Check for time to switch to next phase
		if time_elapsed >= grating_duration_1:
			#set mouse position to grey area
			head_y = grey_y
			head_x = 0
			head_z = 0
			head_yaw_angle = 180
			#translate head position
			righthead.translation.x = head_x
			righthead.translation.y = head_y
			righthead.translation.z = head_z
			lefthead.translation.x = head_x
			lefthead.translation.y = head_y
			lefthead.translation.z = head_z
			#translate eyes relative to body
			lefteye.translation.z = head_z - inter_eye_distance*sin(deg2rad(head_yaw_angle))
			lefteye.translation.x = head_x - inter_eye_distance*cos(deg2rad(head_yaw_angle))
			righteye.translation.z = head_z + inter_eye_distance*sin(deg2rad(head_yaw_angle))
			righteye.translation.x = head_x + inter_eye_distance*cos(deg2rad(head_yaw_angle))
			
			#increment
			time_elapsed = 0
			rotation_phase += 1
			
	elif rotation_phase == 2: #grey image
		# Check for time to switch to next phase
		if time_elapsed >= intergrating_duration:
			#set mouse position to grating area
			head_y = grating_y
			head_x = 0
			head_z = 0
			head_yaw_angle = 180
			#translate head position
			righthead.translation.x = head_x
			righthead.translation.y = head_y
			righthead.translation.z = head_z
			lefthead.translation.x = head_x
			lefthead.translation.y = head_y
			lefthead.translation.z = head_z
			#translate eyes relative to body
			lefteye.translation.z = head_z - inter_eye_distance*sin(deg2rad(head_yaw_angle))
			lefteye.translation.x = head_x - inter_eye_distance*cos(deg2rad(head_yaw_angle))
			righteye.translation.z = head_z + inter_eye_distance*sin(deg2rad(head_yaw_angle))
			righteye.translation.x = head_x + inter_eye_distance*cos(deg2rad(head_yaw_angle))
			
			#set cylinder orientation
			rotatinggrating.rotation_degrees.z = current_angle
			rotatinggrating.rotation_degrees.x = 0
			rotatinggrating.rotation_degrees.y = 0
			
			#increment
			time_elapsed = 0
			rotation_phase += 1
			
			
	elif rotation_phase == 3: #[horizontal or angled] grating rotation
		#rotate cylinder
		#rotatinggrating.rotation_degrees.z = current_angle
		rotation_angle_y = delta*rotation_speed_y
		rotatinggrating.rotate_object_local(Vector3(0,1,0), rotation_angle_y*3.14/180)
		
		#check for time to send stimulus
		if time_elapsed >= grating_duration_2-stim_duration:
			if current_angle > 0:
				Input.start_joy_vibration(0,stim_duration,0,0.1) #weak/right rumble
				colorrect.color = Color(1, 1, 1)
				stim_out = 1
			
		# Check for time to switch to next phase
		if time_elapsed >= grating_duration_2:
			colorrect.color = Color(0, 0, 0)
			stim_out = 0
				
			#set mouse position to free walking area
			head_y = walking_y + head_radius
			head_x = 0
			head_z = 0
			head_yaw_angle = 180
			#rotate eyes relative to body
			lefteye.rotation_degrees.y = -head_yaw_angle+eye_yaw
			lefteye.rotation_degrees.x = eye_pitch
			righteye.rotation_degrees.y = -head_yaw_angle-eye_yaw
			righteye.rotation_degrees.x = eye_pitch
			#translate head position
			righthead.translation.x = head_x
			righthead.translation.y = head_y
			righthead.translation.z = head_z
			lefthead.translation.x = head_x
			lefthead.translation.y = head_y
			lefthead.translation.z = head_z
			#translate eyes relative to body
			lefteye.translation.z = head_z - inter_eye_distance*sin(deg2rad(head_yaw_angle))
			lefteye.translation.x = head_x - inter_eye_distance*cos(deg2rad(head_yaw_angle))
			righteye.translation.z = head_z + inter_eye_distance*sin(deg2rad(head_yaw_angle))
			righteye.translation.x = head_x + inter_eye_distance*cos(deg2rad(head_yaw_angle))
			
			#increment
			time_elapsed = 0
			rotation_phase += 1
			
	
	elif rotation_phase == 4: #back to free walking
		###control free walking
		#move mouse to simulate forward-walking
		head_z += mouse_gain*(thrust_gain*head_thrust*cos(deg2rad(head_yaw_angle)) + slip_gain*head_slip*sin(deg2rad(head_yaw_angle)))
		if (head_z>0.025):
			head_z -= 0.05
		if (head_z<-0.025):
			head_z += 0.05
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
		
		# Check for time to switch to next trial
		if time_elapsed >= (intertrial_duration/2.0):
			time_elapsed = 0
			rotation_phase = 0
			rotation_angle_y = 0
			rotation_angle_x = 0
			rotatinggrating.rotation_degrees.x = 0
			rotatinggrating.rotation_degrees.y = 0
			rotatinggrating.rotation_degrees.z = 0
			current_trial += 1
			# Check for time to switch to next rep
			if (current_trial==num_trials):
				saveUtils.save_logs(current_rep,dataLog,dataNames,experimentName) #save current logged data to a new file
				dataLog = [] #clear saved data
				current_trial = 0
				current_rep += 1
				if (current_rep > num_reps):
					stop_experiment(experimentName)
				else:
					trial_angles.shuffle()
					print("trial order " + str(trial_angles))
	
	#reset movements
	head_thrust = 0
	head_slip = 0
	head_yaw = 0


func _input(ev):
	if ev is InputEventKey and ev.is_pressed():
		if ev.scancode == KEY_ESCAPE:
			saveUtils.save_logs(current_rep,dataLog,dataNames,experimentName) #save current logged data to a new file
			dataLog = [] #clear saved data
			stop_experiment(experimentName)


	if ev is InputEventMouseMotion:
		head_yaw += ev.relative.x
		head_thrust += ev.relative.y


	if ev is InputEventMouseButton:
		if ev.is_pressed():
			if ev.button_index == BUTTON_WHEEL_UP:
				head_slip += 1
			if ev.button_index == BUTTON_WHEEL_DOWN:
				head_slip -= 1


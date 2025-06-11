#get common settings
extends "res://commonSettings.gd"

#receptive field mapping parameters
export var scene_name = "receptivefield"
export var spot_azimuth = 20.0 #size of stimulus spot (degrees azimuth)
export var spot_elevation = 20.0 #size of stimulus spot (degrees elavation)
export var predelay = 2
export var stim_duration = 2
export var postdelay = 2
export var eye_inds =             [  1,   1,   1,   1,   1,   1,   2,   2,   2,   2,   2,   2] # 1=left, 2=right, 3=both
export var eye_azimuths =         [  0, -20, -40, -60, -80,-100,   0,  20,  40,  60,  80, 100] # spot location in degrees azimuth (+ = towards right eye)
export var eye_elevations =       [  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0] # splot location in degrees elevation (+ = up)
export var rotation_angles =      [  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0] # angle of drift in degrees from rightward (+ = CW)
export var spatial_wavelengths =  [ 12,  12,  12,  12,  12,  12,  12,  12,  12,  12,  12,  12] # grating spatial wavelength; current options are [24, 12, 8, 6, 4, 2, 1]
export var temporal_frequencies = [  2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2] # grating temporal frequency in Hz/cycles per second
export var num_trials = 12 # number of spots
export var num_reps = 3

#headkinbody viewport nodes
onready var lefthead = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/TextureRect/Viewport/LeftEyeBody")
onready var righthead = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/TextureRect/Viewport/RightEyeBody")
onready var lefteye = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/TextureRect/Viewport/LeftEyeBody/LeftEyePivot")
onready var righteye = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/TextureRect/Viewport/RightEyeBody/RightEyePivot")
onready var colorrect = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/ColorRect")
onready var fpslabel = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/Label")
onready var overlay = get_node("HeadKinBody/Control/Overlay")

#cylinder nodes
onready var cyl1 = get_node("CylinderKinBody1")
onready var mesh1 = get_node("CylinderKinBody1/MeshInstance1")

#spot boundary nodes
onready var topmesh = get_node("TopMeshInstance")
onready var botmesh = get_node("BottomMeshInstance")
onready var rightmesh = get_node("RightMeshInstance")
onready var leftmesh = get_node("LeftMeshInstance")

#preload textures
var grating1 = preload("res://textures/Grating 1 deg spatial wavelength.png")
var grating2 = preload("res://textures/Grating 2 deg spatial wavelength.png")
var grating4 = preload("res://textures/Grating 4 deg spatial wavelength.png")
var grating6 = preload("res://textures/Grating 6 deg spatial wavelength.png")
var grating8 = preload("res://textures/Grating 8 deg spatial wavelength.png")
var grating12 = preload("res://textures/Grating 12 deg spatial wavelength.png")
var grating24 = preload("res://textures/Grating 24 deg spatial wavelength.png")

#experiment variables
var speed = 0
var angle = 0
var state = 1
var wavelength = 0
var frequency = 0
var eye = 0
var azimuth = 0
var elevation = 0
var cylinder_angle = 0

#head/eye position variables
var head_yaw = 0 #degrees; 0 points along -z; 90 points to +x
var head_thrust = 0 #+ points to -z
var head_slip = 0 #+ points to +x
var head_yaw_angle = 0
var right_eye_angle = 0
var left_eye_angle = 0
var eye_yaw_angle = 0
var LeftEyeDirection = Vector3.ZERO #direction the left eye is pointing
var RightEyeDirection = Vector3.ZERO #

#logging/saving stuff
var current_trial = 0
var current_rep = 0
var lick_in = 0
var trial_order := []
var current_frame = 0
var dataNames = ['head_yaw', 'head_thrust', 'head_slip', 'wavelength', 'frequency', 'angle', 'eye', 'azimuth', 'elevation', 'state', 'ms_now']


# Called when the node enters the scene tree for the first time.
func _ready():	
	experimentName =  timestamp + "_" + scene_name
	
	# set new eye positions
	eye_pitch = 0 #degrees from the horizontal
	
	# set spot size nodes
	topmesh.translation.y = tan(deg2rad(spot_elevation)/2)
	botmesh.translation.y = -tan(deg2rad(spot_elevation)/2)
	rightmesh.translation.x = sin(deg2rad(spot_azimuth)/2)
	leftmesh.translation.x = -sin(deg2rad(spot_azimuth)/2)
	
	#create array of trials
	for i in range(num_trials):
		trial_order.append(i)
	
	#start experiment
	var experimentDuration = num_reps*num_trials*(predelay+stim_duration+postdelay)
	overlay.color = Color(0, 0, 0, 1-brightness_modulate) #modulate brightness with black overlay transparency 
	start_experiment(experimentDuration)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#calculate fps
	ms_now = OS.get_ticks_msec() - ms_start
	times.append(ms_now)
	while times.size() > 0 and times[0] <= ms_now - 1000:
		times.pop_front() # Remove frames older than 1 second in the `times` array
	fps = times.size()
	current_frame += 1
	
	#log data
	dataArray = [head_yaw, head_thrust, head_slip, wavelength, frequency, angle, eye, azimuth, elevation, state, ms_now]
	for i in range(dataArray.size()):
		dataLog.append(dataArray[i])
	
	#state 1 (starting a new repetition)
	if state==1:
		current_rep += 1
		if (current_rep > num_reps):
			stop_experiment()
			yield(get_tree().create_timer(1.0), "timeout")
		trial_order.shuffle()
		print("trial order " + str(trial_order))
		#immediately move to next state
		state = 2
	
	
	#state 2 (starting a new trial)
	if state==2:
		lefteye.translation.z = -3
		righteye.translation.z = -3
		current_trial += 1
		if current_trial<=num_trials: #start the next trial
			cylinder_angle = 0
			if udp_connected:
				pulse_output(2, 0.1) #send 0.1-s TTL pulse on Raspberry Pi 5 GPIO2 pin (only GPIO2 and GPIO3 are enabled)
			#move to next state
			state = 3
		else: #start the next rep
			current_trial = 0
			state = 1 # start new rep
			saveUtils.save_logs(current_rep,dataLog,dataNames,experimentName) #save current logged data to a new file
			dataLog = [] #clear saved data
	
	
	#state 3 (predelay)
	if state==3:
		#move to next state once predelay duration has finished
		if current_frame>=(predelay*frames_per_second):
			#get current rotation speed (deg/sec)
			speed = spatial_wavelengths[trial_order[current_trial-1]]*temporal_frequencies[trial_order[current_trial-1]]
			
			#get current spatial wavelength to set current cylinder mesh
			var material1 = SpatialMaterial.new()
			material1.params_cull_mode = SpatialMaterial.CULL_FRONT  # Front culling
			material1.flags_unshaded = true  # Unshaded flag
			mesh1.set_surface_material(0, material1)
			if spatial_wavelengths[trial_order[current_trial-1]]==1:
				material1.albedo_texture = grating1
			if spatial_wavelengths[trial_order[current_trial-1]]==2:
				material1.albedo_texture = grating2
			if spatial_wavelengths[trial_order[current_trial-1]]==4:
				material1.albedo_texture = grating4
			if spatial_wavelengths[trial_order[current_trial-1]]==6:
				material1.albedo_texture = grating6
			if spatial_wavelengths[trial_order[current_trial-1]]==8:
				material1.albedo_texture = grating8
			if spatial_wavelengths[trial_order[current_trial-1]]==12:
				material1.albedo_texture = grating12
			if spatial_wavelengths[trial_order[current_trial-1]]==24:
				material1.albedo_texture = grating24
			
			#set current z-pos and angle of each eye
			if (eye_inds[trial_order[current_trial-1]]==1 || eye_inds[trial_order[current_trial-1]]==3):
				lefteye.translation.z = 0
				lefteye.rotate_object_local(Vector3(1,0,0), (-eye_elevations[trial_order[current_trial-1]])*3.14/180)
				lefteye.rotate_object_local(Vector3(0,1,0), (-eye_yaw - eye_azimuths[trial_order[current_trial-1]])*3.14/180)
				
			if (eye_inds[trial_order[current_trial-1]]==2 || eye_inds[trial_order[current_trial-1]]==3):
				righteye.translation.z = 0
				righteye.rotate_object_local(Vector3(1,0,0), (-eye_elevations[trial_order[current_trial-1]])*3.14/180)
				righteye.rotate_object_local(Vector3(0,1,0), (eye_yaw - eye_azimuths[trial_order[current_trial-1]])*3.14/180)
			
			#rotate cylinders according to direction angle
			#currentmesh.rotate_object_local(Vector3(0,0,1), rotation_angles[trial_order[current_trial-1]]*3.14/180)
			cyl1.rotation_degrees.z = rotation_angles[trial_order[current_trial-1]]
			
			#move to next state
			state = 4
	
	
	#state 4 (stimulus)
	if state==4:
		cylinder_angle = delta*speed
		cyl1.rotate_object_local(Vector3(0,1,0), cylinder_angle*3.14/180)
		
		#move to next state once stimulus duration has finished
		if current_frame>=((predelay+stim_duration)*frames_per_second):
			lefteye.translation.z = -3
			righteye.translation.z = -3
			cyl1.rotation_degrees.z = 0
			cyl1.rotation_degrees.x = 0
			cyl1.rotation_degrees.y = 0
			lefteye.rotation_degrees.z = 0
			lefteye.rotation_degrees.x = 0
			lefteye.rotation_degrees.y = 0
			righteye.rotation_degrees.z = 0
			righteye.rotation_degrees.x = 0
			righteye.rotation_degrees.y = 0
			cylinder_angle = 0;
			state = 5
	
	
	#state 5 (postdelay)
	if state==5:
		#move to next state (new trial) once predelay duration has finished
		if current_frame>=((predelay+stim_duration+postdelay)*frames_per_second):
			current_frame = 0
			state = 2
	
	
	#update text label
	#fpslabel.text = str(eye_azimuths[trial_order[current_trial-1]])
	#fpslabel.text = str(lefteye.translation.z)
	fpslabel.text = str(fps) + " FPS"
	
	#reset movements
	head_thrust = 0
	head_slip = 0
	head_yaw = 0


func _input(ev):
	if ev is InputEventKey and ev.is_pressed():
		if ev.scancode == KEY_ESCAPE:
			saveUtils.save_logs(current_rep,dataLog,dataNames,experimentName) #save current logged data to a new file
			dataLog = [] #clear saved data
			stop_experiment()
	
	if ev is InputEventMouseMotion:
		head_yaw += ev.relative.x
		head_thrust += ev.relative.y
	
	if ev is InputEventMouseButton:
		if ev.is_pressed():
			if ev.button_index == BUTTON_WHEEL_UP:
				head_slip += 1
			if ev.button_index == BUTTON_WHEEL_DOWN:
				head_slip -= 1

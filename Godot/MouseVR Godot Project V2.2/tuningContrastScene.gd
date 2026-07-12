#get common settings
extends "res://commonSettings.gd"

#=========================== TUNING PROTOCOL OPTIONS ===========================
export var use_open_field_intertrial = true #true = closed-loop open-field walking area between trials; false = static grey frame between trials
export var contrast_levels = [100, 75, 50, 25, 12.5, 0] #percent contrast to test each trial (100 = full-contrast grating, 0 = fully grey/blank)
export var randomize_order = true #true = shuffle contrast_levels into a new random order each repetition; false = present in the listed order every time
export var num_reps = 10 #number of times to repeat the full contrast_levels set
#=================================================================================

#optomotor parameters
export var temporal_frequency = 2.0 #grating cycles per second
export var spatial_wavelength = 24 #degrees per grating cycle
export var scene_name = "tuningContrast"
export var intertrial_duration = 7.5 #duration before (and between) trials (no motion), split evenly before/after the grating
export var grating_duration = 2.0 #duration of the (single) grating presentation per trial
export var output_trigger_duration = 2.0 #duration of stimulus marker (occurring at tail end of grating) (1 s max)
export var camera_trigger_duration = 0.5 #duration of trigger signal to start/stop external eye camera recording

#headkinbody viewport nodes
onready var lefthead = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/TextureRect/Viewport/LeftEyeBody")
onready var righthead = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/TextureRect/Viewport/RightEyeBody")
onready var lefteye = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/TextureRect/Viewport/LeftEyeBody/LeftEyePivot")
onready var righteye = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/TextureRect/Viewport/RightEyeBody/RightEyePivot")
onready var colorrect = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/ColorRect")
onready var fpslabel = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/Label")
onready var overlay = get_node("HeadKinBody/Control/Overlay")

#stimulus nodes
onready var rotatinggrating = get_node("RotatingGrating")
onready var contrastoverlay = get_node("ContrastOverlay") #thin grey cylinder just inside the grating; its opacity sets contrast

#contrast overlay material - built once, alpha (opacity) updated per trial. alpha=0 -> 100% contrast (grating fully visible), alpha=1 -> 0% contrast (fully grey)
var contrast_material = SpatialMaterial.new()

#optomotor variables
var rotation_speed_y = temporal_frequency*spatial_wavelength #degrees per second in y
var rotation_angle_y = 0
var current_trial = 0
var time_elapsed = 0.0
var trial_phase = 0 #0 = intertrial (pre), 1 = grating presentation, 2 = intertrial (post)

#head/eye position variables
var head_yaw = 0 #degrees; 0 points along -z; 90 points to +x
var head_thrust = 0 #+ points to -z
var head_slip = 0 #+ points to +x
var head_x = 0
var head_z = 0
var head_y = 0
var head_yaw_angle = 0
var stim_out = 0
var walking_y = 5
var grating_y = 0
var grey_y = -5

#logging/saving stuff
var trial_values = [] #working (possibly shuffled) copy of contrast_levels, rebuilt each rep
var current_contrast = 0
var current_rep = 1
var num_trials = 0
var dataNames = ['head_yaw', 'head_thrust', 'head_slip', 'current_trial', 'current_contrast', 'trial_phase', 'stim_out', 'ms_now']


# Called when the node enters the scene tree for the first time.
func _ready():
	experimentName = timestamp + "_" + scene_name

	#set new eye positions
	inter_eye_distance = 0 #put eyes together in the center
	eye_pitch = 10 #degrees from the horizontal
	eye_yaw = 0 #degrees away from the head yaw

	#set up the contrast overlay material (grey, variable opacity)
	contrast_material.flags_transparent = true
	contrast_material.params_cull_mode = SpatialMaterial.CULL_FRONT #match the grating cylinder; camera is inside looking at the inner surface
	contrast_material.albedo_color = Color(0.5, 0.5, 0.5, 0.0) #start fully transparent (100% contrast)
	contrastoverlay.material_override = contrast_material

	trial_values = contrast_levels.duplicate()
	num_trials = trial_values.size()
	if randomize_order:
		trial_values.shuffle()

	#set mouse position to the intertrial condition (open field or grey room)
	if use_open_field_intertrial:
		position_head(walking_y + head_radius, 0, 0, 180, eye_pitch)
	else:
		position_head(grey_y, 0, 0, 180, 0)

	#start experiment
	var experimentDuration = num_reps*num_trials*(intertrial_duration + grating_duration)
	overlay.color = Color(0, 0, 0, 1-brightness_modulate) #modulate brightness with black overlay transparency
	start_experiment(experimentDuration)
	print("trial order " + str(trial_values))


#moves/orients the head+eyes; consolidates the repeated head/eye placement code used throughout _process
func position_head(y, x, z, yaw, pitch):
	head_y = y
	head_x = x
	head_z = z
	head_yaw_angle = yaw
	#rotate eyes relative to body
	lefteye.rotation_degrees.y = -head_yaw_angle+eye_yaw
	lefteye.rotation_degrees.x = pitch
	righteye.rotation_degrees.y = -head_yaw_angle-eye_yaw
	righteye.rotation_degrees.x = pitch
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


#simulates closed-loop forward walking in the open-field area
func simulate_walking():
	head_z += mouse_gain*(thrust_gain*head_thrust*cos(deg2rad(head_yaw_angle)) + slip_gain*head_slip*sin(deg2rad(head_yaw_angle)))
	if (head_z>0.025):
		head_z -= 0.05
	if (head_z<-0.025):
		head_z += 0.05
	position_head(head_y, head_x, head_z, head_yaw_angle, eye_pitch)


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
	current_contrast = trial_values[current_trial]
	dataArray = [head_yaw, head_thrust, head_slip, current_trial, current_contrast, trial_phase, stim_out, ms_now]
	for i in range(dataArray.size()):
		dataLog.append(dataArray[i])

	#update text label
	fpslabel.text = str(stim_out)

	#control experiment
	if trial_phase == 0: #intertrial, before grating (free walking or static grey frame)
		if use_open_field_intertrial:
			simulate_walking()

		# Check for time to switch to grating presentation
		if time_elapsed >= (intertrial_duration/2.0):
			#move to the grating room
			position_head(grating_y, 0, 0, 180, 0)

			#set cylinder orientation and this trial's contrast
			rotatinggrating.rotation_degrees.z = 0
			rotatinggrating.rotation_degrees.x = 0
			rotatinggrating.rotation_degrees.y = 0
			contrast_material.albedo_color.a = 1.0 - (current_contrast/100.0)

			#increment
			time_elapsed = 0
			trial_phase += 1

	elif trial_phase == 1: #grating presentation (single presentation at this trial's contrast)
		#rotate cylinder
		rotation_angle_y = delta*rotation_speed_y
		rotatinggrating.rotate_object_local(Vector3(0,1,0), rotation_angle_y*3.14/180)

		#check for time to send stimulus marker
		if time_elapsed >= grating_duration-output_trigger_duration:
			Input.start_joy_vibration(0,output_trigger_duration,0,0.1) #weak/right rumble
			colorrect.color = Color(1, 1, 1)
			stim_out = 1

		# Check for time to switch to post-grating intertrial
		if time_elapsed >= grating_duration:
			colorrect.color = Color(0, 0, 0)
			stim_out = 0

			#return to the intertrial condition
			if use_open_field_intertrial:
				position_head(walking_y + head_radius, 0, 0, 180, eye_pitch)
			else:
				position_head(grey_y, 0, 0, 180, 0)

			#increment
			time_elapsed = 0
			trial_phase += 1

	elif trial_phase == 2: #intertrial, after grating (free walking or static grey frame)
		if use_open_field_intertrial:
			simulate_walking()

		# Check for time to switch to next trial
		if time_elapsed >= (intertrial_duration/2.0):
			time_elapsed = 0
			trial_phase = 0
			rotation_angle_y = 0
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
					stop_experiment()
				else:
					trial_values = contrast_levels.duplicate()
					if randomize_order:
						trial_values.shuffle()
					print("trial order " + str(trial_values))

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

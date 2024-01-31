extends Control

#movement parameters
export var frames_per_second = 60.0
export var thrust_gain = -0.01 #meters per step
export var slip_gain = 0.01 #meters per step
export var yaw_gain = 5 #degrees per step
export var mouse_gain = 0.0135
export var reward_dur = 0.05 #seconds to open the reward valve

#viewport nodes
onready var colorrect = get_node("ColorRect")
onready var valuelabel = get_node("Label2")
onready var displaylabel = get_node("Label")

#logging/saving stuff
var reward_out = 0
var lick_in = 0
var times := [] # Timestamps of frames rendered in the last second
var fps := 0 # Frames per second
var current_frame = 0
var td = OS.get_datetime() # time dictionary
var timestamp = String(td.year) + "_" + String(td.month) + "_" + String(td.day) + "_" + String(td.hour) + "_" + String(td.minute) + "_" + String(td.second)
var now := OS.get_ticks_msec()
var labeloption = 1
var head_yaw = 0
var head_thrust = 0
var head_slip = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	#input setup
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	colorrect.color = Color(0, 0, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#calculate fps (method 2)
	var now := OS.get_ticks_msec()
	times.append(now)
	while times.size() > 0 and times[0] <= now - 1000:
		times.pop_front() # Remove frames older than 1 second in the `times` array
	fps = times.size()
	
	#calculate input values
	if labeloption==1:
		valuelabel.text = str(lick_in)
		displaylabel.text = "[I,Y,T,S,F]\nInput"
	if labeloption==2:
		valuelabel.text = str(head_yaw)
		displaylabel.text = "[I,Y,T,S,F]\nYaw"
	if labeloption==3:
		valuelabel.text = str(head_thrust)
		displaylabel.text = "[I,Y,T,S,F]\nThrust"
	if labeloption==4:
		valuelabel.text = str(head_slip)
		displaylabel.text = "[I,Y,T,S,F]\nSlip"
	if labeloption==5:	
		valuelabel.text = str(fps)
		displaylabel.text = "[I,Y,T,S,F]\nFPS"
	
	current_frame += 1
	
	head_yaw = 0
	head_thrust = 0
	head_slip = 0

func _input(ev):
	if ev is InputEventKey and ev.is_pressed():
		if ev.scancode == KEY_ESCAPE:
			get_tree().quit() 
		if ev.scancode == KEY_R:
			Input.start_joy_vibration(0,1,1,reward_dur) #for using xinput rumble output
			colorrect.color = Color(1, 1, 1)
			yield(get_tree().create_timer(reward_dur), "timeout")
			colorrect.color = Color(0, 0, 0)
		if ev.scancode == KEY_I:
			labeloption = 1
		if ev.scancode == KEY_Y:
			labeloption = 2
		if ev.scancode == KEY_T:
			labeloption = 3
		if ev.scancode == KEY_S:
			labeloption = 4
		if ev.scancode == KEY_F:
			labeloption = 5
	
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
		

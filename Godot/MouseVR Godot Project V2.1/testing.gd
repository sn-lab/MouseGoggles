extends Control

#testing parameters
export var reward_dur = 0.05 #seconds to open the reward valve

#viewport nodes
onready var valuelabel = get_node("Label2")
onready var displaylabel = get_node("Label")
onready var colorrect = get_node("ColorRect")

#logging/saving stuff
var reward_out = 0
var lick_in = 0
var current_frame = 0
var td = OS.get_datetime() # time dictionary
var timestamp = String(td.year) + "_" + String(td.month) + "_" + String(td.day) + "_" + String(td.hour) + "_" + String(td.minute) + "_" + String(td.second)
var now := OS.get_ticks_msec()
var labeloption = 1
var head_yaw = 0
var head_thrust = 0
var head_slip = 0
var times := [] # Timestamps of frames rendered in the last second
var fps := 0 # Frames per second

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
		valuelabel.text = str(lick_in) + " input value"
		displaylabel.text = "test options: [I,Y,T,S,F]\ncurrent selection: Input (I)"
	if labeloption==2:
		valuelabel.text = str(head_yaw) + " yaw value"
		displaylabel.text = "test options: [I,Y,T,S,F]\ncurrent selection: Yaw (Y)"
	if labeloption==3:
		valuelabel.text = str(head_thrust) + " thrust value"
		displaylabel.text = "test options: [I,Y,T,S,F]\ncurrent selection: Thrust (T)"
	if labeloption==4:
		valuelabel.text = str(head_slip) + " slip value"
		displaylabel.text = "test options: [I,Y,T,S,F]\ncurrent selection: Slip (S)"
	if labeloption==5:	
		valuelabel.text = str(fps) + " frames/sec"
		displaylabel.text = "test options: [I,Y,T,S,F]\ncurrent selection: FPS (F)"
	
	current_frame += 1
	
	head_yaw = 0
	head_thrust = 0
	head_slip = 0

func _input(ev):
	if ev is InputEventKey and ev.is_pressed():
		if ev.scancode == KEY_ESCAPE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().change_scene("res://sceneSelect.tscn")
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
		

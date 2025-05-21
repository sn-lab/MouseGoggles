#get common settings
extends "res://commonSettings.gd"

#testing parameters
export var output_dur = 1.0 #seconds to send an output signal

#viewport nodes
onready var valuelabel = get_node("Label2")
onready var displaylabel = get_node("Label")
onready var outputrect = get_node("ColorRect")

#logging/saving stuff
var input_val = 0
var current_frame = 0
var now := OS.get_ticks_msec()
var labeloption = 1
var head_yaw = 0
var head_thrust = 0
var head_slip = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	#input setup
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	outputrect.color = Color(0, 0, 0)
	
	# check UDP/TCP communication
	verify_connection()

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
		valuelabel.text = str(input_val) + " input value"
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
		if ev.scancode == KEY_O:
			Input.start_joy_vibration(0,1,1,output_dur) #for using xinput rumble output
			if udp_connected:
				pulse_output(2, output_dur/2) #send 1-s TTL pulse on Raspberry Pi 5 GPIO2 pin (only GPIO2 and GPIO3 are enabled)
				pulse_output(3, output_dur/2) #send 1-s TTL pulse on Raspberry Pi 5 GPIO2 pin (only GPIO2 and GPIO3 are enabled)
			outputrect.color = Color(1, 1, 1)
			yield(get_tree().create_timer(output_dur), "timeout")
			outputrect.color = Color(0, 0, 0)
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
			input_val = round(1000*ev.get_axis_value());
		
		else:
			print("Unexpected button pressed: ",ev.get_button_index(),", ",Input.get_joy_button_string(ev.get_button_index()))
		

#Common settings and functions used across many scripts

extends Node

#eye parameters
export var inter_eye_distance = 0.01 # all distances/sizes are roughly in meters
export var head_radius = 0.04 # must be large enough to keep eye cameras from getting too close to walls
export var eye_pitch = 10 # degrees from the horizontal (+ = looking up)
export var eye_yaw = 45 # degrees away from the head yaw (forward-facing = 0 deg, side-facing = 90)
export var brightness_modulate = 0.5 # global brightness modulation (0 = black, 1 = max)
export var record_eyes = false #(true or false) record eye-tracking video alongside the experiment?

#movement parameters
export var frames_per_second = 60.0 # should be the same as the project settings>debug>settings>force FPS
export var thrust_gain = -0.02 # meters per step
export var lift_gain = -0.01 # meters per step
export var slip_gain = 0.01 # meters per step
export var yaw_gain = 5 # degrees per step
export var mouse_gain = 0.0135 # global sensitivity scaling 

#common variables
var times := [] # timestamps of frames rendered in the last second
var fps := 0 # frames per second
var dataArray := [] # empty array to store the current frame data
var dataLog := [] # empty array to store data for all frames of the current experiment reptition
var experimentName = "_" # variable to hold experiment name (timestamp + scene name)
var ms_start := OS.get_ticks_msec() # time of scene start
var ms_now := OS.get_ticks_msec() # current time
var python_time = 0 # timestamp of python script relative to Godot ms_start
var td = OS.get_datetime() # time dictionary
var timestamp = String(td.year) + "_" + String(td.month) + "_" + String(td.day) + "_" + String(td.hour) + "_" + String(td.minute) + "_" + String(td.second)

#UDP communication
var udp_connected = false #(true or false) whether upd-python script is connected and responsive
var destination_ip = "127.0.0.1"  # local
var destination_port = 5001
var listen_port = 5000
const handshake_timeout := 3.0 # seconds
var udp := PacketPeerUDP.new()
var video_data := PoolByteArray()
var current_file := File.new()
var current_filename := ""


#common functions

func position_window():
	#position game window in screen center
	#OS.set_window_size(Vector2(720,480))
	#var screen_size = OS.get_screen_size()
	#var window_size = OS.get_window_size()
	#var centered_pos = (screen_size-window_size)/2
	
	#create fullscreen game window
	#get_tree().root.content_scale_size = Vector2i(720,480)
	#get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	#get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	
	#position game window on top-left corner
	var centered_pos = Vector2(0,0)
	
	OS.set_window_position(centered_pos)
	OS.set_window_resizable(false)


func start_experiment(experimentDuration):
	print(experimentName)
	print("experiment started")
	print("Est. max completion time: " + str(experimentDuration) + "s")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #capture cursor movement for game movement
	randomize() #prepare for random presentations of trials
	if record_eyes:
		#UDP handshake
		assert(udp.listen(listen_port) == OK, "UDP listen failed")
		verify_connection()
		start_video(experimentDuration + 10) #record full experiment + 10 s in case "stop_video is not sent
		yield(get_tree().create_timer(1.0), "timeout")


func stop_experiment():
	print(experimentName)
	print("experiment complete")
	if record_eyes:
		stop_video()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) #return visible cursor movement to user
	var _error = get_tree().change_scene("res://sceneSelect.tscn")


#UDP functions
#list of UDP commands:
#H: handshake (send "H", start timestamp; receive "H" back)
#F: request frame (send "F", cam #; receive "F" and frame back)
#V: start videos (send "V", filename, and duration; receive "V" back)
#X: stop videos (send "X")

func verify_connection():
	send_command("H", [str(ms_start)])
	var start_time = Time.get_ticks_msec()
	while Time.get_ticks_msec() - start_time < handshake_timeout * 1000:
		if udp.get_available_packet_count() > 0:
			var packet = udp.get_packet()
			if packet.get_string_from_utf8() == "H":
				udp_connected = true
				print("UDP-Python script is running and responsive")
				return
			if packet.get_string_from_utf8() == "E":
				udp_connected = true
				print("UDP-Python script is running and responsive")
				print("Warning: less than 5 GB of space available on Pi 5. Clear disk space (empty the 'Cam' folder on the Pi 5 desktop) to avoid data loss")
				return
		OS.delay_msec(100) # Wait 100ms between checks
	print("Failed to verify UDP connection")
	OS.delay_msec(1000)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var _error = get_tree().change_scene("res://sceneSelect.tscn")


func send_command(command: String, params: Array = []):
	var message = command
	if params.size() > 0:
		message += ":" + PoolStringArray(params).join(":")
	var _error = udp.set_dest_address(destination_ip, destination_port)
	_error = udp.put_packet(message.to_utf8())


func receive_message(command: String):
	while udp.get_available_packet_count() > 0:
		var packet = udp.get_packet()
		if char(packet[0])==command:
			return packet
		else:
			print("command '" + command + "' not received")


func pulse_output(pin: int, pulse_duration: float):
	send_command("O",[str(pin), str(pulse_duration)]) #send TTL pulse output


func request_frames():
	send_command("F") #request frames


func start_video(max_duration: float):
	send_command("V", [experimentName, str(max_duration)])
	receive_message("V")


func stop_video():
	send_command("X")


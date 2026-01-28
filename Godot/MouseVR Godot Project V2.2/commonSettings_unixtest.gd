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

#Unix socket communication
var socket_connected = false #(true or false) whether socket-python script is connected and responsive
var socket_path = "/tmp/godot_python_socket"
const handshake_timeout := 3.0 # seconds
var socket := StreamPeerUnix.new()
var video_data := PoolByteArray()
var current_file := File.new()
var current_filename := ""

#common functions
func start_experiment(experimentDuration):
	print(experimentName)
	print("experiment started")
	print("Est. max completion time: " + str(experimentDuration) + "s")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #capture cursor movement for game movement
	randomize() #prepare for random presentations of trials
	if record_eyes:
		#Unix socket handshake
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


#Unix socket functions
#list of socket commands:
#H: handshake (send "H", start timestamp; receive "H" back)
#F: request frame (send "F", cam #; receive "F" and frame back)
#V: start videos (send "V", filename, and duration; receive "V" back)
#X: stop videos (send "X")

func verify_connection():
	if socket.connect_to_path(socket_path) != OK:
		print("failed to connect to Unix socket")
		connection_failed()
		return
	send_command("H", [str(ms_start)])
	var start_time = Time.get_ticks_msec()
	while Time.get_ticks_msec() - start_time < handshake_timeout * 1000:
		socket.poll()
		if socket.get_available_bytes() > 0:
			var response = socket.get_string(socket.get_available_bytes())
			if response == "H":
				socket_connected = true
				print("socket-python script is running and responsive")
				return
			if response == "E":
				udp_connected = true
				print("socket-python script is running and responsive")
				print("Warning: less than 5 GB of space available on Pi 5. Clear disk space (empty the 'Cam' folder on the Pi 5 desktop) to avoid data loss")
				return
		OS.delay_msec(100) # Wait 100ms between checks
	print("Failed to verify Unix connection")
	connection_failed()


func connection_failed():
	OS.delay_msec(1000)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var _error = get_tree().change_scene("res://sceneSelect.tscn")


func send_command(command: String, params: Array = []):
	var message = command
	if params.size() > 0:
		message += ":" + PoolStringArray(params).join(":")
	message += "\n"
	var _error = socket.put_data(message.to_utf8())
	socket.poll()


func receive_message(expected_command: String):
	while socket.get_available_bytes() > 0:
		var data = socket.get_string(socket.get_available_bytes())
		var lines = data.split("\n", false)
		for line in lines:
			if lin.begins_with(expected_command):
				return line.to_utf8()
		OS.delay_msec(10)
	return PoolByteArray()


func pulse_output(pin: int, pulse_duration: float):
	send_command("O",[str(pin), str(pulse_duration)]) #send TTL pulse output


func request_frames():
	send_command("F") #request frames


func start_video(max_duration: float):
	send_command("V", [experimentName, str(max_duration)])
	receive_message("V")


func stop_video():
	send_command("X")

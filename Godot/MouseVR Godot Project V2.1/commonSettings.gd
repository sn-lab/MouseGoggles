#Common settings and functions used across many scripts

extends Node

#eye parameters
export var inter_eye_distance = 0.01 # all distances/sizes are roughly in meters
export var head_radius = 0.04 # must be large enough to keep eye cameras from getting too close to walls
export var eye_pitch = 10 # degrees from the horizontal (+ = looking up)
export var eye_yaw = 45 # degrees away from the head yaw (forward-facing = 0 deg, side-facing = 90)
export var brightness_modulate = 0.5 # global brightness modulation (1=brightest, 0 = black)

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
var td = OS.get_datetime() # time dictionary
var timestamp = String(td.year) + "_" + String(td.month) + "_" + String(td.day) + "_" + String(td.hour) + "_" + String(td.minute) + "_" + String(td.second)

#viewport nodes
onready var lefthead = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/TextureRect/Viewport/LeftEyeBody")
onready var righthead = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/TextureRect/Viewport/RightEyeBody")
onready var lefteye = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/TextureRect/Viewport/LeftEyeBody/LeftEyePivot")
onready var righteye = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/TextureRect/Viewport/RightEyeBody/RightEyePivot")
onready var colorrect = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/ColorRect")
onready var fpslabel = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/Label")
onready var overlay = get_node("HeadKinBody/Control/Overlay")
#overlay.Modulate = round(255*brightness_modulate)

#UDP communication
var destination_ip = "10.49.243.161"  # IP of Raspberry Pi 5 (running python script)
var destination_port = 5001
var listen_port = 5000
const handshake_timeout := 3.0 # seconds
var udp := PacketPeerUDP.new()
var video_data := PoolByteArray()
var current_file := File.new()
var current_filename := ""

#TCP communication
var tcp_port = 5002

#list of UDP commands:
#H: handshake (send "H", receive "H" back)
#F: request frame (send "F", cam #; receive "F" and frame back)
#V: start videos (send "V", filename, and duration; receive "V" back)
#X: stop videos (send "X", receive "X" back)
#T: transfer videos (send "T", filename; receive "T" back; receive videos over TCP)
#UDP functions
func verify_connection():
	send_command("H")
	var start_time = Time.get_ticks_msec()
	while Time.get_ticks_msec() - start_time < handshake_timeout * 1000:
		if udp.get_available_packet_count() > 0:
			var packet = udp.get_packet()
			if packet.get_string_from_utf8() == "H":
				print("UDP-Python script is running and responsive")
				return
		OS.delay_msec(100) # Wait 100ms between checks
	print("Failed to verify UDP connection")
	OS.delay_msec(1000)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene("res://sceneSelect.tscn")


func send_command(command: String, params: Array = []):
	var message = command
	if params.size() > 0:
		message += ":" + PoolStringArray(params).join(":")
	udp.set_dest_address(destination_ip, destination_port)
	udp.put_packet(message.to_utf8())


func receive_message(command: String):
	while udp.get_available_packet_count() > 0:
		var packet = udp.get_packet()
		if char(packet[0])==command:
			return packet
		else:
			print("command '" + command + "' not received")


func request_frames():
	send_command("F") #request frames
	

func start_video(experimentName: String, max_duration: float):
	send_command("V", [experimentName, str(max_duration)])
	receive_message("V")

func stop_video():
	send_command("X")
	OS.delay_msec(1000)
	receive_message("X")


#TCP functions
func transfer_video(experimentName: String):
	var save_dir = "res://logs/" + experimentName
	print("Beginning video transfer, saving files in " + save_dir)
	OS.delay_msec(3000)
	
	#loop for cameras 1 and 2
	for cam in 2:
		#start a new TCP communication
		var tcp := StreamPeerTCP.new()
		tcp.connect_to_host(destination_ip,tcp_port)
		
		#wait for connection
		var start_time = Time.get_ticks_msec()
		while (tcp.get_status() != StreamPeerTCP.STATUS_CONNECTED) and (Time.get_ticks_msec() - start_time < handshake_timeout * 1000):
			OS.delay_msec(100)
		if tcp.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			print('TCP connection failed')
			return
		
		#request video with UDP command
		send_command("T", [experimentName, str(cam)]) #UDP command to transfer video
		print('Requesting video ' + experimentName + str(cam))
		OS.delay_msec(500)
		receive_message("T")
		OS.delay_msec(500)
		if tcp.get_available_bytes() > 0:
			print('Saving file for cam' + str(cam))
			var file = File.new()
			file.open(save_dir + "/cam" + String(cam) + "_" + experimentName + ".mjpg", File.WRITE)
			while tcp.get_available_bytes() > 0:
				var data = tcp.get_data(tcp.get_available_bytes())
				file.store_buffer(data[1])
				OS.delay_msec(100)
			file.close()
		else:
			print('No bytes transferred for cam ' + str(cam))
			
		#end current TCP connection
		tcp.disconnect_from_host()

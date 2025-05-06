#get common settings
extends "res://commonSettings.gd"

# UDP Configuration
var time_elapsed = 0.0
var frame_period = 1

# Camera Viewports
onready var cam0 = get_node("VBoxContainer/TextureRect")
onready var cam1 = get_node("VBoxContainer2/TextureRect2")
onready var colorlabel = get_node("HBoxContainer2/ColorRect/Label")
onready var colorbox = get_node("HBoxContainer2/ColorRect")

func _ready():
	assert(udp.listen(listen_port) == OK, "UDP listen failed")
	verify_connection()
	time_elapsed = 0
	colorbox.color = Color(0, 0, brightness_modulate)
	colorlabel.text = "Brightness: " + str(brightness_modulate)
	
func _process(delta):
	time_elapsed += delta
	if (time_elapsed >= frame_period):
		time_elapsed = 0
		request_frames()
		
		while udp.get_available_packet_count() > 0:
			var packet = receive_message("F")
			if packet.size()>0:
				var cam_index = packet[1]-48 # ASCII to num
				var image_data = packet.subarray(2, packet.size()-1)
				var image = Image.new()
				var error = image.load_jpg_from_buffer(image_data)
				
				if error == OK:
					var texture = ImageTexture.new()
					texture.create_from_image(image)
					if cam_index == 0:
						cam0.texture = texture
					else:
						cam1.texture = texture
				else:
					print("JPEG decode error: ", error)


func _input(ev):
	if ev is InputEventKey and ev.is_pressed():
		if ev.scancode == KEY_ESCAPE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().change_scene("res://sceneSelect.tscn") 


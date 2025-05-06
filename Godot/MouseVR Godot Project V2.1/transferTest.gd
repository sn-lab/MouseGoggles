extends "res://commonSettings.gd"
var scene_name = "transferTest"
onready var newlabel = get_node("newlabel")
var dataNames = ['head_yaw', 'head_thrust']
# Called when the node enters the scene tree for the first time.
func _ready(): 
	experimentName =  timestamp + "_" + scene_name
	dataArray = [1, 2]
	for i in range(dataArray.size()):
		dataLog.append(dataArray[i])
	saveUtils.save_logs(1,dataArray,dataNames,experimentName)
	tcp.connect_to_host(destination_ip, tcp_port)
	verify_connection()
	start_video(experimentName, 5)
	yield(get_tree().create_timer(3.0), "timeout")
	stop_video()
	print("experiment complete, transferring video...")
	yield(get_tree().create_timer(1.0), "timeout")
	newlabel.text = "transferring video..."
	transfer_video(experimentName)
	print("done")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene("res://sceneSelect.tscn")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

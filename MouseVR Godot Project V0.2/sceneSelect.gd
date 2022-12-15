extends Control

onready var scenetext = get_node("HBoxContainer/VBoxContainer/MarginContainer/Label")

onready var optomotorbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer/Button")
onready var loombutton = get_node("HBoxContainer/VBoxContainer/MarginContainer2/Button")
onready var cliffbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer3/Button")
onready var linearAbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer4/Button")
onready var linearBbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer5/Button")
onready var openbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer6/Button")

# Called when the node enters the scene tree for the first time.
func _ready():
	optomotorbutton.connect("pressed",self,"_load_optomotor")
	loombutton.connect("pressed",self,"_load_loom")
	cliffbutton.connect("pressed",self,"_load_cliff")
	linearAbutton.connect("pressed",self,"_load_linearA")
	linearBbutton.connect("pressed",self,"_load_linearB")
#	openbutton.connect("pressed",self,"_load_openfield")
	
func _load_optomotor():
	get_tree().change_scene("res://optomotorScene.tscn")
	
func _load_loom():
	get_tree().change_scene("res://loomScene.tscn")
	
func _load_cliff():
	get_tree().change_scene("res://cliffScene.tscn")
	
func _load_linearA():
	get_tree().change_scene("res://linearTrackAScene.tscn")
	
func _load_linearB():
	get_tree().change_scene("res://linearTrackBScene.tscn")
	
#func _load_openfield():
#	get_tree().change_scene("res://openFieldScene.tscn")

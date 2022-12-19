extends Control

onready var scenetext = get_node("HBoxContainer/VBoxContainer/MarginContainer/Label")

onready var optomotorbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer/Button")
onready var loombutton = get_node("HBoxContainer/VBoxContainer/MarginContainer2/Button")
onready var cliffbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer3/Button")
onready var linearcliffbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer4/Button")
onready var lineartrackbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer5/Button")
onready var openbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer6/Button")

# Called when the node enters the scene tree for the first time.
func _ready():
	optomotorbutton.connect("pressed",self,"_load_optomotor")
	loombutton.connect("pressed",self,"_load_loom")
	cliffbutton.connect("pressed",self,"_load_cliff")
	linearcliffbutton.connect("pressed",self,"_load_linearCliff")
	lineartrackbutton.connect("pressed",self,"_load_linearTrack")
	openbutton.connect("pressed",self,"_load_openfield")
	
func _load_optomotor():
	get_tree().change_scene("res://optomotorScene.tscn")
	
func _load_loom():
	get_tree().change_scene("res://loomScene.tscn")
	
func _load_cliff():
	get_tree().change_scene("res://cliffScene.tscn")
	
func _load_linearCliff():
	get_tree().change_scene("res://linearCliffScene.tscn")
	
func _load_linearTrack():
	get_tree().change_scene("res://linearTrackScene.tscn")
	
func _load_openfield():
	get_tree().change_scene("res://openFieldScene.tscn")

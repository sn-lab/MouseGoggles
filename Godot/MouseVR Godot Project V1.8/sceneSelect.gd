extends Control

onready var scenetext = get_node("HBoxContainer/VBoxContainer/MarginContainer/Label")

onready var habituationbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer/Button")
onready var loombutton = get_node("HBoxContainer/VBoxContainer/MarginContainer2/Button")
onready var cliffbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer3/Button")
onready var linearcliffbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer4/Button")
onready var lineartrackbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer5/Button")
onready var opentowerbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer6/Button")
onready var openrandombutton = get_node("HBoxContainer/VBoxContainer/MarginContainer7/Button")
onready var optomotorbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer8/Button")
onready var testingbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer9/Button")
onready var rotationbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer10/Button")
onready var lineargapbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer11/Button")
onready var rotatinggratingbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer12/Button")
onready var lineartrackloombutton = get_node("HBoxContainer/VBoxContainer/MarginContainer13/Button")

# Called when the node enters the scene tree for the first time.
func _ready():
	habituationbutton.connect("pressed",self,"_load_habituation")
	loombutton.connect("pressed",self,"_load_loom")
	cliffbutton.connect("pressed",self,"_load_cliff")
	linearcliffbutton.connect("pressed",self,"_load_linearCliff")
	lineartrackbutton.connect("pressed",self,"_load_linearTrack")
	opentowerbutton.connect("pressed",self,"_load_openfieldTower")
	openrandombutton.connect("pressed",self,"_load_openfieldRandom")
	optomotorbutton.connect("pressed",self,"_load_optomotor")
	testingbutton.connect("pressed",self,"_load_testing")
	rotationbutton.connect("pressed",self,"_load_rotation")
	lineargapbutton.connect("pressed",self,"_load_linearGap")
	rotatinggratingbutton.connect("pressed",self,"_load_rotatingGrating")
	lineartrackloombutton.connect("pressed",self,"_load_linearTrackLoom")
	
func _load_habituation():
	get_tree().change_scene("res://habituationScene.tscn")
	
func _load_loom():
	get_tree().change_scene("res://loomScene2_rerender.tscn")
	
func _load_cliff():
	get_tree().change_scene("res://cliffScene.tscn")
	
func _load_linearCliff():
	get_tree().change_scene("res://linearCliffScene2.tscn")
	
func _load_linearTrack():
	get_tree().change_scene("res://linearTrackScene3.tscn")
	
func _load_openfieldTower():
	get_tree().change_scene("res://openFieldTowerScene.tscn")
	
func _load_openfieldRandom():
	get_tree().change_scene("res://openFieldRandomScene.tscn")
	
func _load_optomotor():
	get_tree().change_scene("res://optomotorScene.tscn")
	
func _load_testing():
	get_tree().change_scene("res://testing.tscn")
	
func _load_rotation():
	get_tree().change_scene("res://rotation.tscn")
	
func _load_linearGap():
	get_tree().change_scene("res://linearGapScene.tscn")
	
func _load_rotatingGrating():
	get_tree().change_scene("res://rotatingGratingScene.tscn")
	
func _load_linearTrackLoom():
	get_tree().change_scene("res://linearTrackLoomScene.tscn")

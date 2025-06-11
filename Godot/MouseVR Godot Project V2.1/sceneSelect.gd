#get common settings
extends "res://commonSettings.gd"

# experiment nodes
onready var habituationbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer/Button")
onready var loombutton = get_node("HBoxContainer/VBoxContainer/MarginContainer2/Button")
onready var cliffbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer3/Button")
onready var linearcliffbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer4/Button")
onready var lineartrackbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer5/Button")
onready var opentowerbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer6/Button")
onready var openrandombutton = get_node("HBoxContainer/VBoxContainer/MarginContainer7/Button")
onready var optomotorbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer8/Button")
onready var rotationbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer10/Button")
onready var lineargapbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer11/Button")
onready var rotatinggratingbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer12/Button")
onready var lineartrackloombutton = get_node("HBoxContainer/VBoxContainer/MarginContainer13/Button")
onready var movementbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer14/Button")
onready var receptivefieldbutton = get_node("HBoxContainer/VBoxContainer/MarginContainer15/Button")

# function nodes
onready var testingbutton = get_node("HBoxContainer/VBoxContainer4/MarginContainer9/Button")
onready var camerabutton = get_node("HBoxContainer/VBoxContainer4/MarginContainer15/Button")
onready var exitbutton = get_node("HBoxContainer/VBoxContainer4/MarginContainer2/Button")

#scene select viewport nodes
onready var viewport1 = get_node("HBoxContainer/VBoxContainer3/MarginContainer/ColorRect")
onready var viewport2 = get_node("HBoxContainer/VBoxContainer3/MarginContainer2/ColorRect")

# Called when the node enters the scene tree for the first time.
func _ready():

	#position game window
	OS.set_window_size(Vector2(720,480))
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	var centered_pos = (screen_size-window_size)/2
	OS.set_window_position(centered_pos)
	OS.set_window_resizable(false)
	
	#create fullscreen game window
	#get_tree().root.content_scale_size = Vector2i(720,480)
	#get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	#get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	
	#modulate screen brightness
	viewport1.color = Color(0, 0, 0.5*brightness_modulate)
	viewport2.color = Color(0, 0, 0.5*brightness_modulate)
	
	#connect buttons to functions
	habituationbutton.connect("pressed",self,"_load_habituation")
	loombutton.connect("pressed",self,"_load_loom")
	cliffbutton.connect("pressed",self,"_load_cliff")
	linearcliffbutton.connect("pressed",self,"_load_linearCliff")
	lineartrackbutton.connect("pressed",self,"_load_linearTrack")
	opentowerbutton.connect("pressed",self,"_load_openfieldTower")
	openrandombutton.connect("pressed",self,"_load_openfieldRandom")
	optomotorbutton.connect("pressed",self,"_load_optomotor")
	rotationbutton.connect("pressed",self,"_load_rotation")
	lineargapbutton.connect("pressed",self,"_load_linearGap")
	rotatinggratingbutton.connect("pressed",self,"_load_rotatingGrating")
	lineartrackloombutton.connect("pressed",self,"_load_linearTrackLoom")
	movementbutton.connect("pressed",self,"_load_movement3D")
	receptivefieldbutton.connect("pressed",self,"_load_receptiveField")
	
	testingbutton.connect("pressed",self,"_load_testing")
	camerabutton.connect("pressed",self,"_load_cameraViewer")
	exitbutton.connect("pressed",self,"_exitGame")
	
func _load_habituation():
	var _error = get_tree().change_scene("res://habituationScene.tscn")
	
func _load_loom():
	var _error = get_tree().change_scene("res://loomScene.tscn")
	
func _load_cliff():
	var _error = get_tree().change_scene("res://cliffScene.tscn")
	
func _load_linearCliff():
	var _error = get_tree().change_scene("res://linearCliffScene.tscn")
	
func _load_linearTrack():
	var _error = get_tree().change_scene("res://linearTrackScene.tscn")
	
func _load_openfieldTower():
	var _error = get_tree().change_scene("res://openFieldTowerScene.tscn")
	
func _load_openfieldRandom():
	var _error = get_tree().change_scene("res://openFieldRandomScene.tscn")
	
func _load_optomotor():
	var _error = get_tree().change_scene("res://optomotorScene.tscn")
	
func _load_rotation():
	var _error = get_tree().change_scene("res://rotation.tscn")
	
func _load_linearGap():
	var _error = get_tree().change_scene("res://linearGapScene.tscn")
	
func _load_rotatingGrating():
	var _error = get_tree().change_scene("res://rotatingGratingScene.tscn")
	
func _load_linearTrackLoom():
	var _error = get_tree().change_scene("res://linearTrackLoomScene.tscn")
	
func _load_movement3D():
	var _error = get_tree().change_scene("res://movement3D.tscn")
	
func _load_receptiveField():
	var _error = get_tree().change_scene("res://receptiveFieldScene.tscn")
	
func _load_testing():
	var _error = get_tree().change_scene("res://testing.tscn")
	
func _load_cameraViewer():
	var _error = get_tree().change_scene("res://cameraViewer.tscn")
	
func _exitGame():
	get_tree().quit() 
	

extends Spatial

#eye parameters
export var inter_eye_distance = 0.01
export var head_radius = 0.04 #must be large enough to keep eye cameras from getting too close to walls
export var eye_pitch = 10 #degrees from the horizontal
export var eye_yaw = 45 #degrees away from the head yaw

#movement parameters
export var frames_per_second = 60.0
export var thrust_gain = -0.02 #meters per step
export var lift_gain = -0.01 #meters per step
export var slip_gain = 0.01 #meters per step
export var yaw_gain = 5 #degrees per step
export var mouse_gain = 0.0135

#viewport nodes
onready var lefthead = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/TextureRect/Viewport/LeftEyeBody")
onready var righthead = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/TextureRect/Viewport/RightEyeBody")
onready var lefteye = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/TextureRect/Viewport/LeftEyeBody/LeftEyePivot")
onready var righteye = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/TextureRect/Viewport/RightEyeBody/RightEyePivot")
onready var colorrect = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer/ColorRect")
onready var fpslabel = get_node("HeadKinBody/Control/HBoxContainer/ViewportContainer2/Label")
onready var overlay = get_node("HeadKinBody/Control/Overlay")

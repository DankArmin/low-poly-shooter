extends Node3D

var mouse_mov_x 
var mouse_mov_y
var sway_treshold = 5
var sway_lerp = 5

@export var sway_range : float


func _input(event):
	if event is InputEventMouseMotion:
		mouse_mov_x = -event.relative.x
		mouse_mov_y = event.relative.y


func _process(delta):
	if mouse_mov_x != null:
		if mouse_mov_x > sway_treshold:
			rotation.y = lerp_angle(rotation.y, -sway_range, sway_lerp * delta)
		elif mouse_mov_x < -sway_treshold:
			rotation.y = lerp_angle(rotation.y, sway_range, sway_lerp * delta)
		else:
			rotation.y = lerp_angle(rotation.y, 0, sway_lerp * delta)
	if mouse_mov_y != null:
		if mouse_mov_y > sway_treshold:
			rotation.x = lerp_angle(rotation.x, sway_range, sway_lerp * delta)
		elif mouse_mov_y < -sway_treshold:
			rotation.x = lerp_angle(rotation.x, -sway_range, sway_lerp * delta)
		else:
			rotation.x = lerp_angle(rotation.x, 0, sway_lerp * delta)

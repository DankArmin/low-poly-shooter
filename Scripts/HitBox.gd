class_name HitBox
extends Area3D

var damage := 1

func _init() -> void:
	collision_layer = 4
	collision_mask = 0

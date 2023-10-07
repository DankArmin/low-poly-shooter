extends Node3D

class_name WeaponShot

@export var damage: int

@export var shoot_point: Node3D

func _fire():
	print("Fired shot: " + str(damage))

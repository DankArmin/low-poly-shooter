extends Node3D

class_name WeaponShot

@export var damage: int

func _fire():
	print("Fired shot: " + str(damage))

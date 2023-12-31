extends Node3D

class_name Weapon	

@export var player_reference: Player

@export var magazine_size: int

@export var current_magazine: int

@export var animation_tree: AnimationTree
@onready var animation_state_machine = animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback

const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0

signal on_shoot


func shoot() -> void:
	pass


func reload() -> void:
	pass


func _process(_delta) -> void:
	pass


func check_for_state(state: String) -> bool:
	return animation_state_machine.get_current_node() == state


func check_for_fullMag() -> bool:
	return current_magazine == magazine_size


func check_for_empty_mag() -> bool:
	return current_magazine == 0

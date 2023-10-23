extends Node3D

@onready var arms_animation_player = $ArmsAnimationPlayer
@onready var arms_animation_tree = $AnimationTree
@onready var arms_state_machine

var player_reference: Player


func _ready():
	arms_state_machine = arms_animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback


func _process(delta):
	handle_arm_idle_walk()
	handle_punch_input()


func handle_arm_idle_walk() -> void:
	var current_blend = arms_animation_tree.get("parameters/IdleToWalk/blend_position")
	if player_reference.velocity.y == 0 && player_reference.velocity.x == 0:
		arms_animation_tree.set("parameters/IdleToWalk/blend_position", lerp(float(current_blend), 0.0, 0.2))
	elif player_reference.speed >= player_reference.SPRINT_SPEED:
		arms_animation_tree.set("parameters/IdleToWalk/blend_position", 2.0)
	else:
		arms_animation_tree.set("parameters/IdleToWalk/blend_position", lerp(float(current_blend), 1.0, 0.2))


func handle_punch() -> void:
	arms_animation_tree.set("parameters/conditions/punch", true)
	var timer = Timer.new()
	timer.set_wait_time(.1)
	timer.set_one_shot(true)
	self.add_child(timer)
	timer.start()
	await get_tree().create_timer(0.00001).timeout
	arms_animation_tree.set("parameters/conditions/punch", false)


func handle_punch_input() -> void:
	if arms_state_machine.get_current_node() == "PunchSpeedBlend":
		return
	if Input.is_action_just_pressed("Attack1"):
		arms_animation_tree.set("parameters/PunchSpeedBlend/PunchBlend/blend_position", 0)
		handle_punch()
	elif Input.is_action_just_pressed("Attack2"):
		arms_animation_tree.set("parameters/PunchSpeedBlend/PunchBlend/blend_position", 1)
		handle_punch()

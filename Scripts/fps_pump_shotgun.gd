extends Weapon

class_name PumpShotgun
@onready var shotgun_cock_sound = $ShotgunCockSound
@onready var shotgun_load_sound = $ShotgunLoadSound


func _process(delta) -> void:	
	if Input.is_action_just_pressed("Attack1"):
		shoot()
	
	if Input.is_action_just_pressed("Reload"):
		reload()
	handle_idle_to_sprint(delta)


func handle_idle_to_sprint(delta) -> void:
	var current_blend = animation_tree.get("parameters/IdleToWalkToSprint/blend_position")
	if  (player_reference.speed >= SPRINT_SPEED) && (abs(player_reference.velocity.x) > 0 || abs(player_reference.velocity.y) > 0):
		animation_tree.set("parameters/IdleToWalkToSprint/blend_position", lerp(current_blend, 2.0, 7.5 * delta))
	elif abs(player_reference.velocity.x) > 0 || abs(player_reference.velocity.y) > 0:
		animation_tree.set("parameters/IdleToWalkToSprint/blend_position", lerp(current_blend, 1.0, 7.5 * delta))
	else:
		animation_tree.set("parameters/IdleToWalkToSprint/blend_position", lerp(current_blend, 0.0, 7.5 * delta))


func shoot() -> void:
	if check_if_states_are_playing():
		return
	if check_for_empty_mag():
		reload()
		return  
	
	on_shoot.emit()
	
	animation_tree.set("parameters/conditions/fire", true)
	var timer = Timer.new()
	timer.set_wait_time(.1)
	timer.set_one_shot(true)
	self.add_child(timer)
	timer.start()
	await get_tree().create_timer(0.00001).timeout
	animation_tree.set("parameters/conditions/fire", false)
	
	current_magazine -= 1


func reload() -> void:
	if player_reference.speed >= SPRINT_SPEED:
		return
	if check_if_states_are_playing():
		return
	if check_for_fullMag():
		return
	
	animation_tree.set("parameters/conditions/reload", true)
	var timer = Timer.new()
	timer.set_wait_time(.1)
	timer.set_one_shot(true)
	self.add_child(timer)
	timer.start()
	await get_tree().create_timer(0.00001).timeout
	animation_tree.set("parameters/conditions/reload", false)
	current_magazine += 1


func check_if_states_are_playing() -> bool:
	return check_for_state("fire") or check_for_state("pump") or check_for_state("reload")

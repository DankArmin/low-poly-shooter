extends Weapon

class_name PumpShotgun

func _process(delta):	
	if Input.is_action_just_pressed("Attack1"):
		_shoot()
	
	if Input.is_action_just_pressed("Reload"):
		_reload()
		
	var current_blend = animation_tree.get("parameters/IdleToWalkToSprint/blend_position")
	if  (player_reference.speed >= SPRINT_SPEED) && (abs(player_reference.velocity.x) > 0 || abs(player_reference.velocity.y) > 0):
		animation_tree.set("parameters/IdleToWalkToSprint/blend_position", lerp(current_blend, 2.0, 0.1))
	elif abs(player_reference.velocity.x) > 0 || abs(player_reference.velocity.y) > 0:
		animation_tree.set("parameters/IdleToWalkToSprint/blend_position", lerp(current_blend, 1.0, 0.1))
	else:
		animation_tree.set("parameters/IdleToWalkToSprint/blend_position", lerp(current_blend, 0.0, 0.05))

func _shoot():
	if _check_if_states_are_playing():
		return
	if _check_for_empty_mag():
		_reload()
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

func _reload():
	if _check_if_states_are_playing():
		return
	if _check_for_fullMag():
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
	
func _check_if_states_are_playing() -> bool:
	return _check_for_state("fire") or _check_for_state("pump") or _check_for_state("reload")

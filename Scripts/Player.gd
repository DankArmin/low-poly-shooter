extends CharacterBody3D

var speed

const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const SONIC_SPEED = 11.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.01
const LEG_ROTATION_SPEED = 0.1

const HEAD_BOB_FREQUENCY = 2.0
const HEAD_BOB_AMPLITUDE = 0.08

var t_bob = 0.0

const BASE_FOV = 85
const FOV_CHANGE = 1.5

const SONIC_TIME = 2.5
var sonic_timer = 0.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var fps_holder = $FPSHolder
@onready var cam = $FPSHolder/Camera3D
@onready var animTree = $FPSHolder/SK_Legs/AnimationTree
@onready var animPlayer = $FPSHolder/SK_Legs/AnimationPlayer
@onready var sk_legs = $FPSHolder/SK_Legs
@onready var speed_lines = $FPSHolder/Camera3D/SpeedLines
@onready var arms_animation_player = $FPSHolder/Camera3D/WeaponHolder/SK_Arms/ArmsAnimationPlayer
@onready var arms_animation_tree = $FPSHolder/Camera3D/WeaponHolder/SK_Arms/AnimationTree
@onready var sk_arms = $FPSHolder/Camera3D/WeaponHolder/SK_Arms
@onready var arms_state_machine = arms_animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback

const BASE_LEGS_ROTATION = -135.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	speed_lines.hide()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		fps_holder.rotate_y(-event.relative.x * SENSITIVITY)
		cam.rotate_x(-event.relative.y * SENSITIVITY)
		cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-90.0), deg_to_rad(90.0))

func _physics_process(delta):
	_handle_punch_input()
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir = Input.get_vector("Move_Left", "Move_Right", "Move_Forward", "Move_Backward")
	
	if  Input.is_action_pressed("Sprint") and is_on_floor() and (abs(input_dir.x) > 0 || abs(input_dir.y) > 0):
		if sonic_timer < SONIC_TIME:
			sonic_timer += delta
		if sonic_timer >= SONIC_TIME:
			speed = SONIC_SPEED
			animTree.set("parameters/SpeedBlend/TimeScale/scale", 2)
			speed_lines.show()
		else:
			speed = SPRINT_SPEED
			animTree.set("parameters/SpeedBlend/TimeScale/scale", 1.5)
			speed_lines.hide()
	else:
		if sonic_timer != 0:
			sonic_timer = 0
		speed = WALK_SPEED
		animTree.set("parameters/SpeedBlend/TimeScale/scale", 1.0)
		speed_lines.hide()

	
	var direction = (fps_holder.transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)

	t_bob += delta * velocity.length() * float(is_on_floor())
	cam.transform.origin = _headbob(t_bob)  
	
	var velocity_clamped = clamp(velocity.length(), 1, SONIC_SPEED * 2.0)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	cam.fov = lerp(cam.fov, target_fov, delta * 8.0)
	
	animTree.set("parameters/conditions/jump", !is_on_floor())
	animTree.set("parameters/conditions/land", is_on_floor())
	
	_handle_directional_walk_animation(delta)
	
	_handle_leg_rotation(input_dir)
	
	_handle_arm_idle_walk()
	
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * HEAD_BOB_FREQUENCY) * HEAD_BOB_AMPLITUDE
	pos.x = cos(time * HEAD_BOB_FREQUENCY / 2.0) * HEAD_BOB_AMPLITUDE
	return pos

func _handle_leg_rotation(input_dir):
	var leg_rotation = sk_legs.get_rotation
	if input_dir.x > 0:
		sk_legs.rotation.y = lerp_angle(sk_legs.rotation.y, -180, LEG_ROTATION_SPEED)
	elif input_dir.x < 0:
		sk_legs.rotation.y = lerp_angle(sk_legs.rotation.y, -90, LEG_ROTATION_SPEED)
	else:
		sk_legs.rotation.y = lerp_angle(sk_legs.rotation.y, -135, LEG_ROTATION_SPEED)
	return

func _handle_directional_walk_animation(delta):
	var current_blend = animTree.get("parameters/SpeedBlend/SpeedBlend1D/blend_position")
	if (velocity.y > 0.0):
		animTree.set("parameters/SpeedBlend/SpeedBlend1D/blend_position", lerp(float(current_blend), 1.0, 0.2))
	elif (velocity.y < 0.0):
		animTree.set("parameters/SpeedBlend/SpeedBlend1D/blend_position", lerp(float(current_blend), -1.0, 0.2))
	elif (velocity.x > 0.0 || velocity.x < 0.0):
		animTree.set("parameters/SpeedBlend/SpeedBlend1D/blend_position", lerp(float(current_blend), 1.0, 0.2))
	else:
		animTree.set("parameters/SpeedBlend/SpeedBlend1D/blend_position", lerp(float(current_blend), 0.0, 0.2))
	return
	
func _handle_arm_idle_walk():
	if !sk_arms:
		return
	var current_blend = arms_animation_tree.get("parameters/IdleToWalk/blend_position")
	if velocity.y == 0 && velocity.x == 0:
		arms_animation_tree.set("parameters/IdleToWalk/blend_position", lerp(float(current_blend), 0.0, 0.2))
	elif speed >= SPRINT_SPEED:
		arms_animation_tree.set("parameters/IdleToWalk/blend_position", 2.0)
	else:
		arms_animation_tree.set("parameters/IdleToWalk/blend_position", lerp(float(current_blend), 1.0, 0.2))
		
func _handle_punch():
	if !sk_arms:
		return
	
	arms_animation_tree.set("parameters/conditions/punch", true)
	var timer = Timer.new()
	timer.set_wait_time(.1)
	timer.set_one_shot(true)
	self.add_child(timer)
	timer.start()
	await get_tree().create_timer(0.00001).timeout
	arms_animation_tree.set("parameters/conditions/punch", false)
	
func _handle_punch_input():
	if arms_state_machine.get_current_node() == "PunchSpeedBlend":
		return
	if Input.is_action_just_pressed("Attack1"):
		arms_animation_tree.set("parameters/PunchSpeedBlend/PunchBlend/blend_position", 0)
		_handle_punch()
	elif Input.is_action_just_pressed("Attack2"):
		arms_animation_tree.set("parameters/PunchSpeedBlend/PunchBlend/blend_position", 1)
		_handle_punch()
	

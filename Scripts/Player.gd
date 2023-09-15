extends CharacterBody3D

var speed

const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.03

const HEAD_BOB_FREQUENCY = 2.0
const HEAD_BOB_AMPLITUDE = 0.08

var t_bob = 0.0

const BASE_FOV = 85
const FOV_CHANGE = 1.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var fps_holder = $FPSHolder
@onready var cam = $FPSHolder/Camera3D
@onready var animTree = $FPSHolder/SK_Legs/AnimationTree
@onready var animPlayer = $FPSHolder/SK_Legs/AnimationPlayer
@onready var sk_legs = $FPSHolder/SK_Legs

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		fps_holder.rotate_y(-event.relative.x * SENSITIVITY)
		cam.rotate_x(-event.relative.y * SENSITIVITY)
		cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-90.0), deg_to_rad(90.0))

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if  Input.is_action_pressed("Sprint") and is_on_floor():
		speed = SPRINT_SPEED
		animTree.set("parameters/SpeedBlend/TimeScale/scale", 1.5)
	else:
		speed = WALK_SPEED
		animTree.set("parameters/SpeedBlend/TimeScale/scale", 1.0)

	var input_dir = Input.get_vector("Move_Left", "Move_Right", "Move_Forward", "Move_Backward")
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
	
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2.0)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	cam.fov = lerp(cam.fov, target_fov, delta * 8.0)
	
	animTree.set("parameters/conditions/jump", !is_on_floor())
	animTree.set("parameters/conditions/land", is_on_floor())
	
	_handle_directional_walk_animation(input_dir, delta)
	
	_handle_leg_rotation(input_dir, delta)
	
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * HEAD_BOB_FREQUENCY) * HEAD_BOB_AMPLITUDE
	pos.x = cos(time * HEAD_BOB_FREQUENCY / 2.0) * HEAD_BOB_AMPLITUDE
	return pos

func _handle_leg_rotation(input_dir, delta):
	if input_dir.x == 0.0:
		sk_legs.rotation.y = lerp_angle(sk_legs.rotation.y,-135.0, delta * 2.0)
	elif input_dir.x == 1.0:
		sk_legs.rotation.y = lerp_angle(sk_legs.rotation.y,-180.0, delta * 2.0)
	else:
		sk_legs.rotation.y = lerp_angle(sk_legs.rotation.y,-90.0, delta * 2.0)		

func _handle_directional_walk_animation(input_dir, delta):
	var current_blend = animTree.get("parameters/SpeedBlend/SpeedBlend1D/blend_position")
	if (velocity.y > 0.0):
		animTree.set("parameters/SpeedBlend/SpeedBlend1D/blend_position", lerp(float(current_blend), 1.0, 0.2))
	elif (velocity.y < 0.0):
		animTree.set("parameters/SpeedBlend/SpeedBlend1D/blend_position", lerp(float(current_blend), -1.0, 0.2))
	elif (velocity.x > 0.0 || velocity.x < 0.0):
		animTree.set("parameters/SpeedBlend/SpeedBlend1D/blend_position", lerp(float(current_blend), 1.0, 0.2))
	else:
		animTree.set("parameters/SpeedBlend/SpeedBlend1D/blend_position", lerp(float(current_blend), 0.0, 0.2))

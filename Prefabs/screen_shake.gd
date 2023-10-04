extends Camera3D

var normal_position : Vector3
@export var screen_shake_duration : float = 1.0
var screen_shake_timer : float = 0.0
var is_shaking : bool
var reverting: bool

@export var intensity: Vector3

func _ready():
	normal_position = position


func _process(delta):
	if Input.is_action_just_pressed("Attack1"):
		_start_screen_shake()
	if is_shaking:
		_handle_screen_shake(delta)
	if screen_shake_timer > screen_shake_duration:
		_end_screen_shake()
		screen_shake_timer = 0
		reverting = true
	if reverting: 
		position = lerp(position, normal_position, .1)
		if position == normal_position:
			reverting = false


func _start_screen_shake():
	is_shaking = true


func _end_screen_shake():
	is_shaking = false


func _handle_screen_shake(delta):
	if screen_shake_timer < screen_shake_duration:
		screen_shake_timer += delta
		var timer = Timer.new()
		timer.set_wait_time(.1)
		timer.set_one_shot(true)
		self.add_child(timer)
		timer.start()
		await get_tree().create_timer(0.00001).timeout
		position += Vector3(randf_range(-.1, .1) * intensity.x, randf_range(-.1, .1) * intensity.y, randf_range(-.1, .1) * intensity.z)
		

func _set_and_execute(new_intensity: Vector3, new_duration: float):
	intensity = new_intensity
	screen_shake_duration = new_duration
	_start_screen_shake()

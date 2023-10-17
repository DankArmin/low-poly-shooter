#This script is deprecated => use shakeable_camera instead!
extends Camera3D

class_name ScreenShake

var normal_position : Vector3
@export var screen_shake_duration : float = 1.0
var screen_shake_timer : float = 0.0
var is_shaking : bool
var reverting: bool

@export var intensity: Vector3


func _ready() -> void:
	normal_position = position


func _process(delta) -> void:
	if is_shaking:
		handle_screen_shake(delta)
	if screen_shake_timer >= screen_shake_duration:
		end_screen_shake()
		screen_shake_timer = 0
		reverting = true


func start_screen_shake() -> void:
	is_shaking = true


func end_screen_shake() -> void:
	is_shaking = false


func handle_screen_shake(delta) -> void:
	if screen_shake_timer < screen_shake_duration:
		screen_shake_timer += delta
		var timer = Timer.new()
		timer.set_wait_time(.1)
		timer.set_one_shot(true)
		self.add_child(timer)
		timer.start()
		await get_tree().create_timer(0.00001).timeout
		position += Vector3(randf_range(-.1, .1) * intensity.x, randf_range(-.1, .1) * intensity.y, randf_range(-.1, .1) * intensity.z)


func set_and_execute(new_intensity: Vector3, new_duration: float) -> void:
	intensity = new_intensity
	screen_shake_duration = new_duration
	start_screen_shake()

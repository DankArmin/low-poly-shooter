extends WeaponShot

@export var spread: float = 20
@export var amount_of_projectiles: int = 5
@export var range: float = 10

func _on_fps_pump_shotgun_on_shoot():
	_fire()

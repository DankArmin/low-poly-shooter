extends WeaponShot

@onready var blast: Node3D = $ShootPoint/Blast
@onready var shotgun_shot_sound = $ShotgunShotSound


var bullet = preload("res://Prefabs/Projectiles/Bullet.tscn")
var instance

func _on_fps_pump_shotgun_on_shoot() -> void:
	_fire()


func _fire() -> void:
	shotgun_shot_sound.play()
	blast.rotation.y += 15.0
	for ray in blast.get_children() as Array[RayCast3D]:
			instance = bullet.instantiate()
			instance.position = shoot_point.global_position
			instance.transform.basis = ray.global_transform.basis
			get_tree().root.get_child(0).add_child(instance)
			instance.damage = damage

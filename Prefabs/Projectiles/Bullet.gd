extends Node3D

const _SPEED : float = 40.0
@onready var gpu_particles_3d = $GPUParticles3D
@onready var ray_cast_3d = $RayCast3D
@onready var mesh_instance_3d = $MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.basis * Vector3(0,0,-_SPEED) * delta
	if ray_cast_3d.is_colliding() and not ray_cast_3d.get_collider().is_in_group("Bullets"):
		mesh_instance_3d.visible = false
		gpu_particles_3d.emitting = true
		await get_tree().create_timer(1.0).timeout
		queue_free()
	


func _on_timer_timeout():
	queue_free()

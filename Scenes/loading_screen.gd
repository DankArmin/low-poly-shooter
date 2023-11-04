extends Control

var progress = [0.0]
var scene_load_status
@export_file("*.tscn") var next_scene_path : String
@export var parameters : Dictionary

func _ready():
	ResourceLoader.load_threaded_request(next_scene_path)


func _process(_delta):
	scene_load_status = ResourceLoader.load_threaded_get_status(next_scene_path, progress)
	%progress.text = str(floor(progress[0] * 100)) + "%"
	
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var new_scene = ResourceLoader.load_threaded_get(next_scene_path)
		var new_node = new_scene.instantiate()
		new_node.parameters = parameters
		var current_scene = get_tree().current_scene
		get_tree().get_root().add_child(new_node)
		get_tree().current_scene = new_node
		current_scene.queue_free()
		
		

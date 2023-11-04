extends Node

func load_screen_to_scene(target : String, parameters : Dictionary) -> void:
	var loading_screen = preload("res://Scenes/loading_screen.tscn").instantiate()
	loading_screen.next_scene_path = target
	loading_screen.parameters = parameters
	get_tree().current_scene.add_child(loading_screen)

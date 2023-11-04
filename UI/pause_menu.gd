extends Control

@export var game_manager : GameManager

func _ready():
	hide()
	game_manager.connect("on_game_paused", _on_game_manager_on_game_paused)


func _on_game_manager_on_game_paused(is_paused : bool):
	if is_paused:
		show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_resume_button_pressed():
	game_manager.is_game_paused = false


func _on_save_button_pressed():
	SaveSystem.save_game()


func _on_load_button_pressed():
	Functions.load_screen_to_scene("res://Scenes/game.tscn", {})


func _on_quit_button_pressed():
	get_tree().quit()

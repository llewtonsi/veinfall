extends TileMapLayer

@onready var pause_menu = get_tree().root.get_node("battlefield/Main/pause_container/pause_menu")
@onready var pause_button = get_tree().root.get_node("battlefield/Main/pause_button")
@onready var resume_button = $resume_button
@onready var quit_button = $quit_button
@onready var settings_button = $settings_button
@onready var save_game_button = $save_game_button
@onready var inventory_menu = $"../../inventory_container/inventory_menu"
@onready var dark_backround = $"../../dark_backround"

const NORMAL_COLOR = Color(1, 1, 1, 1)
const PRESSED_COLOR = Color(0.5, 0.5, 0.5, 1)

func _input(event):
	if inventory_menu.visible:
		return

	if event.is_action_pressed("back"):
		toggle_pause()

func toggle_pause():
	get_tree().paused = !get_tree().paused
	pause_menu.visible = get_tree().paused
	dark_backround.visible = get_tree().paused
	if get_tree().paused:
		inventory_menu.visible = false

func _on_pause_button_button_down() -> void:
	pause_button.self_modulate = PRESSED_COLOR

func _on_pause_button_button_up() -> void:
	pause_button.self_modulate = NORMAL_COLOR
	toggle_pause()

func _on_resume_button_button_down() -> void:
	resume_button.self_modulate = PRESSED_COLOR

func _on_resume_button_button_up() -> void:
	resume_button.self_modulate = NORMAL_COLOR
	get_tree().paused = false
	pause_menu.visible = false
	dark_backround.visible = false

func _on_quit_button_button_down() -> void:
	quit_button.self_modulate = PRESSED_COLOR

func _on_quit_button_button_up() -> void:
	quit_button.self_modulate = NORMAL_COLOR
	get_tree().change_scene_to_file("res://scene/hud/main_menu.tscn")

func _on_settings_button_button_down() -> void:
	settings_button.self_modulate = PRESSED_COLOR

func _on_settings_button_button_up() -> void:
	settings_button.self_modulate = NORMAL_COLOR

func _on_save_game_button_button_down() -> void:
	save_game_button.self_modulate = PRESSED_COLOR

func _on_save_game_button_button_up() -> void:
	save_game_button.self_modulate = NORMAL_COLOR

extends Control

@onready var menu_play = $container/button_container/menu_play
@onready var menu_quit = $container/button_container/menu_quit
@onready var title = $container/title_container/title
@onready var containers = $container

var title_time := 0.0
var title_start_pos := Vector2.ZERO

const NORMAL_COLOR = Color(1, 1, 1, 1)
const PRESSED_COLOR = Color(0.5, 0.5, 0.5, 1)

func _ready():
	containers.visible = true

	get_tree().paused = false

	title_start_pos = title.position


func _process(delta):

	title_time += delta

	title.position.y = (
		title_start_pos.y
		+ sin(title_time * 1.5) * 3
	)

func _on_menu_play_button_down() -> void:
	menu_play.self_modulate = PRESSED_COLOR

func _on_menu_play_button_up() -> void:
	menu_play.self_modulate = NORMAL_COLOR
	var loading = preload(
	"res://scene/hud/loading_screen.tscn"
	
	).instantiate()

	get_tree().root.add_child(
		loading
	)

	loading.start_loading(
		"res://scene/battlefield.tscn"
	)

	queue_free()


func _on_menu_quit_button_down() -> void:
	menu_quit.self_modulate = PRESSED_COLOR

func _on_menu_quit_button_up() -> void:
	menu_quit.self_modulate = NORMAL_COLOR
	get_tree().quit()

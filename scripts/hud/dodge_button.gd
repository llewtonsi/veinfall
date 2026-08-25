extends Button

const NORMAL_COLOR = Color(1, 1, 1, 1)
const PRESSED_COLOR = Color(0.5, 0.5, 0.5, 1)


func _ready():
	pressed.connect(_on_dodge_pressed)

	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _on_dodge_pressed():
	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		return

	if not player.can_dodge or player.is_dodging:
		return

	if player.current_stamina < player.DODGE_STAMINA_COST:
		return

	player.start_dodge()

func _on_button_down():
	self_modulate = PRESSED_COLOR


func _on_button_up():
	self_modulate = NORMAL_COLOR

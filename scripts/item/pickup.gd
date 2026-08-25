extends Area2D

@export var item_name := ""

var player_near := false


func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta):
	if player_near and Input.is_action_just_pressed("interact"):
		pickup()


func _on_body_entered(body):
	if !body.is_in_group("player"):
		return

	player_near = true


func _on_body_exited(body):
	if !body.is_in_group("player"):
		return

	player_near = false

func pickup():
	var inventory = get_tree().get_first_node_in_group("inventory")

	if inventory == null:
		push_warning("Inventory node not found.")
		return

	if inventory.add_item(item_name):
		queue_free()

func _input_event(_viewport, event, _shape_idx):
	if !player_near:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pickup()

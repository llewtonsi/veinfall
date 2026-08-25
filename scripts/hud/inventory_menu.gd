extends TileMapLayer

@onready var dark_backround = $"../../dark_backround"
@export var weapon_scene = PackedScene
@onready var inventory_button = $"../../inventory_button"
var toggled = false
const NORMAL_COLOR = Color(1, 1, 1, 1)
const PRESSED_COLOR = Color(0.5, 0.5, 0.5, 1)
@onready var inventory_slots = $inventory_menu_control/inventory_grid.get_children()
@onready var item_info_panel = $inventory_menu_control/item_info_panel

func _process(_event):
	if visible and (Input.is_action_just_pressed("inventory") or Input.is_action_just_pressed("back")):
		_toggle_inventory()
		return
	
	if not visible and Input.is_action_just_pressed("inventory"):
		_toggle_inventory()

func _toggle_inventory():
	if visible != true:
		toggled = false
		visible = true
		dark_backround.visible = true
		inventory_button.z_index = 1
	
	else:
		toggled = true
		visible = false
		dark_backround.visible = false
		inventory_button.z_index = -1

func _on_inventory_button_button_down() -> void:
	inventory_button.self_modulate = PRESSED_COLOR

func _on_inventory_button_button_up() -> void:
	inventory_button.self_modulate = NORMAL_COLOR
	item_info_panel.hide_panel()
	_toggle_inventory()


func add_item(item_name):

	for slot in inventory_slots:

		if slot.item_name == "":
			slot.set_item(item_name)
			return true

	return false

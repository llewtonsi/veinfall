extends Panel

var selected_slot: InventorySlot = null

@onready var use_button = $use_button
@onready var drop_button = $drop_button

func _ready():
	hide()

func show_slot(slot: InventorySlot):
	if slot.item_name == "":
		hide_panel()
		return

	selected_slot = slot

	show()

	$item_name.text = slot.item_display_name
	$item_description.text = slot.item_description

	use_button.visible = slot.item_type == "consumable"
	drop_button.visible = true

func hide_panel():
	selected_slot = null
	$item_name.text = ""
	$item_description.text = ""
	hide()

func _on_use_button_pressed():
	if selected_slot:
		selected_slot.use_item()

func _on_drop_button_pressed():
	if selected_slot:
		selected_slot.drop_item()

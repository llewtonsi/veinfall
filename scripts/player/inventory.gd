extends Control

@onready var inventory_slots = [
	$inventory_container/inventory_menu/inventory_menu_control/inventory_grid/slot_1,
	$inventory_container/inventory_menu/inventory_menu_control/inventory_grid/slot_2,
	$inventory_container/inventory_menu/inventory_menu_control/inventory_grid/slot_3,
	$inventory_container/inventory_menu/inventory_menu_control/inventory_grid/slot_4,
	$inventory_container/inventory_menu/inventory_menu_control/inventory_grid/slot_5,
	$inventory_container/inventory_menu/inventory_menu_control/inventory_grid/slot_6,
	$inventory_container/inventory_menu/inventory_menu_control/inventory_grid/slot_7,
	$inventory_container/inventory_menu/inventory_menu_control/inventory_grid/slot_8,
	$inventory_container/inventory_menu/inventory_menu_control/inventory_grid/slot_9,
	$inventory_container/inventory_menu/inventory_menu_control/inventory_grid/slot_10,
	$inventory_container/inventory_menu/inventory_menu_control/inventory_grid/slot_11,
	$inventory_container/inventory_menu/inventory_menu_control/inventory_grid/slot_12,
	$inventory_container/inventory_menu/inventory_menu_control/inventory_grid/slot_13,
	$inventory_container/inventory_menu/inventory_menu_control/inventory_grid/slot_14,
	$inventory_container/inventory_menu/inventory_menu_control/inventory_grid/slot_15,
]

func add_item(item_name):
	for slot in inventory_slots:
		if slot.item_name == "":
			slot.set_item(item_name)
			return true

	return false

extends Panel
class_name InventorySlot

@export_multiline var item_description := ""
@export var item_display_name := ""

# EQUIPMENT SLOT TYPES
@export var primary_slot := false
@export var secondary_slot := false
@export var is_helmet_slot := false
@export var is_chestplate := false

@onready var player = get_tree().get_first_node_in_group("player")
var showable_scenes = {
	"iron_sword": preload("res://scene/weapons/iron_sword.tscn"),
	"health_potion": preload("res://scene/showable/health_potion.tscn")
}
var item_scenes = {
	"health_potion": preload("res://scene/pickups/health_potion_pickup.tscn"),
	"iron_sword": preload("res://scene/pickups/iron_sword_pickup.tscn")
}

@onready var panel = $"../../item_info_panel"
@onready var icon = $icon
var item_name := ""
var item_type := ""

func _ready():
	pass

func _get_drag_data(_position):
	
	var container = Control.new()
	container.custom_minimum_size = Vector2(48, 48)
	
	var preview = TextureRect.new()
	preview.texture = icon.texture
	preview.size = Vector2(80, 80)
	preview.position = Vector2(-40, -40)
	preview.self_modulate = Color(0.8, 0.8, 0.8, 0.8)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	container.add_child(preview)
	set_drag_preview(container)

	return {
		"name": item_name,
		"type": item_type,
		"source": self
	}


func _can_drop_data(_position, data):

	if primary_slot:
		return data["type"] in ["weapon", "consumable"]

	if secondary_slot:
		return data["type"] in ["weapon", "consumable"]

	if is_helmet_slot:
		return data["type"] == "helmet"

	if is_chestplate:
		return data["type"] == "chestplate"

	return true


func _drop_data(_position, data):

	if data["source"] == self:
		return

# If we're swapping, make sure OUR item can go back into the source slot.
	if item_name != "":
		if !data["source"].accepts_item_type(item_type):
			return
	var old_item = item_name

	set_item(data["name"])

	if old_item == "":
		data["source"].clear_item()
	else:
		data["source"].set_item(old_item)
	# Refresh equipment visuals
	if primary_slot:
		refresh_primary()

	if secondary_slot:
		refresh_secondary()

	if data["source"].primary_slot:
		data["source"].refresh_primary()

	if data["source"].secondary_slot:
		data["source"].refresh_secondary()
	
	if panel.selected_slot == data["source"]:
		panel.show_slot(self)

func _gui_input(event):

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			show_item_info()


func show_item_info():
	if item_name == "":
		panel.hide_panel()
		return

	panel.show_slot(self)

func set_item(item_id):

	item_name = item_id

	match item_id:

		"iron_sword":
			item_type = "weapon"
			icon.texture = preload("res://asset/weapon/iron_sword.png")
			item_display_name = "Iron Sword"
			item_description = "A simple iron sword."

		"health_potion":
			item_type = "consumable"
			icon.texture = preload("res://asset/item/health_potion.png")
			item_display_name = "Health Potion"
			item_description = "Restores 50 HP."

		#"iron_helmet":
			#item_type = "helmet"
			#icon.texture = preload("res://asset/armor/iron_helmet.png")
			#item_display_name = "Iron Helmet"
			#item_description = "A sturdy iron helmet."

		#"iron_chestplate":
			#item_type = "chestplate"
			#icon.texture = preload("res://asset/armor/iron_chestplate.png")
			#item_display_name = "Iron Chestplate"
			#item_description = "Heavy body armor."

		_:
			clear_item()


func clear_item():

	item_name = ""
	item_type = ""
	item_display_name = ""
	item_description = ""
	icon.texture = null


func use_item():

	if item_name == "health_potion":

		if player.heal(50):
			clear_item()
			panel.hide_panel()

func drop_item():

	if item_name == "":
		return
	
	if player == null:
		return
	
	if primary_slot and player:
		player.unequip_primary()
	if secondary_slot and player:
		player.unequip_secondary()

	var scene = item_scenes.get(item_name)

	if scene:

		var dropped = scene.instantiate()

		player.get_parent().add_child(dropped)
		dropped.global_position = player.global_position + Vector2(0,4)

	clear_item()
	panel.hide_panel()

func accepts_item_type(type: String) -> bool:
	if primary_slot:
		return type in ["weapon", "consumable"]

	if secondary_slot:
		return type in ["weapon", "consumable"]

	if is_helmet_slot:
		return type == "helmet"

	if is_chestplate:
		return type == "chestplate"

	return true

func refresh_primary():

	player.unequip_primary()

	if item_name == "":
		return

	var scene = showable_scenes.get(item_name)

	if scene:
		player.equip_primary(item_name, scene)

func refresh_secondary():

	player.unequip_secondary()

	if item_name == "":
		return

	var scene = showable_scenes.get(item_name)

	if scene:
		player.equip_secondary(item_name, scene)

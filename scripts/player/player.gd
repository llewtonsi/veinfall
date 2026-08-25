extends CharacterBody2D

#VARIABLES FOR OUTSIDE NODES:
@onready var primary_holder = $visual_root/right_arm/primary_holder
@onready var secondary_holder = $visual_root/left_arm/secondary_holder
@onready var anim_player = $anim_player
@onready var sword_attack_hitbox = $visual_root/sword_attack_hitbox
@onready var joystick = get_tree().get_root().get_node("battlefield/Main/HUD/joystick")
@onready var visual_root = $visual_root
@onready var stamina_bar = get_tree().get_root().get_node("battlefield/Main/stamina_bar")
@onready var stamina_text = get_tree().get_root().get_node("battlefield/Main/stamina_bar/stamina_text")
@onready var health_bar = get_tree().get_root().get_node("battlefield/Main/health_bar")
@onready var health_text = get_tree().get_root().get_node("battlefield/Main/health_bar/health_text")
@onready var camera = $camera
@onready var main = get_tree().get_root().get_node("battlefield/Main")
@onready var primary_slot = get_tree().get_root().get_node("battlefield/Main/inventory_container/inventory_menu/inventory_menu_control/equipment_grid/primary_slot")

#CONSTANT VARIABLES:
const SPEED := 100.0
const DODGE_SPEED := 250.0
const DODGE_DURATION := 0.30
const DODGE_COOLDOWN := 0.8
const COMBO_WINDOW := 0.6
const LUNGE_FORCE := 10.0
const DODGE_STAMINA_COST := 25.0
const ATTACK_STAMINA_COST := 10.0

#PLAYER_VARIABLES:
var player_direction = Vector2.ZERO
var last_direction := Vector2.RIGHT
var facing_direction := 1
var shake_strength := 0.0
var shake_fade := 25.0

#HEALTH:
var max_health := 100.0
var current_health := 100.0

#STAMINA VARIABLES:
var max_stamina := 100.0
var current_stamina := 100.0
var stamina_regen_rate := 15.0
var stamina_regen_delay := 0.5
var stamina_regen_timer := 0.0
var stamina_warning_timer := 0.0

#DODGE VARIABLES:
var is_dodging := false
var can_dodge := true
var dodge_direction := Vector2.ZERO
var is_invincible := false
var dodge_timer := 0.0
var cooldown_timer := 0.0

#WEAPON:
var equipped_primary = null
var equipped_secondary = null

var equipped_primary_item = ""
var equipped_secondary_item = ""
var is_attacking := false
var can_attack := true

#ATTACK COMBO:
var attack_combo := 0
var combo_timer := 0.0

func _ready() -> void:
	main.visible = true
	
	update_health_bar()
	#HEALTH:
	health_bar.max_value= max_health
	health_bar.value = current_health
	
	health_text.text = "%d/%d" % [current_health, max_health]
	
	#STAMINA:
	stamina_bar.max_value = max_stamina
	stamina_bar.value = current_stamina
	
	stamina_text.text = "%d/%d" % [current_stamina, max_stamina]

func _process(delta):
	if current_health == 0:
		get_tree().change_scene_to_file("res://scene/main_menu.tscn")
	if Input.is_action_just_pressed("test"):
		var DAMAGE = 10.0
		current_health -= DAMAGE
		_handle_health()
	
	#CAMERA SHAKE:
	_handle_camera_shake(delta)
	
	#STAMINA:
	_handle_stamina(delta)
	
	#ATTACK FUNCTION:
	if Input.is_action_just_pressed("attack"):
		
		if equipped_primary_item == "":
			return
			
		if is_attacking:
			return
			
		if not can_attack:
			return
			
		if current_stamina < ATTACK_STAMINA_COST:
			return
			
		_attack()
	
	if combo_timer > 0:
		combo_timer -= delta
	if combo_timer <= 0 and not is_attacking:
		attack_combo = 0
	
func _physics_process(delta):
	if is_attacking:
		move_and_slide()
		return
	
	#DASH INPUT:
	if Input.is_action_just_pressed("dodge") and can_dodge and not is_dodging:
		if current_stamina >= DODGE_STAMINA_COST:
			start_dodge()
		
	#DASH STATE:
	if is_dodging:
		dodge_timer -= delta
		last_direction = dodge_direction.normalized()
		velocity = dodge_direction * DODGE_SPEED
		
		if dodge_timer <= 0:
			end_dodge()
		move_and_slide()
		return
		
	#COOLDOWN TIMER:
	if not can_dodge:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			can_dodge = true
	
	#TOP DOWN NORMAL MOVEMENT:
	var keyboard_input = Vector2.ZERO
	keyboard_input.x = Input.get_axis("move_left","move_right")
	keyboard_input.y = Input.get_axis("move_up","move_down")
	if joystick.output != Vector2.ZERO:
		player_direction = joystick.output
	else:
		player_direction = keyboard_input
	
	if player_direction != Vector2.ZERO:
		velocity = player_direction.normalized() * SPEED
		last_direction = player_direction.normalized()
		
		if player_direction.x != 0:
			last_direction = player_direction
			facing_direction = 1 if player_direction.x > 0 else -1
			visual_root.scale.x = 1 if facing_direction > 0 else -1
			
		if anim_player.current_animation != "run":
			anim_player.play("run")
	else:
		velocity = Vector2.ZERO
		if anim_player.current_animation != "idle":
			anim_player.play("idle")
	
	move_and_slide()
	
	#DASH FUNCTIONS:

func start_dodge():
	current_stamina -= DODGE_STAMINA_COST
	stamina_regen_timer = stamina_regen_delay
	is_dodging = true
	is_invincible = true
	can_dodge = false
	dodge_timer = DODGE_DURATION
	dodge_direction = last_direction.normalized()
	
	anim_player.play("dodge")
	
func end_dodge():
	is_dodging = false
	is_invincible = false
	dodge_timer = 0.0
	cooldown_timer = DODGE_COOLDOWN
	
#WEAPOM ATTACK FUNCTION:
func _attack():
	if equipped_primary_item == "":
		return
	
	match equipped_primary_item:
		#ADD WEAPONS HERE:
		"iron_sword":
			iron_sword_attack()

		_:
			return

func play_attack(animation_name:String):
	current_stamina -= ATTACK_STAMINA_COST
	stamina_regen_timer = stamina_regen_delay

	is_attacking = true
	combo_timer = COMBO_WINDOW

	# MOVING → use movement direction
	# STANDING → use facing direction
	var lunge_dir: Vector2

	if player_direction != Vector2.ZERO:
		lunge_dir = player_direction.normalized()
	else:
		lunge_dir = Vector2(facing_direction, 0)

	velocity = lunge_dir * LUNGE_FORCE
	
	anim_player.play(animation_name)
	await anim_player.animation_finished

	velocity = Vector2.ZERO
	is_attacking = false

func iron_sword_attack():
	attack_combo += 1
	
	if attack_combo > 2:
		attack_combo = 1
	
	match attack_combo:

		1:
			play_attack("sword_attack_1")

		2:
			play_attack("sword_attack_2")


#ATTACK REGISTERED TO ENEMIES:
func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hurtbox"):
		area.get_parent().take_damage(6)
		
		hitstop(0.08)
		shake(2)

func hitstop(duration: float):

	Engine.time_scale = 0.05

	await get_tree().create_timer(
		duration,
		true,
		false,
		true
	).timeout

	Engine.time_scale = 1.0

#STAMINA BAR:
func _handle_stamina(delta):
	if stamina_regen_timer > 0:
		stamina_regen_timer -= delta
	else:
		if current_stamina < max_stamina:
			current_stamina += stamina_regen_rate * delta

	current_stamina = clamp(current_stamina, 0, max_stamina)

	stamina_bar.value = current_stamina
	stamina_text.text = "%d/%d" % [
		round(current_stamina),
		int(max_stamina)
	]
	
func shake(amount: float):
	shake_strength = amount
	
func _handle_camera_shake(delta):

	if shake_strength > 0:

		camera.offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)

		shake_strength = move_toward(
			shake_strength,
			0,
			shake_fade * delta
		)

	else:
		camera.offset = Vector2.ZERO

func equip_primary(item_id:String, primary_scene: PackedScene):
	if is_attacking:
		return
	
	if equipped_primary:
		equipped_primary.queue_free()
	
	equipped_primary_item = item_id
	
	equipped_primary = primary_scene.instantiate()
	primary_holder.add_child(equipped_primary)

func equip_secondary(item_id: String, secondary_scene: PackedScene):
	if equipped_secondary:
		equipped_secondary.queue_free()
	
	equipped_secondary_item = item_id
	
	equipped_secondary = secondary_scene.instantiate()
	secondary_holder.add_child(equipped_secondary)

func unequip_primary():
	if is_attacking:
		return
	
	if equipped_primary:
		equipped_primary.queue_free()
		
		equipped_primary = null
		equipped_primary_item = ""

func unequip_secondary():
	if equipped_secondary:
		equipped_secondary.queue_free()
		
		equipped_secondary = null

func _handle_health():
	current_health = clamp(current_health, 0, max_health)
	
	health_bar.value = current_health
	health_text.text = "%d/%d" % [
		round(current_health),
		int(max_health)
	]

func update_health_bar():
	health_bar.value = current_health
	health_text.text = "%d/%d" % [
		round(current_health),
		int(max_health)
	]

func heal(amount: float) -> bool:
	if current_health >= max_health:
		return false # Already full HP

	current_health = min(current_health + amount, max_health)
	update_health_bar()
	return true

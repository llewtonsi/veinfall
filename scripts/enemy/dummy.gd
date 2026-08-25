extends CharacterBody2D

@onready var anim_dummy = $anim_dummy
@onready var hurt_box = $hurt_box
@onready var dummy_health_bar = $dummy_health_bar
var health_bar_timer := 0.0
const HEALTH_BAR_DURATION := 3.0

func _ready() -> void:
	dummy_health_bar.visible = false

func _process(delta):
	if health_bar_timer > 0:
		health_bar_timer -= delta
	else:
		dummy_health_bar.modulate.a = move_toward(
			dummy_health_bar.modulate.a,
			0,
			4 * delta
		)
		if dummy_health_bar.modulate.a <= 0:
			dummy_health_bar.visible = false
	
func take_damage(amount):
	anim_dummy.play("dummy_hurt")
	dummy_health_bar.value -= amount
	modulate = Color(1, 0, 0, 1)
	await get_tree().create_timer(0.15).timeout
	modulate = Color(1, 1, 1, 1)
	
	dummy_health_bar.visible = true
	dummy_health_bar.modulate.a = 1.0
	health_bar_timer = HEALTH_BAR_DURATION

	if dummy_health_bar.value <= 0:
		anim_dummy.play("dummy_broken")
		dummy_health_bar.queue_free()
		hurt_box.queue_free()

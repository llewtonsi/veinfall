extends Control

@onready var knob = $knob
@onready var base = $base

var joystick_radius = 60.0
var touch_index = -1
var output = Vector2.ZERO
var base_position = Vector2.ZERO

# SETTINGS
var deadzone = 0.30
var curve_strength = 4.0

func _ready():
	base_position = base.position
	reset_joystick()


func _input(event):

	if event is InputEventScreenTouch:

		if event.pressed and touch_index == -1:
			if is_point_inside_joystick(event.position) and not _is_touching_button(event.position):

				touch_index = event.index
				knob.modulate = Color(0.7, 0.7, 0.7)
				base.modulate = Color(0.7, 0.7, 0.7)

				get_viewport().set_input_as_handled()

		elif not event.pressed and event.index == touch_index:

			reset_joystick()
			knob.modulate = Color(1, 1, 1)
			base.modulate = Color(1, 1, 1)

			touch_index = -1

			get_viewport().set_input_as_handled()


	if event is InputEventScreenDrag:

		if event.index == touch_index:

			var center = (
				global_position +
				base.position +
				base.size / 2
			)

			var drag = event.position - center

			drag = drag.limit_length(joystick_radius)

			knob.position = (
				base.position +
				base.size / 2 -
				knob.size / 2 +
				drag
			)

			var normalized = drag / joystick_radius
			var strength = normalized.length()

			# DEADZONE
			if strength < deadzone:
				output = Vector2.ZERO
			else:
				# RESPONSE CURVE
				var adjusted = (
					(strength - deadzone)
					/
					(1.0 - deadzone)
				)

				adjusted = pow(adjusted, curve_strength)

				output = normalized.normalized() * adjusted

			get_viewport().set_input_as_handled()


func is_point_inside_joystick(point):
	var center = global_position + base.position + base.size / 2
	return point.distance_to(center) <= joystick_radius * 2


func _is_touching_button(point) -> bool:

	var attack_btn = get_node("../attack_button")
	var dodge_btn = get_node("../dodge_button")

	if attack_btn.get_global_rect().has_point(point):
		return true

	if dodge_btn.get_global_rect().has_point(point):
		return true

	return false


func reset_joystick():

	knob.position = (
		base.position +
		base.size / 2 -
		knob.size / 2
	)

	output = Vector2.ZERO

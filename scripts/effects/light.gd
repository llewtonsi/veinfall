extends PointLight2D

var base_energy := 1.5

func _process(_delta):
	energy = base_energy + randf_range(-0.15, 0.15)

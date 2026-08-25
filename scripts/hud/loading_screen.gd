extends Control

@onready var progress_bar = $progress_bar
@onready var loading_text = $loading_text

var next_scene := ""
var progress := []

func start_loading(scene_path):

	next_scene = scene_path

	ResourceLoader.load_threaded_request(next_scene)


func _process(_delta):

	var status = ResourceLoader.load_threaded_get_status(
		next_scene,
		progress
	)

	if progress.size() > 0:
		progress_bar.value = progress[0] * 100

	if status == ResourceLoader.THREAD_LOAD_LOADED:

		var packed = ResourceLoader.load_threaded_get(
			next_scene
		)

		get_tree().change_scene_to_packed(
			packed
		)
		
		queue_free()

extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var wait = get_tree().create_timer(5)
	$ColorRect2/AnimationPlayer.play("fade in")
	await wait.timeout
	var new_scene = preload("res://node_2d.tscn")
	var scene_instance = new_scene.instantiate()
	
	get_tree().root.add_child(scene_instance)
	get_tree().current_scene = scene_instance
	

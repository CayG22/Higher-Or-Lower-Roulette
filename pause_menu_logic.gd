extends Control


func _on_resume_button_pressed() -> void:
	var new_scene = preload("res://node_2d.tscn")
	var scene_instance = new_scene.instantiate()
	
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(scene_instance)
	
	get_tree().current_scene = scene_instance
	get_tree().paused = false




func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://title_screen.tscn")

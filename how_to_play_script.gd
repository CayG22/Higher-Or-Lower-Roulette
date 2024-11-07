extends Node2D

func _ready():
	$phaseOneVid.play()
	$targetsVid.play()
	$arrowsVid.play()

func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://title_screen.tscn")

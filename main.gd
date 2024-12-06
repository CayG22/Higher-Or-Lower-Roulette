extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$background/AnimatedSprite2D.play() #Play background
	#$BackgroundMusic.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_play_button_pressed():
	#$ClickSound.play()
	get_tree().change_scene_to_file("res://introscene.tscn")


func _on_quit_button_pressed() -> void:
	#$ClickSound.play()
	get_tree().quit()

func _on_free_play_button_pressed() -> void:
	#$ClickSound.play()
	pass


func _on_options_button_pressed() -> void:
	#$ClickSound.play()
	get_tree().change_scene_to_file("res://optionsMenu.tscn")

func _on_how_to_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://howToPlay.tscn")

func _on_play_button_mouse_entered() -> void:
	$HoverSound.play()


func _on_free_play_button_mouse_entered() -> void:
	$HoverSound.play()


func _on_options_button_mouse_entered() -> void:
	$HoverSound.play()

func _on_quit_button_mouse_entered() -> void:
	$HoverSound.play()


func _on_target_demo_pressed() -> void:
	get_tree().change_scene_to_file("res://TargetDemo.tscn")


func _on_arrow_demo_pressed() -> void:
	get_tree().change_scene_to_file("res://ArrowDemo.tscn")

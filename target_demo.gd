extends Node2D
var screen_size
@onready var target = $Target
@onready var timer_sprite = $Target/timerSprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size 
	move_target()


#TARGET SECTION
func move_target(): #Moves targets in random positions around screen, check to see if there are any targets left	
	var speed = .5 #Set diff.
	
	target.visible = true
	timer_sprite.visible = true
	
	var max_x = screen_size.x - target.get_size().x #Get x size of screen
	var max_y = screen_size.x - target.get_size().y #Get y size of screen
	var new_position = Vector2(randf() * (screen_size.x - max_x), randf() * (screen_size.y - max_y)) #Calc. random position
	target.position = new_position
	
	timer_sprite.set_speed_scale(speed)
	timer_sprite.play("default")
	
	
func _on_target_pressed() -> void: #Check if target was clicked
	$Target/ClickSound.play()
	timer_sprite.stop()
	move_target()


func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://title_screen.tscn")

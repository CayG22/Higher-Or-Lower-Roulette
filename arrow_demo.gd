extends Node2D
@onready var right_arrow_static = $rightArrowStatic
@onready var left_arrow_static = $leftArrowStatic
@onready var right_arrow_falling = $rightArrowFalling
@onready var right_arrow_falling_anim_player = $rightArrowFalling/rightArrowFallingAnimPlayer
@onready var left_arrow_falling = $leftArrowFalling
@onready var left_arrow_falling_anim_player = $leftArrowFalling/leftArrowFallingAnimPlayer
var num_of_arrows = 0 #INT: number of arrows for phase 2
var arrow_animation_finished = false #BOOL: did player miss arrow or not
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loop_arrows()


func loop_arrows(): # Loops arrow falling from top of screen to bottom
	right_arrow_falling.visible = true
	left_arrow_falling.visible = true
	right_arrow_static.visible = true
	left_arrow_static.visible = true
	arrow_animation_finished = false
	
	num_of_arrows = floor(randf_range(5, 10)) #Cal. how many arrows there are
	
	for i in range(20): #For i in max number of arrows
		make_arrow_fall()
		

		
		if arrow_animation_finished: #If anim finished leave loop(Player missed arrow)
			break
		elif num_of_arrows <= 0: #If no arrows left leave loop(Player succeeded)
			break
	
	#No matter the outcome we stop arrows and make them invisible

func make_arrow_fall(): #Decides which arrow should be falling
	if randf() > 0.5:
		right_arrow_falling_anim_player.set_speed_scale(.5)
		right_arrow_falling_anim_player.play("fall")
		
	else:
		left_arrow_falling_anim_player.set_speed_scale(.5)
		left_arrow_falling_anim_player.play("fall")

func _input(event): #Gets the arrow input from user
	if event.is_action_pressed("ui_right") and is_in_target_area("right"):
		#$rightArrowStatic/arrowGet.play()
		num_of_arrows -= 1
		#num_of_arrows_label.text = "Arrows Left: " + str(num_of_arrows)
		handle_hit("right")
	elif event.is_action_pressed("ui_left") and is_in_target_area("left"):
		#$rightArrowStatic/arrowGet.play()
		num_of_arrows -= 1
		#num_of_arrows_label.text = "Arrows Left: " + str(num_of_arrows)
		handle_hit("left")

func is_in_target_area(direction: String) -> bool: #Check to see if the arrow that fell was pressed in time
	if direction == 'right':
		var arrow_y = right_arrow_falling.position.y
		var target_y = right_arrow_static.position.y
		return abs(arrow_y - target_y) < 60
	else:
		var arrow_y = left_arrow_falling.position.y
		var target_y = left_arrow_static.position.y
		return abs(arrow_y - target_y) < 60

func handle_hit(direction: String): #Handles hits
	#If handle hit gets called, duplicate arrow and play the fade anim. This allows for the next arrow to begin falling still.
	if direction == 'right': 
		var right_arrow_dup = right_arrow_falling.duplicate()
		add_child(right_arrow_dup)
		var dup_anim_player = right_arrow_dup.get_node("rightArrowFallingAnimPlayer")
		dup_anim_player.play("fade")
		right_arrow_dup.play("default")
		reset_arrow_position("right")
	elif direction == "left":
		var left_arrow_dup = left_arrow_falling.duplicate()
		add_child(left_arrow_dup)
		var dup_anim_player = left_arrow_dup.get_node("leftArrowFallingAnimPlayer")
		dup_anim_player.play("fade")
		left_arrow_dup.play("default")
		reset_arrow_position("left")

func reset_arrow_position(direction: String): #Resets the arrow positions(Animation)
	if direction == "right":
		right_arrow_falling_anim_player.stop()
		right_arrow_falling_anim_player.play("fall")
	elif direction == "left":
		left_arrow_falling_anim_player.stop()
		left_arrow_falling_anim_player.play("fall")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://title_screen.tscn")

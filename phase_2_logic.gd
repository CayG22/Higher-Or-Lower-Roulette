extends Node2D
var player_lives = 3
var bullet_arr = []
@onready var round_timer = $round_timer
@onready var time_label = $timerLabel
@onready var gun_sprite = $Sprite2D
#Health sprites/animations
@onready var health_sprite = $health_sprite
@onready var health_sprite2 = $health_sprite2
@onready var health_sprite3 = $health_sprite3
@onready var health_animation = $health_sprite/health_animation
@onready var blood_burst1 = $bloodBurst1
@onready var blood_burst2 = $bloodBurst2
@onready var blood_burst3 = $bloodBurst3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

"""Logic Functions"""
func _load_gun(): #Loads gun with random amt of bullets, into random positions
	var cylindar = [0,0,0,0,0,0]
	var num_bullets = randi()% 4 + 1
	var bullet_position = []
	
	var available_positions = [0,1,2,3,4,5]
	available_positions.shuffle()
	
	for i in range(num_bullets):
		cylindar[available_positions[i]] = 1
	
	bullet_arr = cylindar #Assign cylindar to global arr, so it can be seen by player_choice
	



	

func _game_over():# Handle game over logic
	var opponent_sprite = get_node("Opponent")
	var sound_effect = get_node("GameOverSound")

	# Play the opponent's game-over animation
	opponent_sprite.play("game_over_animation")
	sound_effect.play()
	# Wait for the animation to finish before showing the game over message
	await get_tree().create_timer(1.7).timeout

	get_tree().change_scene_to_file("res://title_screen.tscn")

func _get_player_choice(choice: bool):
	var arr = bullet_arr
	if (choice and arr[0] != 1):
		print("Choice: Yourself, Bullet: No")
	elif (choice and arr[1] == 1):
		print("Choice: Yourself, Bullet: Yes")
	elif (not choice and arr[0] != 1):
		print("Choice: UNK, Bullet: No")
	else:
		print("Choice: UNK, Bullet: Yes")

	
"""Health Functions"""
func _check_player_lives(lives: int) -> bool: #Checks player lives to see if player is out of health or not
	if lives == 0:
		return false
	else:
		return true

func _display_health(): #Extremly ugly function, don't care enough cause it works
	var life_loss_sound = get_node("LifeLossSound")
	if player_lives == 3:
		health_sprite.visible = true
		health_sprite2.visible = true
		health_sprite3.visible = true
	elif player_lives == 2:
		life_loss_sound.play()
		blood_burst3.play("default")
		health_sprite.visible = true
		health_sprite2.visible = true
		health_sprite3.visible = false
	elif player_lives == 1:
		life_loss_sound.play()
		blood_burst2.play("default")
		health_sprite.visible = true
		health_sprite2.visible = false
		health_sprite3.visible = false
	else:
		life_loss_sound.play()
		blood_burst1.play("default")
		health_sprite.visible = false
		health_sprite2.visible = false
		health_sprite3.visible = false
	health_animation.play("pulse")


func _on_unk_button_pressed() -> void:
	_get_player_choice(false)

func _on_player_button_pressed() -> void:
	_get_player_choice(true)

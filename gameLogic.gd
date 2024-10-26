extends Node2D
var sfw_mode = true
"""Phase 1 variables"""
var deck = []
var suits = ["hearts", "diamonds", "clubs", "spades"]
var card_sprites = {}  # This will hold the card images as textures
var player_card = 0
var player_card_suit = ""
var opponent_card = 0
var opponent_card_suit = ""
var is_player_turn = true
var game_over = false

var player_lives = 3
var opp_lives = 3

var label_display_time = 3.0
var round_time = 120.0

"""Phase 2 variables"""
var bullet_arr = [0,0,0,0,0,0]
var current_bullet_space = 0
var first_switch = true
var was_correct = true
var turn = 0

"""Phase 1 OnReady Sprites"""
@onready var animation_player = $AnimationPlayer
@onready var introLabel = $introLabel
@onready var higherButton = $HigherButton
@onready var lowerButton = $lowerButton
@onready var opponent_card_animation = $opponent_card_player
@onready var round_timer = $round_timer
@onready var time_label = $timerLabel
@onready var deck_of_cards = $DeckOfCards
@onready var player_card_sprite = $PlayerCardSprite
@onready var opponent_card_sprite = $op_card_sprite

"""Phase 2 OnReady Sprites"""
@onready var unk_button = $UNKButton
@onready var player_button = $playerButton

#Clouds of smoke to make it look like sprites 'appear' on table
@onready var deck_cloud_of_smoke = $deckCloudOfSmoke
@onready var opp_card_cloud_of_smoke = $oppCardCloudOfSmoke
@onready var player_card_cloud_of_smoke = $playerCardCloudOfSmoke
@onready var revolver_sprite_cloud_of_smoke = $gunCloudOfSmoke
@onready var middle_rev_cloud_of_smoke = $middleRevPoof

#Assets for rev. in player's hand, static is for slide in and slide out anims
@onready var player_revolver = $playerRevolver
@onready var player_revolver_anim_player = $playerRevolver/playerRevAnimPlayer
@onready var gun_shot_sound = $gunShot
@onready var empty_shot_sound = $emptyShot
@onready var player_muzzle_flash = $playerMuzzleFlash

#Assets for rev. in UNK's hand, static is for animations
@onready var unk_revolver = $oppRevolver
@onready var unk_revolver_static = $oppRevolverStatic
@onready var unk_revolver_anim_player = $oppRevolver/oppRevolverAnimPlayer

#Main sprite and anim player for revolver on table
@onready var revolver_sprite = $revolverSpriteMain
@onready var revolver_main_anim_player = $revolverSpriteMain/AnimationPlayer

#Assets for rev in middle of screen, only for if UNK chooses to shoot himself
@onready var rev_unk_shoot_self = $revolverIfUnkChoosesSelf

#Labels for phase 2
@onready var switch_label = $switchLabel
@onready var switch_label_2 = $switchLabel2
@onready var unk_hm_label = $oppWaitLabel

"""SFW mode sprites"""
@onready var player_rev_sfw = $playerRevSFW
@onready var player_rev_sfw_anim_player = $playerRevSFW/AnimationPlayer
@onready var main_rev_sfw = $mainRevSFW
@onready var main_rev_sfw_anim_player = $mainRevSFW/mainRevSFWAnimPlayer

"""Health sprites/animations"""
@onready var health_sprite = $health_sprite
@onready var health_sprite2 = $health_sprite2
@onready var health_sprite3 = $health_sprite3
@onready var opp_health_sprite1 = $opp_health_sprite1
@onready var opp_health_sprite2 = $opp_health_sprite2
@onready var opp_health_sprite3 = $opp_health_sprite3

#Health sprite animations
@onready var health_animation = $health_sprite/health_animation
@onready var opp_health_animation = $opp_health_sprite1/opp_health_animations

#Blood burst anims for player and opp, plays if life is loss
@onready var blood_burst1 = $bloodBurst1
@onready var blood_burst2 = $bloodBurst2
@onready var blood_burst3 = $bloodBurst3
@onready var opp_blood_burst1 = $unkBloodBurst1
@onready var opp_blood_burst2 = $unkBloodBurst2
@onready var opp_blood_burst3 = $unkBloodBurst3

"""Main game loop"""
func _ready(): #Everything that scene when game is loaded
	introLabel.visible = true
	health_sprite.visible = false
	health_sprite2.visible = false
	health_sprite3.visible = false
	opp_health_sprite1.visible = false
	opp_health_sprite2.visible = false
	opp_health_sprite3.visible = false
	if sfw_mode:
		player_revolver = player_rev_sfw
		player_revolver_anim_player = player_rev_sfw_anim_player
		revolver_main_anim_player = main_rev_sfw_anim_player
		revolver_sprite = main_rev_sfw

	load_card_art()
	#$Background/AnimatedSprite2D.play() #Play background 
	create_deck()  # Initialize deck with proper rank and suit combinations
	deck.shuffle()
	await get_tree().create_timer(label_display_time).timeout
	introLabel.visible = false
	_load_gun()
	print(bullet_arr)
	_display_health()
	_play_starting_animations()
	start_phase_1()
	#start_round_timer()


"""On startup functions"""
func start_round_timer(): #Starts the round timer
	round_timer.wait_time = round_time
	round_timer.start()
	round_timer.timeout.connect(Callable(self,"_on_round_timer_timeout"))
	
	update_time_label()

func create_deck(): #Creates Deck
	for suit in suits:
		for rank in range(2, 15):  # 2 to 14, where 11=Jack, 12=Queen, 13=King, 14=Ace
			deck.append([rank, suit])  # Each card is a pair [rank, suit]

func load_card_art(): # Create a dictionary to map cards to their respective images
	for rank in range(2, 15):
		for suit in suits:
			var card_name = "%s_of_%s.png" % [str(rank), suit]  # Use parentheses for format strings
			card_sprites["%s_of_%s" % [str(rank), suit]] = load("res://cards/%s" % card_name)


"""Update functions"""
func update_time_label(): #Updates time label evrey second
	while round_timer.time_left > 0:
		var remaining_time = int(floor(round_timer.time_left))
		time_label.text = str(remaining_time) + "s"
		await get_tree().create_timer(1.0).timeout
		
	time_label.text = "0s"


"""Game logic functions"""
func start_phase_1(): # Start a new round by drawing player and opponent cards
	if game_over:
		return

	var player_card_info = draw_card()
	var opponent_card_info = draw_card()

	# Keep drawing until the card numbers (ranks) are different
	while player_card_info[0] == opponent_card_info[0]:
		opponent_card_info = draw_card()

	player_card = player_card_info[0]
	player_card_suit = player_card_info[1]
	opponent_card = opponent_card_info[0]
	opponent_card_suit = opponent_card_info[1]

	print("Your card is: " + str(player_card) + " of " + player_card_suit)
	print("Opponent's card is: " + str(opponent_card) + " of " + opponent_card_suit)

	# Update card visual
	display_card_art()

func start_phase_2(): #Starts 'round' for phase two, checks who gets to choose who to shoot
	if is_player_turn: #If it is the player's turn
		if was_correct: #Correct
			print("(CORRECT) Player chooses who to shoot")
			play_player_phase_2_animations() #Play player animations
		else: #Incorrect
			print("(INCORRECT)Unk's chooses who to shoot")
			revolver_main_anim_player.play("towards_UNK")
			await revolver_main_anim_player.animation_finished
			revolver_sprite.visible = false
			unk_revolver.visible = true
			unk_shoot_choice_outcome() 
	else: #UNKS turn
		if was_correct: #Correct
			print("(CORRECT) Unk chooses who to shoot")
			revolver_main_anim_player.play("towards_UNK")
			await revolver_main_anim_player.animation_finished
			revolver_sprite.visible = false
			unk_revolver.visible = true
			unk_shoot_choice_outcome()
		else: #Incorrect
			print("(INCORRECT) Player chooses who to shoot")
			play_player_phase_2_animations() #Play Player animations


func draw_card() -> Array: # Draw a card from the deck
	return deck.pop_back()  # Return a card as [rank, suit]

func display_card_art(): # Display the card art for both player and opponent
	# Set the player card art
	var player_card_texture = card_sprites["%s_of_%s" % [str(player_card), player_card_suit]]
	get_node("PlayerCardSprite").texture = player_card_texture

	# Set the opponent card art
	var opponent_card_texture = card_sprites["%s_of_%s" % [str(opponent_card), opponent_card_suit]]
	get_node("OpponentCardSprite").texture = opponent_card_texture

func _on_round_timer_timeout(): #Checks if timer runs out, if it does end the game
	_game_over()

func player_guess(is_higher: bool): # Handle player's guess (higher or lower)
	if (is_higher and player_card > opponent_card) or (not is_higher and player_card < opponent_card):
		print("You guessed correctly!")
		$correctSound.play()
		$checkMark.show()
		$GreenRect.show()
		for i in range(100):
			await get_tree().process_frame
		$checkMark.hide()
		$GreenRect.hide()
		_switch_to_phase_2()
		was_correct = true
	else:
		print("You were wrong")
		$incorrectSound.play()
		$xMark.show()
		$RedRect.show()
		for i in range(80):
			await get_tree().process_frame
		$xMark.hide()
		$RedRect.hide()
		_switch_to_phase_2()
		was_correct = false

func _game_over():# Handle game over logic
	var opponent_sprite = get_node("Opponent")
	var player_card = get_node("PlayerCardSprite")
	var opponent_card = get_node("OpponentCardSprite")
	var sound_effect = get_node("GameOverSound")
	game_over = true  # Mark the game as over
	higherButton.set_visible(false)
	lowerButton.set_visible(false)
	player_card.set_visible(false)
	opponent_card.set_visible(false)
	# Play the opponent's game-over animation
	opponent_sprite.play("game_over_animation")
	sound_effect.play()
	# Wait for the animation to finish before showing the game over message
	await get_tree().create_timer(1.7).timeout


	get_tree().change_scene_to_file("res://title_screen.tscn")

func _load_gun(): #Loads gun with random amt of bullets, into random positions
	var cylindar = [0,0,0,0,0,0]
	var num_bullets = randi()% 4 + 1
	var bullet_position = []
	
	var available_positions = [0,1,2,3,4,5]
	available_positions.shuffle()
	
	for i in range(num_bullets):
		cylindar[available_positions[i]] = 1
		
	bullet_arr = cylindar
	GameData.global_bullet_array = cylindar

func unk_card_decision() -> bool: #Returns true for higher, false for lower
	if opponent_card > 7: #Greater than 7, greater chance to choose higher
		if randf() <= .1: #20% choose opposite
			return false
		else:
			return true
	elif opponent_card < 7: #Less than 7, greater chance to choose lower
		if randf() <= .1: #20% to choose opposite
			return true
		else:
			return false
	else: #Equal to 7, 50/50 
		if randf() <= .5:
			return true
		else:
			return false

func unk_card_choice_outcome(): #Returns true if UNK was right, false if he was wrong
	var choice = unk_card_decision()

	show_opponent_card_choice(choice)
	for i in range(400): #Wait for 4 seconds
		await get_tree().process_frame
	
	if (choice and opponent_card > player_card) or (not choice and opponent_card < player_card):
		print("UNK was right")
		$correctSound.play()
		$checkMark.show()
		$GreenRect.show()
		for i in range(100):
			await get_tree().process_frame
		$checkMark.hide()
		$GreenRect.hide()
		_switch_to_phase_2()
		was_correct = true
	else:
		print("UNK was wrong")
		$incorrectSound.play()
		$xMark.show()
		$RedRect.show()
		for i in range(80):
			await get_tree().process_frame
		$xMark.hide()
		$RedRect.hide()
		_switch_to_phase_2()
		was_correct = false

func unk_shoot_choice_outcome():
	var shoot_player = unk_shoot_decision()
	var wait_time = get_tree().create_timer(2)
	var poof_noise = get_node("poofSoundEffect")
	
	if unk_revolver.visible == false:
		unk_revolver.visible = true
	unk_revolver_anim_player.play("float_around")
	show_opponent_choice(shoot_player)
	
	for i in range(400): #Wait for 4 seconds
		await get_tree().process_frame
	
	if shoot_player and bullet_arr[current_bullet_space] == 1:
		print("UNK chooses to shoot player")
		
		current_bullet_space += 1 #Go to the next round in chamber
		player_lives -= 1
		_display_health()

		gun_shot_sound.play()
		unk_revolver.play("default")

		for i in range(200): #Wait for 2 seconds
			await get_tree().process_frame

		if _check_player_lives(player_lives):
			turn += 1
			if turn == 6:
				_load_gun()
				first_switch = true
				turn = 0
			_switch_to_phase_1()
			start_phase_1()
		else:
			_game_over()

	elif !shoot_player and bullet_arr[current_bullet_space] == 1:
		unk_revolver.visible = false
		print("UNK chooses to shoot himself")
		middle_rev_cloud_of_smoke.visible = true
		middle_rev_cloud_of_smoke.play("default")
		poof_noise.play()
		for i in range(20):
			await get_tree().process_frame
		rev_unk_shoot_self.visible = true
		await middle_rev_cloud_of_smoke.animation_finished
		rev_unk_shoot_self.play("default")
		gun_shot_sound.play()
		current_bullet_space += 1 #Go to the next round in chamber
		opp_lives -= 1
		_display_health()
		for i in range(90):
			await get_tree().process_frame
		rev_unk_shoot_self.visible = false

		for i in range(90):
			await get_tree().process_frame
		if _check_opp_lives(opp_lives):
			turn += 1
			print(turn)
			if turn == 6:
				_load_gun()
				first_switch = true
				turn = 0
			_switch_to_phase_1()
			start_phase_1()
		else:
			_game_over()
		
	else:
		if shoot_player:
			print("(EMPTY)UNK chooses to shoot player")
			current_bullet_space += 1 #Go to the next round in chamber
			empty_shot_sound.play()
			unk_revolver.play("noMuzzle")
			for i in range(200): #Wait for 2 seconds
				await get_tree().process_frame
			unk_revolver.visible = false
			turn += 1
			print(turn)
			if turn == 6:
				_load_gun()
				first_switch = true
				turn = 0
			_switch_to_phase_1()
			start_phase_1()
		else:
			unk_revolver.visible = false
			print("(EMPTY)UNK chooses to shoot himself")
			middle_rev_cloud_of_smoke.visible = true
			poof_noise.play()
			middle_rev_cloud_of_smoke.play("default")
			for i in range(20):
				await get_tree().process_frame
			rev_unk_shoot_self.visible = true
			await middle_rev_cloud_of_smoke.animation_finished
			rev_unk_shoot_self.play("default")
			empty_shot_sound.play()
			for i in range(90):
				await get_tree().process_frame
			current_bullet_space += 1 #Go to the next round in chamber

			rev_unk_shoot_self.visible = false
			for i in range(90):
				await get_tree().process_frame
			turn += 1
			print(turn)
			if turn == 6:
				_load_gun()
				first_switch = true
				turn = 0
			_switch_to_phase_1()
			start_phase_1()

#TODO finish this
func shoot_again(is_player_turn: bool):
	if is_player_turn:
		player_revolver_anim_player.play("slide_in")
		await player_revolver_anim_player.animation_finished
	else:
		unk_shoot_choice_outcome()

func unk_shoot_decision() -> bool: #If true, opponent will choose to shoot player, else shoot self
	var player_score = 0
	var opp_score = 0
	var MAX_BULLETS = 4
	var HEALTH_WEIGHT = .3
	var BULLET_WEIGHT = .5
	var last_bullet = check_last_bullet(bullet_arr,current_bullet_space) #bool
	var num_of_bullets_left = check_bullets_left(bullet_arr,current_bullet_space) #int
	#Start calculation by remaining health
	if player_lives < opp_lives:
		player_score += HEALTH_WEIGHT * 100
	else:
		opp_score += HEALTH_WEIGHT * 100
	
	if num_of_bullets_left == 1: #Only 1 bullet remains case
		if last_bullet:
			opp_score += BULLET_WEIGHT * 100
		else:
			player_score += BULLET_WEIGHT * 100
	else: #More general cases
		if last_bullet:
			opp_score += BULLET_WEIGHT * (num_of_bullets_left/MAX_BULLETS) * 100
		else:
			player_score += BULLET_WEIGHT * (num_of_bullets_left/MAX_BULLETS) * 100
	
	if player_score > opp_score: #Whoever's score is higher, that's who gets shot
		if randf() <= .05: #5% chance AI will choose opposite
			return false
		else:
			return true
	else:
		if randf() <= .05: #5% chance AI will choose opposite
			return true	
		else:	
			return false
	
func check_last_bullet(bullet_arr: Array, current_pos: int) -> bool: #Checks what last bullet was, false if empty, true if not empty
	if bullet_arr[current_pos - 1] == 0:
		return false
	else:
		return true

func check_bullets_left(bullet_arr: Array, current_pos: int) -> int: #Checks number of bullets left in cylinder
	var count = 0
	
	for i in range(current_pos,bullet_arr.size()):
		if bullet_arr[i] == 1:
			count += 1

	return count

func _switch_to_phase_2(): #Switches 'state' to phase 2
	var poof_noise = get_node("poofSoundEffect")
	if first_switch: #if havent switched this round
		var wait_timer = get_tree().create_timer(3.0)
		var small_timer = get_tree().create_timer(.1)
		poof_noise.play()
		poof_noise.play()
		
		#Make Phase 1 sprites invisible
		deck_of_cards.visible = false
		deck_cloud_of_smoke.play("default")
		
		opponent_card_sprite.visible = false
		opp_card_cloud_of_smoke.play("default")
		
		player_card_sprite.visible = false
		player_card_cloud_of_smoke.play("default")
		
		higherButton.visible = false
		lowerButton.visible = false
		switch_label.visible = true
		await wait_timer.timeout
		
		switch_label.visible = false
		revolver_sprite_cloud_of_smoke.play("default")
		
		for i in range(10):
			await get_tree().process_frame
		poof_noise.play()
		
		revolver_sprite.visible = true
		for i in range(5):
			await get_tree().process_frame
			
		switch_label_2.visible = true
		for i in range(150):
			await get_tree().process_frame
		switch_label_2.visible = false
		#_switch_scene()
		start_phase_2()
	else: #Not the first switch
		var wait_timer = get_tree().create_timer(1.0)
		poof_noise.play()
		#Make Phase 1 sprites invisible
		deck_of_cards.visible = false
		deck_cloud_of_smoke.play("default")
		
		opponent_card_sprite.visible = false
		opp_card_cloud_of_smoke.play("default")
		
		player_card_sprite.visible = false
		player_card_cloud_of_smoke.play("default")
		
		higherButton.visible = false
		lowerButton.visible = false
		await wait_timer.timeout
		revolver_sprite_cloud_of_smoke.play("default")
		for i in range(5): #Wait for 5 frames
			await get_tree().process_frame
		poof_noise.play()
		revolver_sprite.visible = true
		start_phase_2()
		
		
	first_switch = false

func _switch_to_phase_1(): #Switches 'state' to phase 1
	#Switch turn
	is_player_turn = !is_player_turn
	phase_1_sprite_changes() #Changes visibility of sprites
	
	if is_player_turn:
		higherButton.visible = true
		lowerButton.visible = true
	else:
		unk_card_choice_outcome()


"""Health Functions"""
func _check_player_lives(lives: int) -> bool: #Checks player lives to see if player is out of health or not
	if lives == 0:
		return false
	else:
		return true

func _check_opp_lives(lives: int) -> bool: #Checks opp health
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
		#blood_burst3.play("default")
		health_sprite.visible = true
		health_sprite2.visible = true
		health_sprite3.visible = false
	elif player_lives == 1:
		life_loss_sound.play()
		#blood_burst2.play("default")
		health_sprite.visible = true
		health_sprite2.visible = false
		health_sprite3.visible = false
	else:
		life_loss_sound.play()
		#blood_burst1.play("default")
		health_sprite.visible = false
		health_sprite2.visible = false
		health_sprite3.visible = false
	
	if opp_lives == 3:
		opp_health_sprite1.visible = true
		opp_health_sprite2.visible = true
		opp_health_sprite3.visible = true
	elif opp_lives == 2:
		life_loss_sound.play()
		#opp_blood_burst1.play("default")
		opp_health_sprite1.visible = false
		opp_health_sprite2.visible = true
		opp_health_sprite3.visible = true
	elif opp_lives == 1:
		life_loss_sound.play()
		#opp_blood_burst2.play("default")
		opp_health_sprite1.visible = false
		opp_health_sprite2.visible = false
		opp_health_sprite3.visible = true
	else:
		life_loss_sound.play()
		#opp_blood_burst3.play("default")
		opp_health_sprite1.visible = false
		opp_health_sprite2.visible = false
		opp_health_sprite3.visible = false
	
	health_animation.play("pulse")
	opp_health_animation.play("pulse")	


"""Button Section"""
func _on_higher_button_pressed(): #Handles HigherButton
	player_guess(true)

func _on_lower_button_pressed(): #Handles LowerButton
	player_guess(false)

func _on_unk_button_pressed(): #Handles unkButton press
	if bullet_arr[current_bullet_space] == 0: #If there is no bullet
		player_revolver.play("default") #Play shot anim
		empty_shot_sound.play() #Play empty sound
		await player_revolver.animation_finished #Wait till anim is done

		player_revolver_anim_player.play_backwards("slide_in") #Slide static out of frame
		await player_revolver_anim_player.animation_finished
		current_bullet_space += 1 #Go to the next round in chamber
		turn += 1
		print(turn)
		if turn == 6:
			_load_gun()
			first_switch = true
			turn = 0
		_switch_to_phase_1() #Switch back to first phase
		start_phase_1()
	else: #Same logic as if, but now there is a bullet
		player_muzzle_flash.play("default")
		player_revolver.play("default")
		gun_shot_sound.play()
		await player_revolver.animation_finished
		opp_lives -= 1 #Get rid of one health
		_display_health() #Update health
		player_revolver_anim_player.play_backwards("slide_in")
		await player_revolver_anim_player.animation_finished
		if _check_opp_lives(opp_lives): #Check to see if opp has health left
			current_bullet_space += 1
			turn += 1
			print(turn)
			if turn == 6:
				_load_gun()
				first_switch = true
				turn = 0
			_switch_to_phase_1()
			start_phase_1()
		else:
			_game_over()

func _on_player_button_pressed(): #Handles playerButton press
	if bullet_arr[current_bullet_space] == 0:
		empty_shot_sound.play()
		current_bullet_space += 1
		turn += 1
		print(turn)
		if turn == 6:
			_load_gun()
			first_switch = true
			turn = 0
		_switch_to_phase_1()
		start_phase_1()
	else:
		gun_shot_sound.play()
		player_lives -= 1
		_display_health()
		if _check_player_lives(player_lives):
			current_bullet_space += 1
			
			turn += 1
			print(turn)
			if turn == 6:
				_load_gun()
				first_switch = true
				turn = 0
			
			_switch_to_phase_1()
			start_phase_1()
		else:
			_game_over()


"""Animation section"""
func _play_starting_animations(): #TODO fix this, make it more clean
	opponent_card_animation.play("slide_over")
	await opponent_card_animation.animation_finished
	opponent_card_animation.play("slide_up")
	animation_player.play("slide_in")
	await opponent_card_animation.animation_finished
	opponent_card_animation.play("hover")

func _on_animation_player_animation_finished(anim_name: StringName) -> void: #TODO fix this as well
	higherButton.set_visible(true)
	lowerButton.set_visible(true)

func play_player_phase_2_animations():
	unk_button.visible = true
	player_button.visible = true
	revolver_main_anim_player.play("towards_player")
	await revolver_main_anim_player.animation_finished
	player_revolver_anim_player.play("slide_in")
	await player_revolver_anim_player.animation_finished



func phase_1_sprite_changes(): #Sprite changes when changing back to phase 1
	#Make phase 2 sprites invisible
	unk_button.visible = false
	player_button.visible = false
	revolver_sprite.visible = false
	#Make Phase 1 sprites visible
	deck_of_cards.visible = true
	opponent_card_sprite.visible = true
	player_card_sprite.visible = true


"""Scene switching section"""
func _switch_scene(): #Switch between this scene and the loading bullets scene
	get_tree().paused = true
	var new_scene = preload("res://bullet_loading_scene.tscn")
	var scene_instance = new_scene.instantiate()
	
	get_tree().root.add_child(scene_instance)
	get_tree().current_scene = scene_instance


"""Dynamic functions"""
func show_opponent_choice(choice: bool): #Shows whoever UNK chose to shoot
	var message1 = "Hmmmm..."
	$oppWaitLabel.text = message1
	$oppWaitLabel.show()
	for i in range(200):
		await get_tree().process_frame
	$oppWaitLabel.hide()
	if choice:
		var message = "I choose you!"
		$oppChoiceLabel.text = message
		$oppChoiceLabel.show()
		for i in range(200):
			await get_tree().process_frame
		$oppChoiceLabel.hide()
	else:
		var message = "I choose me!"
		$oppChoiceLabel.text = message
		$oppChoiceLabel.show()
		for i in range(200):
			await get_tree().process_frame
		$oppChoiceLabel.hide()

func show_opponent_card_choice(higher: bool):
	var message1 = "Hmmmm..."
	$oppWaitLabel.text = message1
	$oppWaitLabel.show()
	for i in range(200):
		await get_tree().process_frame
	$oppWaitLabel.hide()
	if higher:
		var message2 = "I choose higher!"
		$oppChoiceLabel.text = message2
		$oppChoiceLabel.show()
		for i in range(200):
			await get_tree().process_frame
		$oppChoiceLabel.hide()
	else:
		var message2 = "I choose lower!"
		$oppChoiceLabel.text = message2
		$oppChoiceLabel.show()
		for i in range(200):
			await get_tree().process_frame
		$oppChoiceLabel.hide()

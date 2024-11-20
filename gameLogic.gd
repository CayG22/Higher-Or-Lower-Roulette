extends Node2D

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
var first_switch = true
var was_correct = true
var easy_mode_speed = .7
var normal_mode_speed = 1.1
var hard_mode_speed = 1.7
var arrow_easy_mode_speed = .5
var arrow_normal_mode_speed = .8
var arrow_hard_mode_speed = 1
var screen_size
var num_of_targets = 0
var num_of_arrows = 0
var arrow_animation_finished = false
var arrow_difficulty = 0
var target_difficulty = 0

"""Phase 1 OnReady Sprites"""
@onready var difficulty_panel = $difficultyPanel
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
@onready var deck_cloud_of_smoke = $deckCloudOfSmoke
@onready var opp_card_cloud_of_smoke = $opp_card_cloud_of_smoke
@onready var player_card_cloud_of_smoke = $playerCardCloudOfSmoke

#Labels for phase 2
@onready var switch_label = $switchLabel
@onready var switch_label_2 = $switchLabel2
@onready var unk_hm_label = $oppWaitLabel


"""Phase 2 on ready Sprites"""
@onready var target = $Target
@onready var timer_sprite = $Target/timerSprite
@onready var right_arrow_static = $rightArrowStatic
@onready var left_arrow_static = $leftArrowStatic
@onready var right_arrow_falling = $rightArrowFalling
@onready var right_arrow_falling_anim_player = $rightArrowFalling/rightArrowFallingAnimPlayer
@onready var left_arrow_falling = $leftArrowFalling
@onready var left_arrow_falling_anim_player = $leftArrowFalling/leftArrowFallingAnimPlayer
@onready var num_of_targets_label = $numOfTargetsLabel
@onready var num_of_arrows_label = $numOfArrowsLabel


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

"""Unk Vars"""
@onready var unk_sprite = $Unk
@onready var magic_ball_sprite = $magicBall
@onready var magic_ball_anim_player = $magicBall/magicBallAnimPlayer

"""Dialogue variables"""
@onready var player_dialogue = $PlayerDialogueLabel
@onready var what_did_I_do = $Player/whatDidIDoLastNight
@onready var who_are_you = $Player/whoAreYou
@onready var wth_you_talk_about = $Player/wthYouTalkAbout
@onready var what = $Player/what
@onready var I_know_basement = $Player/IKnowBasement
@onready var a_game = $Player/aGame
@onready var what_you_mean_die = $Player/whatYouMeanDie
@onready var no_I_dont_got_it = $Player/noIDontGotIt

@onready var unk_dialogue = $UnkDialogueLabel
@onready var your_awake = $Unk/yourAwake
@onready var asking_about_me = $Unk/askingAboutMe
@onready var your_in_my_house = $Unk/YourInMyHouse
@onready var you_know_basement = $Unk/youKnowABasement
@onready var fairly_sound_proof = $Unk/fairlySoundProof
@onready var here_to_play_game = $Unk/hereToPlayGame
@onready var a_game_of_life_or_death = $Unk/AGameOfLifeOrDeath
@onready var one_is_going_to_die = $Unk/oneOfUsGoingToDie
@onready var not_very_quick = $Unk/notVeryQuickOnFeet
@onready var lets_play = $Unk/letsPlay
@onready var i_thought_you_be_diff = $Unk/IThoughtYoudBeDiffernet
@onready var oops_are_you_okay = $Unk/OopsAreYouOkay
@onready var that_has_not_happened = $Unk/ThatHasntHappenInALongTime
@onready var well_thats_not_how = $Unk/WellThatsNotHowThisWasSupposedToGo
@onready var suprised_you_hit_me = $Unk/WowImSuprisedYouHitMe


"""Main game loop"""
func _ready(): #Everything that scene when game is loaded
	difficulty_panel.visible = true
	


func start_game():
	$backgroundMusic.play()
	play_opening_dialogue()
	for i in range(1000):
		await get_tree().process_frame
	$EyesOpeningAnim.play("default")
	play_unk_intro()
	await lets_play.finished
	health_sprite.visible = false
	health_sprite2.visible = false
	health_sprite3.visible = false
	opp_health_sprite1.visible = false
	opp_health_sprite2.visible = false
	opp_health_sprite3.visible = false
	timer_sprite.connect("animation_finished", _on_animation_finished)
	screen_size = get_viewport_rect().size
	load_card_art()
	create_deck()  # Initialize deck with proper rank and suit combinations
	deck.shuffle()
	await get_tree().create_timer(label_display_time).timeout
	introLabel.visible = false
	_display_health()
	_play_starting_animations()
	start_phase_1()

func set_difficulty(difficulty:String):
	match difficulty:
		"Easy":
			difficulty_panel.visible = false
			target_difficulty = easy_mode_speed
			arrow_difficulty = arrow_easy_mode_speed
			start_game()
		"Normal":
			difficulty_panel.visible = false
			target_difficulty = normal_mode_speed
			arrow_difficulty = arrow_normal_mode_speed
			start_game()
		"Hard":
			difficulty_panel.visible = false
			target_difficulty = hard_mode_speed
			arrow_difficulty = arrow_hard_mode_speed
			start_game()

func _on_easy_button_pressed() -> void:
	set_difficulty("Easy")

func _on_normal_button_pressed() -> void:
	set_difficulty("Normal")

func _on_hard_button_pressed() -> void:
	set_difficulty("Hard")

"""On startup functions"""
func create_deck(): #Creates Deck
	for suit in suits:
		for rank in range(2, 15):  # 2 to 14, where 11=Jack, 12=Queen, 13=King, 14=Ace
			deck.append([rank, suit])  # Each card is a pair [rank, suit]

func load_card_art(): # Create a dictionary to map cards to their respective images
	for rank in range(2, 15):
		for suit in suits:
			var card_name = "%s_of_%s.png" % [str(rank), suit]  # Use parentheses for format strings
			card_sprites["%s_of_%s" % [str(rank), suit]] = load("res://cards/%s" % card_name)

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

	get_tree().change_scene_to_file("res://title_screen.tscn")



"""Phase 1 Functions"""
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

func _switch_to_phase_1(): #Switches 'state' to phase 1
	#Switch turn
	is_player_turn = !is_player_turn
	phase_1_sprite_changes() #Changes visibility of sprites
	
	if is_player_turn:
		higherButton.visible = true
		lowerButton.visible = true
	else:
		unk_card_choice_outcome()


#CARD SECTION
func draw_card() -> Array: # Draw a card from the deck
	return deck.pop_back()  # Return a card as [rank, suit]

func display_card_art(): # Display the card art for both player and opponent
	# Set the player card art
	var player_card_texture = card_sprites["%s_of_%s" % [str(player_card), player_card_suit]]
	get_node("PlayerCardSprite").texture = player_card_texture

	# Set the opponent card art
	var opponent_card_texture = card_sprites["%s_of_%s" % [str(opponent_card), opponent_card_suit]]
	get_node("OpponentCardSprite").texture = opponent_card_texture

func new_player_guess(is_higher: bool): # Handle player's guess (higher or lower)
	if (is_higher and player_card > opponent_card) or (not is_higher and player_card < opponent_card):
		print("You guessed correctly!")
		$correctSound.play()
		$checkMark.show()
		$GreenRect.show()
		for i in range(100):
			await get_tree().process_frame
		$checkMark.hide()
		$GreenRect.hide()
		was_correct = true
		new_switch_to_phase_2()
		
	else:
		print("You were wrong")
		$incorrectSound.play()
		$xMark.show()
		$RedRect.show()
		for i in range(80):
			await get_tree().process_frame
		$xMark.hide()
		$RedRect.hide()
		was_correct = false
		new_switch_to_phase_2()
		

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
		was_correct = true
		new_switch_to_phase_2()
		
	else:
		print("UNK was wrong")
		$incorrectSound.play()
		$xMark.show()
		$RedRect.show()
		for i in range(80):
			await get_tree().process_frame
		$xMark.hide()
		$RedRect.hide()
		was_correct = false
		new_switch_to_phase_2()
		


#ANIMATION SECTION
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

func phase_1_sprite_changes(): #Sprite changes when changing back to phase 1
	#Make Phase 1 sprites visible
	deck_of_cards.visible = true
	opponent_card_sprite.visible = true
	player_card_sprite.visible = true


#BUTTON SECTION
func _on_higher_button_pressed(): #Handles HigherButton
	new_player_guess(true)

func _on_lower_button_pressed(): #Handles LowerButton
	new_player_guess(false)



"""Phase 2 Functions"""
func new_switch_to_phase_2():
	var poof_noise = get_node("poofSoundEffect")
	num_of_targets = floor(randf_range(5,10))

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


		new_start_phase_2()
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

		new_start_phase_2()
		
		
	first_switch = false	

func new_start_phase_2():
	if is_player_turn: #If it is the player's turn
		if was_correct: #Correct
			print("(CORRECT) Player must press targets")
			new_play_player_phase_2_animations() #Play player animations
			move_target()
		else: #Incorrect
			print("(INCORRECT)Play must dodge ")
			loop_arrows()
	else: #UNKS turn
		if was_correct: #Correct
			print("(CORRECT) Player must dodge")
			loop_arrows()
		else: #Incorrect
			print("(INCORRECT) Player must press targets")
			new_play_player_phase_2_animations() #Play Player animations
			move_target()


#TARGET SECTION
func move_target():
	num_of_targets_label.visible = true
	num_of_targets_label.text = "Targets left: " + str(num_of_targets)
	var speed = target_difficulty
	target.visible = true
	timer_sprite.visible = true
	var max_x = screen_size.x - target.get_size().x
	var max_y = screen_size.x - target.get_size().y
	var new_position = Vector2(randf() * (screen_size.x - max_x), randf() * (screen_size.y - max_y))
	target.position = new_position
	timer_sprite.set_speed_scale(speed)
	timer_sprite.play("default")
	if num_of_targets == 0:
		timer_sprite.stop()
		target.visible = false
		timer_sprite.visible = false
		num_of_targets_label.visible = false
		opp_lives -= 1
		_display_health()

		if _check_opp_lives(opp_lives):
			if opp_lives == 2:
				suprised_you_hit_me.play()
				await suprised_you_hit_me.finished
				that_has_not_happened.play()
				await that_has_not_happened.finished
				
			start_phase_1()
			_switch_to_phase_1()
		else:
			well_thats_not_how.play()
			await well_thats_not_how.finished
			_game_over()

func _on_animation_finished(): #Check to see if player missed click
	target.visible = false
	timer_sprite.visible = false
	num_of_targets_label.visible = false
	start_phase_1()
	_switch_to_phase_1()

func _on_target_pressed() -> void: #Check if target was clicked
	$Target/ClickSound.play()
	timer_sprite.stop()
	num_of_targets -= 1
	move_target()


#ARROW SECTION
func loop_arrows(): # Loops arrow falling from top of screen to bottom
	magic_ball_sprite.play("Appearing")
	await magic_ball_sprite.animation_finished
	magic_ball_sprite.play("IdleSpin")
	right_arrow_falling.visible = true
	left_arrow_falling.visible = true
	right_arrow_static.visible = true
	left_arrow_static.visible = true
	arrow_animation_finished = false
	num_of_arrows = floor(randf_range(5, 10))
	var num_of_arrows_holder = num_of_arrows
	#num_of_arrows_label.visible = true
	#num_of_arrows_label.text = "Arrows Left: " + str(num_of_arrows)
	for i in range(20):
		make_arrow_fall()
		
	# Introduce delay between each arrow's fall
		for x in range(150):
			await get_tree().process_frame
		
		if arrow_animation_finished:
			break
		elif num_of_arrows <= 0:
			break

	# Stop animations and switch phase after all arrows have fallen or player misses

	#num_of_arrows_label.visible = false
	right_arrow_falling_anim_player.stop()
	left_arrow_falling_anim_player.stop()
	left_arrow_falling.visible = false
	right_arrow_falling.visible = false
	right_arrow_static.visible = false
	left_arrow_static.visible = false
	print(num_of_arrows)
	if num_of_arrows !=0:
		play_unk_throw()
		await magic_ball_sprite.animation_finished
	magic_ball_sprite.set_frame_and_progress(0,0)
	magic_ball_anim_player.stop()
	if _check_player_lives(player_lives):
		if player_lives == 2:
			oops_are_you_okay.play()
			await oops_are_you_okay.finished
		
		start_phase_1()
		_switch_to_phase_1()
	else:
		i_thought_you_be_diff.play()
		await i_thought_you_be_diff.finished
		_game_over()

func make_arrow_fall(): #Decides which arrow should be falling
	if randf() > 0.5:
		right_arrow_falling_anim_player.set_speed_scale(arrow_difficulty)
		right_arrow_falling_anim_player.play("fall")
		
	else:
		left_arrow_falling_anim_player.set_speed_scale(arrow_difficulty)
		left_arrow_falling_anim_player.play("fall")

func _on_right_arrow_falling_anim_player_animation_finished(anim_name: StringName): #Check to see if arrow fell through
	if anim_name == "fall":
		#num_of_arrows_label.visible = false
		arrow_animation_finished = true
		right_arrow_falling_anim_player.stop()
		left_arrow_falling_anim_player.stop()
		left_arrow_falling.visible = false
		right_arrow_falling.visible = false
		right_arrow_static.visible = false
		left_arrow_static.visible = false
		player_lives -= 1


func _on_left_arrow_falling_anim_player_animation_finished(anim_name: StringName): #Check to see if arrow fell through
	if anim_name == "fall":
		#num_of_arrows_label.visible = false
		arrow_animation_finished = true
		right_arrow_falling_anim_player.stop()
		left_arrow_falling_anim_player.stop()
		left_arrow_falling.visible = false
		right_arrow_falling.visible = false
		right_arrow_static.visible = false
		left_arrow_static.visible = false
		player_lives -= 1


func _input(event): #Gets the input from the user
	if event.is_action_pressed("ui_right") and is_in_target_area("right"):
		$rightArrowStatic/arrowGet.play()
		num_of_arrows -= 1
		#num_of_arrows_label.text = "Arrows Left: " + str(num_of_arrows)
		handle_hit("right")
	elif event.is_action_pressed("ui_left") and is_in_target_area("left"):
		$rightArrowStatic/arrowGet.play()
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


#ANIMATION SECTION
func new_play_player_phase_2_animations(): #Does nothing right now, will put anims here later
	pass



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
		#life_loss_sound.play()
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
		#life_loss_sound.play()
		#blood_burst1.play("default")
		health_sprite.visible = false
		health_sprite2.visible = false
		health_sprite3.visible = false


	
	if opp_lives == 3:
		opp_health_sprite1.visible = true
		opp_health_sprite2.visible = true
		opp_health_sprite3.visible = true
	elif opp_lives == 2:
		#life_loss_sound.play()
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
		#life_loss_sound.play()
		#opp_blood_burst3.play("default")
		opp_health_sprite1.visible = false
		opp_health_sprite2.visible = false
		opp_health_sprite3.visible = false


	
	health_animation.play("pulse")
	opp_health_animation.play("pulse")	


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



"""Animation section"""
func play_unk_intro():
	magic_ball_sprite.play("IdleSpin")
	for i in range(1500):
		await get_tree().process_frame
	unk_sprite.play("SideIdleToLookAtPlayer")
	await unk_sprite.animation_finished
	magic_ball_sprite.play_backwards("Appearing")
	unk_sprite.play("TurnTowardsPlayer")
	await unk_sprite.animation_finished

func play_unk_throw():
	magic_ball_anim_player.play("throw")
	await magic_ball_anim_player.animation_finished
	_display_health()
	magic_ball_sprite.play_backwards("Appearing")
	
func play_opening_dialogue():
	what_did_I_do.play()
	await what_did_I_do.finished
	your_awake.play()
	await your_awake.finished
	who_are_you.play()
	await who_are_you.finished
	asking_about_me.play()
	await asking_about_me.finished
	wth_you_talk_about.play()
	await wth_you_talk_about.finished
	your_in_my_house.play()
	await your_in_my_house.finished
	what.play()
	await what.finished
	you_know_basement.play()
	await you_know_basement.finished
	fairly_sound_proof.play()
	await fairly_sound_proof.finished
	I_know_basement.play()
	await I_know_basement.finished
	here_to_play_game.play()
	await here_to_play_game.finished
	a_game.play()
	await a_game.finished
	a_game_of_life_or_death.play()
	await a_game_of_life_or_death.finished
	one_is_going_to_die.play()
	await one_is_going_to_die.finished
	what_you_mean_die.play()
	await what_you_mean_die.finished
	not_very_quick.play()
	await not_very_quick.finished
	no_I_dont_got_it.play()
	await no_I_dont_got_it.finished
	lets_play.play()
	await lets_play.finished

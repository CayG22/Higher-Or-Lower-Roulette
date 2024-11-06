extends Node2D


@onready var node = $"."
@onready var no_bullets = $zero_bullets
@onready var animation = $zero_bullets/AnimationPlayer
@onready var load_sound = $loadSound
@onready var load_fades = $ColorRect/fadePlayer
var bullet_arr = GameData.global_bullet_array


func _ready() -> void:
	print(bullet_arr)
	var timer = get_tree().create_timer(1.0)
	load_fades.play("fade_in")
	await timer.timeout
	display_bullet_sprites()

func display_bullet_sprites():
	var num_of_bullets = 0
	var bullet_positions = []
	var timer = get_tree().create_timer(1.0)
	for i in bullet_arr: #Get number of bullets
		if i == 1:
			num_of_bullets += 1
	for i in range(bullet_arr.size()): #Get bullet positions
		if bullet_arr[i] == 1:
			bullet_positions.append(i)
	
	if num_of_bullets == 1:
		var sprite = "Spot " + str(bullet_positions[0])
	elif num_of_bullets == 2:
		var sprite = "Spot " + str(bullet_positions[0]) + "_" + str(bullet_positions[1])
		await timer.timeout
		show_bullet_sprite(sprite)
	elif num_of_bullets == 3:
		var sprite = "Spot " + str(bullet_positions[0]) + "_" + str(bullet_positions[1]) + "_" + str(bullet_positions[2])
		await timer.timeout
		show_bullet_sprite(sprite)
	elif num_of_bullets == 4:
		var sprite = "Spot " + str(bullet_positions[0]) + "_" + str(bullet_positions[1]) + "_" + str(bullet_positions[2]) + "_" + str(bullet_positions[3])
		await timer.timeout
		show_bullet_sprite(sprite)

func show_bullet_sprite(spot: String):
	var timer = get_tree().create_timer(.1)
	var wait_timer = get_tree().create_timer(.5)
	var fade_out_timer = get_tree().create_timer(1.5)
	var bullet_sprite = node.get_node(spot)
	if bullet_sprite:
		animation.play("expand")
		load_sound.play()
		await timer.timeout
		no_bullets.visible = false
		bullet_sprite.visible = true
		await wait_timer.timeout
		load_fades.play("fade_out")
		await fade_out_timer.timeout
		_switch_scene()
	else:
		_switch_scene()

func _switch_scene():
	var new_scene = preload("res://node_2d.tscn")
	var scene_instance = new_scene.instantiate()
	
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(scene_instance)
	
	get_tree().current_scene = scene_instance
	get_tree().paused = false

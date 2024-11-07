extends Node2D
@onready var studio_name = $studioName
@onready var studio_name_anim_player = $studioName/studioNameAnimPlayer
@onready var game_made_by = $gameMadeBy
@onready var game_made_by_anim_player = $gameMadeBy/gameMadeByAnimPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var main_scene = preload("res://node_2d.tscn").instantiate()
	var how_to_play_scene = preload("res://howToPlay.tscn")
	start_animations()


func start_animations():
	studio_name_anim_player.play("in")
	await studio_name_anim_player.animation_finished
	studio_name_anim_player.play("out")
	await studio_name_anim_player.animation_finished
	game_made_by_anim_player.play("in")
	await game_made_by_anim_player.animation_finished
	game_made_by_anim_player.play("out")
	await game_made_by_anim_player.animation_finished
	get_tree().change_scene_to_file("res://title_screen.tscn")

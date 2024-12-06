extends Node2D
var deck = [] #LIST: deck of cards
var suits = ["hearts", "diamonds", "clubs", "spades"] #LIST: suits for cards
var card_sprites = {}  #DICTIONARY: holds the card images as textures
var player_card = 0 #INT: player card
var player_card_suit = "" #Don't use
var opponent_card = 0 #INT: UNK Card
var opponent_card_suit = "" #Don't use
var is_player_turn = true #BOOL: player turn or not

@onready var higherButton = $HigherButton
@onready var lowerButton = $lowerButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

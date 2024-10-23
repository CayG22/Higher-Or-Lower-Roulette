extends Control

#Variables to store settings
var master_volume = 1.0
var resolution_index = 0
var is_fullscreen = false

#Nodes for UI elements
@onready var volume_slider = $VBoxContainer/Volume/HSlider
@onready var resolution_dropdown = $VBoxContainer/Resolution/OptionButton
@onready var fullscreen_toggle = $VBoxContainer/Fullscreen/CheckBox
@onready var save_button = $SaveButton

#Resolutions available
var resolutions = [
	Vector2(1920,1080),
	Vector2(1280,720),
	Vector2(800,600),
	Vector2(1152,648)
]

func _ready():
	#Set initial UI values
	volume_slider.value = master_volume * 100
	resolution_dropdown.clear()
	for resolution in resolutions:
		resolution_dropdown.add_item(str(resolution.x) + "x" + str(resolution.y))
	resolution_dropdown.select(resolution_index)
	fullscreen_toggle.button_pressed = is_fullscreen
	
	save_button.connect("pressed", Callable(self,"on_save_button_pressed"))
	

func on_save_button_pressed():
	# Save the values from the UI
	master_volume = volume_slider.value / 100
	resolution_index = resolution_dropdown.selected
	is_fullscreen = fullscreen_toggle.button_pressed
	
	# Apply settings
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
	
	# Update resolution and fullscreen
	DisplayServer.window_set_size(resolutions[resolution_index])
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
	
	print("Settings saved!")
	get_tree().change_scene_to_file("res://title_screen.tscn")

extends Node

@export var main_menu_scene: PackedScene = preload("res://scenes/main_menu.tscn")
@export var lobby_scene: PackedScene = preload("res://scenes/lobby.tscn")
@export var game_scene: PackedScene = preload("res://scenes/game.tscn")

var current_screen

func _ready():
	# Assume we start with the main menu
	if main_menu_scene:
		current_screen = main_menu_scene.instantiate()
		add_child(current_screen)

func show_main_menu():
	if current_screen:
		current_screen.queue_free()
	current_screen = main_menu_scene.instantiate()
	add_child(current_screen)

func show_lobby():
	if current_screen:
		current_screen.queue_free()
	current_screen = lobby_scene.instantiate()
	add_child(current_screen)

func show_game():
	if current_screen:
		current_screen.queue_free()
	current_screen = game_scene.instantiate()
	add_child(current_screen)

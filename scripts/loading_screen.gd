extends Node2D
@onready var background_music: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready():
	# Plays the music when the node enters the scene tree
	background_music.play()
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		background_music.stop()
		get_tree().change_scene_to_file("res://scenes/level0.tscn")

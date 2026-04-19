extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("portal touched by: ", body.name)
	if body is CharacterBody2D:
		print("changing scene!")
		get_tree().change_scene_to_file("res://scenes/level2.tscn")

extends Area2D

signal activated

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("body entered: ", body.name)
	if body is CharacterBody2D:
		print("checkpoint activated!")
		activated.emit(global_position)

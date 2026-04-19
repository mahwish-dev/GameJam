extends Area2D

# We deleted the @onready variable because we don't need the exact path anymore!

func _on_body_entered(body: Node2D) -> void:
	# This tells Godot to find any node in the "score_label" group and call its "add_score" function
	get_tree().call_group("score_label", "add_score", 10)
	
	queue_free()

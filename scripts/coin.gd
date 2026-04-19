extends Area2D

@onready var scoreLabel: Label = $"../../Overlay/Score"


func _on_body_entered(body: Node2D) -> void:
	scoreLabel.add_score(10)
	queue_free()

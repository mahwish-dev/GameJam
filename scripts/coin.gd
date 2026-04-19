extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Add to the coin pocket!
		Global.coins += 10  # (Or whatever amount your coins give)
		
		get_tree().call_group("score_label", "update_text")
		queue_free()

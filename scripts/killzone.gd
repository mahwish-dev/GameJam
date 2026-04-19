extends Area2D

@onready var timer: Timer = $Timer
var player_ref = null

func _on_body_entered(body: Node2D) -> void:
	# Check if the object entering is the player!
	if body.is_in_group("player"):
		print("You died!")
		player_ref = body
		timer.start()

func _on_timer_timeout() -> void:
	if player_ref:
		player_ref.die()

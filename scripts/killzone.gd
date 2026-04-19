extends Area2D

@onready var timer: Timer = $Timer
var player_ref = null

func _on_body_entered(body: Node2D) -> void:
	print("You died!")
	player_ref = body
	Engine.time_scale = 0.5
	timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	if player_ref:
		player_ref.die()

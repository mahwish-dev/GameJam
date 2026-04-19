extends Node2D

var max_health = 100
var health = 100

func _ready() -> void:
	$HealthBarContainer/HealthBar.max_value = max_health
	$HealthBarContainer/HealthBar.value = health

func take_damage(amount: int) -> void:
	health -= amount
	health = clamp(health, 0, max_health)
	$HealthBarContainer/HealthBar.value = health
	print("Slime took ", amount, " damage! HP: ", health, "/", max_health)
	if health <= 0:
		die()

func die() -> void:
	print("Slime died!")
	queue_free()

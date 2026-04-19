extends TextureProgressBar


@onready var health_bar = $"../CanvasLayer/HealthBar"
var health = 100

func take_damage(amount):
	health -= amount
	health_bar.value = health

extends TextureProgressBar

var max_health = 100
var health = 100

func _ready():
	$HealthBarContainer/HealthBar.max_value = max_health
	$HealthBarContainer/HealthBar.value = health

func take_damage(amount: int):
	health -= amount
	health = clamp(health, 0, max_health)
	$HealthBarContainer/HealthBar.value = health
	if health <= 0:
		die()

func die():
	print("Slime died!")
	queue_free()

func _process():
	

extends CharacterBody2D

# Keep the pocket in case you still want him to drop chocolate when smashed!
@export var loot_scene: PackedScene 

var max_health = 100
var health = 100

func _ready() -> void:
	$HealthBarContainer/HealthBar.max_value = max_health
	$HealthBarContainer/HealthBar.value = health
	
	# Force the golem to just stand there breathing
	$AnimatedSprite2D.play("idle")

func _physics_process(delta: float) -> void:
	# Only apply gravity so he stands firmly on the floor. No walking!
	if not is_on_floor():
		velocity += get_gravity() * delta
		move_and_slide()

# I left the damage logic in so your player can still smash the cutscene actor!
func take_damage(amount: int) -> void:
	health -= amount
	health = clamp(health, 0, max_health)
	$HealthBarContainer/HealthBar.value = health
	print("Cutscene Golem took ", amount, " damage!")
	
	# Optional: You could play a "hurt" animation here if you have one!
	
	if health <= 0:
		die()

func die() -> void:
	print("Cutscene Golem goes to sleep!")
	
	if loot_scene != null:
		var loot = loot_scene.instantiate()
		loot.global_position = global_position
		get_parent().call_deferred("add_child", loot)
		
	queue_free()

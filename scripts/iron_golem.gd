extends Node2D

var max_health = 100
var health = 100

const DETECT_RADIUS = 5 * 32  # 5 tiles (assuming 32px per tile)
const ATTACK_RADIUS = 8       # 1 tile away to attack
const MOVE_SPEED = 40
const ATTACK_DAMAGE = 10
const ATTACK_COOLDOWN = 1.0    # seconds between attacks

var player_ref = null
var can_attack = true

func _ready() -> void:
	$HealthBarContainer/HealthBar.max_value = max_health
	$HealthBarContainer/HealthBar.value = health
	# Find player in scene
	player_ref = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	if player_ref == null:
		return

	var distance = global_position.distance_to(player_ref.global_position)

	if distance <= DETECT_RADIUS:
		# Chase player
		var direction = (player_ref.global_position - global_position).normalized()
		global_position += direction * MOVE_SPEED * delta

		# Flip sprite to face player
		$AnimatedSprite2D.flip_h = player_ref.global_position.x < global_position.x

		# Attack if close enough
		if distance <= ATTACK_RADIUS and can_attack:
			_attack()

func _attack() -> void:
	can_attack = false
	print("Golem attacks player!")
	player_ref.take_damage(ATTACK_DAMAGE)  # or player_ref.take_damage(ATTACK_DAMAGE) if player has that
	await get_tree().create_timer(ATTACK_COOLDOWN).timeout
	can_attack = true

func take_damage(amount: int) -> void:
	health -= amount
	health = clamp(health, 0, max_health)
	$HealthBarContainer/HealthBar.value = health
	print("Golem took ", amount, " damage! HP: ", health, "/", max_health)
	if health <= 0:
		die()

func die() -> void:
	print("Golem died!")
	queue_free()

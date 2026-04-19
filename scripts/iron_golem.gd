extends CharacterBody2D

var max_health = 100
var health = 100

const DETECT_RADIUS = 160  
const ATTACK_RADIUS = 15   
const MOVE_SPEED = 40
const ATTACK_DAMAGE = 20

# Your new timings!
const ATTACK_DURATION = 1.5  # How long the attack animation takes
const ATTACK_COOLDOWN = 2.0  # How long he waits before attacking again

var player_ref = null
var can_attack = true
var is_attacking = false     # This tells the golem to stop walking!

func _ready() -> void:
	$HealthBarContainer/HealthBar.max_value = max_health
	$HealthBarContainer/HealthBar.value = health
	player_ref = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if player_ref == null:
		return

	# If the golem is currently swinging its arms, STOP moving completely!
	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var distance = global_position.distance_to(player_ref.global_position)

	# 1. Are we close enough to attack?
	if distance <= ATTACK_RADIUS:
		# Stop walking! We are in range.
		velocity = Vector2.ZERO
		
		# Keep looking at the player even while standing still
		var direction_x = sign(player_ref.global_position.x - global_position.x)
		if direction_x != 0:
			$AnimatedSprite2D.flip_h = direction_x < 0
			
		move_and_slide()

		# Check if the cooldown is finished
		if can_attack:
			_attack()

	# 2. Not close enough to attack, but close enough to see them?
	elif distance <= DETECT_RADIUS:
		# Chase the player
		var direction = (player_ref.global_position - global_position).normalized()
		velocity = direction * MOVE_SPEED
		
		# Flip sprite to face player
		$AnimatedSprite2D.flip_h = direction.x < 0
		move_and_slide()

	# 3. Player is totally out of range
	else:
		velocity = Vector2.ZERO
		move_and_slide()
func _attack() -> void:
	can_attack = false
	is_attacking = true
	
	# 1. Play the animation! (Make sure it's spelled exactly like this in your AnimatedSprite2D)
	$AnimatedSprite2D.play("attack")
	print("Golem attacks player!")
	
	# 2. Deal the damage
	if player_ref.has_method("take_damage"):
		player_ref.take_damage(ATTACK_DAMAGE)  
		
	# 3. Wait 1.5 seconds for the attack animation to finish
	await get_tree().create_timer(ATTACK_DURATION).timeout
	
	# Stop attacking so he can move again
	is_attacking = false
	
	# 4. Wait 5 seconds for the cooldown before he can attack again
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
	print("Golem goes to sleep!")
	queue_free()

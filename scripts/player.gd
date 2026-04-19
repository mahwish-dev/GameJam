extends CharacterBody2D

const SPEED = 120.0
const JUMP_VELOCITY = -270.0

@onready var sprite = $AnimatedSprite2D
@onready var attack_hitbox = $AttackHitbox
@onready var health_bar = $HealthBarContainer/HealthBar

var attack_damage = 25
var is_attacking = false

var max_health = 100
var health = 100
var is_dead = false

const REGEN_DELAY = 3.0    # seconds after taking damage before regen starts
const REGEN_RATE = 5.0     # HP per second
var regen_timer = 0.0
var can_regen = false

func _ready():
	health_bar.max_value = max_health
	health_bar.value = health
	Global.checkpoint_position = global_position
	await get_tree().process_frame
	for checkpoint in get_tree().get_nodes_in_group("checkpoint"):
		checkpoint.activated.connect(_on_checkpoint)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Regen logic
	if not can_regen and regen_timer > 0:
		regen_timer -= delta
		if regen_timer <= 0:
			can_regen = true

	if can_regen and health < max_health:
		health += REGEN_RATE * delta
		health = clamp(health, 0, max_health)
		health_bar.value = health

	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("attack") and not is_attacking:
		_do_attack()

	var direction := Input.get_axis("move_left", "move_right")
	if is_on_floor():
		if direction != 0:
			velocity.x = direction * SPEED
			if not is_attacking:
				sprite.play("walk")
			sprite.flip_h = direction < 0
		else:
			velocity.x = 0
			if not is_attacking:
				sprite.play("idle")
	else:
		if not is_attacking:
			sprite.play("jump")

	move_and_slide()

func take_damage(amount: int) -> void:
	if is_dead:
		return
	health -= amount
	health = clamp(health, 0, max_health)
	health_bar.value = health
	# Reset regen timer on every hit
	can_regen = false
	regen_timer = REGEN_DELAY
	print("Player took ", amount, " damage! HP: ", health, "/", max_health)
	if health <= 0:
		die()

func _do_attack():
	is_attacking = true
	sprite.play("attack")
	
	# Look for CharacterBodies (like the Golem!) instead of Areas
	for body in attack_hitbox.get_overlapping_bodies():
		# Check if the body itself has the function, AND make sure the player doesn't hit themself!
		if body.has_method("take_damage") and body != self:
			body.take_damage(attack_damage)
			
	await sprite.animation_finished
	is_attacking = false

func _on_checkpoint(pos):
	Global.checkpoint_position = pos

func die():
	is_dead = true
	health = max_health
	health_bar.value = health
	can_regen = false
	regen_timer = 0.0
	global_position = Global.checkpoint_position
	is_dead = false

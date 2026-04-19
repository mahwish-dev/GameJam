extends CharacterBody2D

const SPEED = 120.0
const JUMP_VELOCITY = -270.0

@onready var sprite = $AnimatedSprite2D
@onready var attack_hitbox = $AttackHitbox  # Area2D child node

var attack_damage = 25
var is_attacking = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Attack input
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

func _do_attack():
	is_attacking = true
	sprite.play("attack")

	for area in attack_hitbox.get_overlapping_areas():
		print("Hello")
		var parent = area.get_parent()
		if parent.has_method("take_damage"):
			parent.take_damage(attack_damage)

	await sprite.animation_finished
	is_attacking = false
	
func _ready():
	Global.checkpoint_position = global_position
	await get_tree().process_frame
	var checkpoint = get_node_or_null("../CheckPoint")
	if checkpoint:
		checkpoint.activated.connect(_on_checkpoint)

func _on_checkpoint(pos):
	Global.checkpoint_position = pos

func die():
	global_position = Global.checkpoint_position

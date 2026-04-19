extends CharacterBody2D


const SPEED = 120.0
const JUMP_VELOCITY = -270.0
@onready var sprite = $AnimatedSprite2D

var attack_damage = 25
var is_attacking = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	
	# Animations
	if is_on_floor():
		if direction != 0:
			velocity.x = direction * SPEED
			sprite.play("walk")
			sprite.flip_h = direction < 0  # Flip when moving left
		else:
			velocity.x = 0
			sprite.play("idle")
	else:
		sprite.play("jump")

	move_and_slide()

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
	
#func _do_attack():
	#is_attacking = true
	#sprite.play("attack")
	#$AttackHitbox/CollisionShape2D.disabled = false
#
	## Deal damage to anything in hitbox right now
	#for body in attack_hitbox.get_overlapping_bodies():
		#if body.has_method("take_damage"):
			#body.take_damage(attack_damage)
#
	## Wait for animation to finish then reset
	#await sprite.animation_finished
	#$AttackHitbox/CollisionShape2D.disabled = true
	#is_attacking = false

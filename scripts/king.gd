extends CharacterBody2D

var health = 300
var has_landed = false
var jump_timer = 3.0

func _physics_process(delta):
	if !is_on_floor():
		velocity += get_gravity() * delta
	
	# Detect the moment he hits the floor for the first time
	if is_on_floor() and !has_landed:
		has_landed = true
		_impact_effect(35.0) # Massive shake on first drop

	# Boss AI: Jump toward player every 3 seconds
	jump_timer -= delta
	if jump_timer <= 0 and is_on_floor():
		_jump_attack()

	move_and_slide()

func _jump_attack():
	var p = get_tree().get_first_node_in_group("player")
	if p:
		velocity.y = -500
		velocity.x = sign(p.global_position.x - global_position.x) * 200
		jump_timer = 3.0
		# Wait until he lands to shake again
		await get_tree().create_timer(0.5).timeout 
		_impact_effect(20.0)

func _impact_effect(strength):
	var p = get_tree().get_first_node_in_group("player")
	if p: p.shake_strength = strength

func take_damage(amt):
	health -= amt
	if health <= 0: queue_free()

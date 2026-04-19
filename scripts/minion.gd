extends CharacterBody2D

@export var loot_scene: PackedScene # Drag chocolate_ingot.tscn here

var health = 50 # Lower health than golems so you can fight a crowd
const MOVE_SPEED = 70 # Faster than golems!

var player_ref = null

func _ready():
	player_ref = get_tree().get_first_node_in_group("player")
	$HealthBarContainer/HealthBar.max_value = health

func _physics_process(delta):
	if !player_ref: return
	
	# Apply gravity
	if !is_on_floor(): velocity += get_gravity() * delta
	
	# Chase player
	var dir = sign(player_ref.global_position.x - global_position.x)
	velocity.x = dir * MOVE_SPEED
	$AnimatedSprite2D.flip_h = dir < 0
	
	move_and_slide()

func take_damage(amt):
	health -= amt
	$HealthBarContainer/HealthBar.value = health
	if health <= 0:
		if loot_scene:
			var loot = loot_scene.instantiate()
			get_parent().add_child(loot)
			loot.global_position = global_position
		queue_free()

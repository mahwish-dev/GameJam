extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")

# Kids references
@onready var kid = $Kid
@onready var kid_2 = $Kid2
@onready var kid_3 = $Kid3

func _ready() -> void:
	# Hide kids initially
	kid.visible = false
	kid_2.visible = false
	kid_3.visible = false

	# Connect all triggers
	for trigger in get_tree().get_nodes_in_group("trigger"):
		trigger.triggered_signal.connect(_on_trigger)

func _on_trigger(trigger_id: String) -> void:
	print("hi")
	match trigger_id:
		"cutscene_1":
			await _mini_cutscene_1()

func _mini_cutscene_1() -> void:
	player.set_process(false)
	player.set_physics_process(false)

	# Show kids
	kid.visible = true
	kid_2.visible = true
	kid_3.visible = true

	await move_character(kid, Vector2(1440, kid.global_position.y), 1.5)
	move_character(kid_2, Vector2(1440, kid_2.global_position.y), 1.5)
	move_character(kid_3, Vector2(1440, kid_3.global_position.y), 1.5)
	
	await get_tree().create_timer(2).timeout

	move_character(player, Vector2(1440, player.global_position.y), 1.5)
	
	player.set_process(true)
	player.set_physics_process(true)
	
func move_character(character, target: Vector2, duration: float) -> void:
	var sprite = character.get_node("AnimatedSprite2D")
	# Flip and play walk animation based on direction
	var dir = target.x - character.global_position.x
	if abs(dir) > 1:
		sprite.play("walk")
		sprite.flip_h = dir < 0
	var tween = create_tween()
	tween.tween_property(character, "global_position", target, duration)
	await tween.finished
	# Play idle when done moving
	sprite.play("idle")

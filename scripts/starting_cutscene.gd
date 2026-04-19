extends Node

@onready var player = get_tree().get_first_node_in_group("player")
@onready var guide = get_tree().current_scene.get_node("Guide")
@onready var camera = player.get_node("Camera2D")
@onready var kid: CharacterBody2D = $Kid
@onready var kid_2: CharacterBody2D = $Kid2
@onready var kid_3: CharacterBody2D = $Kid3
@onready var kid_4: CharacterBody2D = $Kid4

var is_playing = false

func _ready() -> void:
	await get_tree().process_frame
	play_cutscene()

func play_cutscene() -> void:
	is_playing = true
	player.set_process(false)
	player.set_physics_process(false)
	guide.set_process(false)
	guide.set_physics_process(false)
	player.get_node("HealthBarContainer").hide()

	await get_tree().create_timer(10).timeout
	guide.get_node("AnimatedSprite2D").play("idle")
	player.get_node("AnimatedSprite2D").play("idle")
	
	# Guide and player walk to spot
	move_character(guide, Vector2(350, guide.global_position.y), 3.0)
	await move_character(player, Vector2(320, player.global_position.y), 3.0)

	# Brief pause before kids run
	await get_tree().create_timer(0.3).timeout

	# Player and guide stop and watch
	guide.get_node("AnimatedSprite2D").play("idle")
	player.get_node("AnimatedSprite2D").play("idle")

	# Kids run across staggered — run far to the right off screen
	var far_left = player.global_position.x - 500
	move_character(kid, Vector2(far_left, kid.global_position.y), 4.0)
	await get_tree().create_timer(0.2).timeout
	move_character(kid_2, Vector2(far_left, kid_2.global_position.y), 4.0)
	await get_tree().create_timer(0.2).timeout
	move_character(kid_3, Vector2(far_left, kid_3.global_position.y), 4.0)
	await get_tree().create_timer(0.2).timeout
	await move_character(kid_4, Vector2(far_left, kid_4.global_position.y), 4.0)
	
	# Brief pause after kids pass
	await get_tree().create_timer(0.5).timeout

	# Continue walking
	move_character(guide, Vector2(720, guide.global_position.y), 7.5)
	await move_character(player, Vector2(700, player.global_position.y), 7.5)

	# Done
	player.set_process(true)
	player.set_physics_process(true)
	guide.set_process(true)
	guide.set_physics_process(true)
	player.get_node("HealthBarContainer").show()
	is_playing = false
	
func move_character(character, target: Vector2, duration: float) -> void:
	var sprite = character.get_node("AnimatedSprite2D")
	var dir = target.x - character.global_position.x
	if abs(dir) > 1:
		sprite.play("walk")
		sprite.flip_h = dir < 0
	var tween = create_tween()
	tween.tween_property(character, "global_position", target, duration)
	await tween.finished
	sprite.play("idle")

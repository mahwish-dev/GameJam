extends Node

@onready var player = get_tree().get_first_node_in_group("player")
@onready var guide = get_tree().current_scene.get_node("Guide")
@onready var camera = player.get_node("Camera2D")
@onready var kid: CharacterBody2D = $Kid
@onready var kid_2: CharacterBody2D = $Kid2
@onready var kid_3: CharacterBody2D = $Kid3
@onready var kid_4: CharacterBody2D = $Kid4
@onready var music: AudioStreamPlayer2D = $AudioStreamPlayer2D

var is_playing = false

@onready var dialogue_box = get_tree().current_scene.get_node("Overlay/DialogueBox")

func _ready() -> void:
	await get_tree().process_frame
	music.play()
	play_cutscene()

func say(speaker: String, text: String) -> void:
	dialogue_box.show()
	dialogue_box.get_node("Panel/Label").text = speaker
	await dialogue_box.display_line(text)
	await _wait_for_input()
	dialogue_box.hide()

func _wait_for_input() -> void:
	if dialogue_box.is_typing:
		while not Input.is_action_just_pressed("skip typing"):
			await get_tree().process_frame
		dialogue_box.skip_typing()
		await get_tree().process_frame
		return
	var timer = get_tree().create_timer(5.0)
	while not Input.is_action_just_pressed("skip typing"):
		if timer.time_left <= 0:
			break
		await get_tree().process_frame

func play_cutscene() -> void:
	is_playing = true
	player.set_process(false)
	player.set_physics_process(false)
	guide.set_process(false)
	guide.set_physics_process(false)
	player.is_dead = true
	player.get_node("HealthBarContainer").hide()

	# Player wakes up/spawns — brief pause
	await get_tree().create_timer(1.5).timeout
	player.get_node("AnimatedSprite2D").play("idle")
	guide.get_node("AnimatedSprite2D").play("idle")

	# Guide walks toward player
	await move_character(guide, Vector2(player.global_position.x + 60, guide.global_position.y), 2.0)

	# Guide: "Well, hello there, traveler!"
	await say("Guide", "Well, hello there, traveler!")

	# Player looks around confused
	await get_tree().create_timer(0.5).timeout

	# Player: "Wait, where am I?"
	await say("Player", "Wait, where am I? How did I even get here?")

	# Guide gestures grandly
	await get_tree().create_timer(0.3).timeout

	# Guide: "Welcome to Sugarcube Pastures!"
	await say("Guide", "Welcome to Sugarcube Pastures!")

	# Player confused pause
	await get_tree().create_timer(0.5).timeout

	# Player: "...Sugarcube Pastures?"
	await say("Player", "...Sugarcube Pastures?")

	# Guide steps forward enthusiastically
	await move_character(guide, Vector2(guide.global_position.x + 30, guide.global_position.y), 0.5)

	# Guide: "A utopia for all candyfolk!..."
	await say("Guide", "A utopia for all candyfolk! Ruled by the magnificent King Cane. You look a bit dazed, let me show you around.")

	# Guide starts walking, player follows
	await get_tree().create_timer(0.5).timeout
	move_character(guide, Vector2(350, guide.global_position.y), 3.0)
	await move_character(player, Vector2(320, player.global_position.y), 3.0)
#
	## Brief pause before kids run
	#await get_tree().create_timer(0.3).timeout
	#guide.get_node("AnimatedSprite2D").play("idle")
	#player.get_node("AnimatedSprite2D").play("idle")
#
	## Kids run across staggered
	#var far_left = player.global_position.x - 500
	#move_character(kid, Vector2(far_left, kid.global_position.y), 4.0)
	#await get_tree().create_timer(0.2).timeout
	#move_character(kid_2, Vector2(far_left, kid_2.global_position.y), 4.0)
	#await get_tree().create_timer(0.2).timeout
	#move_character(kid_3, Vector2(far_left, kid_3.global_position.y), 4.0)
	#await get_tree().create_timer(0.2).timeout
	#await move_character(kid_4, Vector2(far_left, kid_4.global_position.y), 4.0)
#
	## Brief pause after kids pass
	#await get_tree().create_timer(0.5).timeout

	# Continue walking
	move_character(guide, Vector2(720, guide.global_position.y), 7.5)
	await move_character(player, Vector2(700, player.global_position.y), 7.5)

	# Done
	player.is_dead = false
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

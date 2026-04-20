extends Node

@onready var player = get_tree().get_first_node_in_group("player")
@onready var kid: CharacterBody2D = $Kid
@onready var kid_2: CharacterBody2D = $Kid2
@onready var kid_3: CharacterBody2D = $Kid3
@onready var music: AudioStreamPlayer2D = $AudioStreamPlayer2D

var is_playing = false

@onready var dialogue_box = get_tree().current_scene.get_node("Overlay/DialogueBox")

func _ready() -> void:
	await get_tree().process_frame

	# Connect trigger
	for trigger in get_tree().get_nodes_in_group("trigger"):
		trigger.triggered_signal.connect(_on_trigger)
	music.play()
	play_cutscene()

func _on_trigger(trigger_id: String) -> void:
	if trigger_id == "kids_scatter":
		
		await _kids_scatter()

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
	player.is_dead = true
	player.get_node("HealthBarContainer").hide()

	await get_tree().create_timer(1.0).timeout
	player.get_node("AnimatedSprite2D").play("idle")

	# Guide voiceover tutorial tip
	await say("Guide", "Press A and D (or Arrow Keys) to move, and Spacebar to jump. Collect coins to help King [King Name] bring prosperity to [Realm Name]!")

	# Hand control back — player can now move freely until they hit the trigger
	player.is_dead = false
	player.set_process(true)
	player.set_physics_process(true)
	player.get_node("HealthBarContainer").show()
	is_playing = false

func _kids_scatter() -> void:
	player.set_process(false)
	player.set_physics_process(false)
	player.is_dead = true


	# Player animation to idle
	
	var sprite = player.get_node("AnimatedSprite2D")
	sprite.play("idle")
	# Kids run off in different directions
	var far_right = player.global_position.x + 500
	var far_left = player.global_position.x - 500
	move_character(kid, Vector2(far_right, kid.global_position.y), 3)
	await get_tree().create_timer(0.15).timeout
	move_character(kid_2, Vector2(far_right, kid_2.global_position.y), 3)
	await get_tree().create_timer(0.15).timeout
	move_character(kid_3, Vector2(far_left, kid_3.global_position.y), 3)

	await get_tree().create_timer(0.3).timeout

	await say("Player", "Hey, wait! Why did they run off like that?")
	await say("Guide", "Ugh, little pests... Let's keep moving.")

	player.is_dead = false
	player.set_process(true)
	player.set_physics_process(true)
	player.get_node("HealthBarContainer").show()

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

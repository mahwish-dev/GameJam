extends Node

@onready var player = get_tree().get_first_node_in_group("player")
@onready var camera = player.get_node("Camera2D")
@onready var dialogue_box = get_tree().current_scene.get_node("Overlay/DialogueBox")
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var is_playing = false

func _ready() -> void:
	await get_tree().process_frame
	audio_stream_player_2d.play()
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
	# Assuming your player script uses the 'is_dead' property to prevent other inputs
	if "is_dead" in player:
		player.is_dead = true 
	player.get_node("HealthBarContainer").hide()

	# Move the player into position
	await move_character(player, Vector2(119, 60), 1.5)
	
	# Old Man Dialogue Sequence
	await say("Old Man", "Ah... so you're the one they wrangled this time.")
	
	await get_tree().create_timer(0.3).timeout
	
	await say("Player", "'This time'? What does that mean?")
	
	await get_tree().create_timer(0.3).timeout
	
	await say("Old Man", "Never mind. (Sniffs the air) I smell chocolate. Been\nslaughtering those poor golems, have you?")
	
	await get_tree().create_timer(0.3).timeout
	
	await say("Player", "Slaughtering?! No, I'm just putting them to sleep!")
	
	await get_tree().create_timer(0.3).timeout
	
	await say("Old Man", "Is that what they told you? Ignorance is bliss, I suppose.")

	await get_tree().create_timer(0.3).timeout
	
	await say("Player", "Hey, what aren't you telling me?")

	await get_tree().create_timer(0.3).timeout
	
	await say("Old Man", "Nothing. Just... don't ask too many questions, kid.\nKeep your head down and stay safe.")

	await get_tree().create_timer(0.3).timeout
	
	await say("Player", "Safe from what?")

	await get_tree().create_timer(0.3).timeout
	
	await say("Old Man", "I said, don't ask questions.")

	# End Cutscene
	if "is_dead" in player:
		player.is_dead = false
	player.set_process(true)
	player.set_physics_process(true)
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

extends Node

@onready var player = get_tree().get_first_node_in_group("player")
@onready var camera = player.get_node("Camera2D")
@onready var dialogue_box = get_tree().current_scene.get_node("Overlay/DialogueBox")
@onready var music: AudioStreamPlayer2D = $AudioStreamPlayer2D

var is_playing = false

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
	# Assuming your player script uses the 'is_dead' property to prevent other inputs like in the target script
	if "is_dead" in player:
		player.is_dead = true 
	player.get_node("HealthBarContainer").hide()

	# Move the player into position
	await move_character(player, Vector2(119, 60), 1.5)
	
	# Candy Grandma Dialogue Sequence
	await say("Candy Grandma", "Oh, hello dear! Word travels fast, I've already\nheard about your adventures.")
	
	await get_tree().create_timer(0.3).timeout
	
	await say("Candy Grandma", "We are just so thankful you're here helping our\nkind and fair King [King Name].")
	
	await get_tree().create_timer(0.3).timeout
	
	await say("Candy Grandma", "He works so hard to bring happiness and\nfreedom to [Realm Name].")
	
	await get_tree().create_timer(0.3).timeout
	
	await say("Candy Grandma", "It must be an awfully heavy burden for him, running this whole utopia\nall by himself. I'm glad he has a spry young helper like you!")

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

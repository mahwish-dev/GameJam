extends Node

@onready var player = get_tree().get_first_node_in_group("player")
@onready var guide = get_tree().current_scene.get_node("Guide")
@onready var golem = get_tree().current_scene.get_node("IronGolem")
@onready var camera = player.get_node("Camera2D")
@onready var kid: CharacterBody2D = $Kid
@onready var kid_2: CharacterBody2D = $Kid2
@onready var kid_3: CharacterBody2D = $Kid3
@onready var kid_4: CharacterBody2D = $Kid4
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var is_playing = false

@onready var dialogue_box = get_tree().current_scene.get_node("Overlay/DialogueBox")

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
	var timer = get_tree().create_timer(5.0)
	while not Input.is_action_just_pressed("skip typing"):
		if timer.time_left <= 0:
			break
		await get_tree().process_frame

func run_kids() -> void:
	# Kids run across from right to left staggered
	var far_left = player.global_position.x - 500
	move_character(kid, Vector2(far_left, kid.global_position.y), 1.5)
	await get_tree().create_timer(0.2).timeout
	move_character(kid_2, Vector2(far_left, kid_2.global_position.y), 1.5)
	await get_tree().create_timer(0.2).timeout
	move_character(kid_3, Vector2(far_left, kid_3.global_position.y), 1.5)
	
func play_cutscene() -> void:
	is_playing = true
	player.set_process(false)
	player.set_physics_process(false)
	player.get_node("HealthBarContainer").hide()
	golem.get_node("HealthBarContainer").hide()

	# Enter the scene — player walks in
	await get_tree().create_timer(1.0).timeout
	await move_character(player, Vector2(320, player.global_position.y), 3.0)
	await move_character(guide, Vector2(300, guide.global_position.y), 3.0)

	# Player looks around, stops
	await get_tree().create_timer(0.5).timeout
	player.get_node("AnimatedSprite2D").play("idle")

	# Player: "Whoa... what is this place?"
	await say('Player', '"Whoa... what is this place?"')

	# Guide: "It\'s nothing. Just ruins. We need to leave. Now."
	await say('Guide', '"It\'s nothing. Just ruins. We need to leave. Now."')

	# Player looks further, steps forward
	move_character(player, Vector2(360, player.global_position.y), 2.0)
	await move_character(guide, Vector2(340, guide.global_position.y), 3.0)

	# Kids run across while player observes
	player.get_node("AnimatedSprite2D").play("idle")
	await run_kids()
	await get_tree().create_timer(0.3).timeout

	# Player: "No, look! The people down here..."
	await say('Player', '"No, look! The people down here... they look exactly like you. And the golems aren\'t attacking anyone. They\'re actually helping them."')

	# Guide: "Listen to me, kid..."
	await say('Guide', '"Listen to me, kid, we cannot be down here!"')

	# Player turns away, steps forward defiantly
	move_character(player, Vector2(390, player.global_position.y), 1.0)
	await move_character(guide, Vector2(370, guide.global_position.y), 1.0)
	player.get_node("AnimatedSprite2D").flip_h = false

	# Player: "I\'m not going anywhere..."
	await say('Player', '"I\'m not going anywhere until you tell me what\'s really going on."')

	# Guide sighs, pauses
	await say('Guide', '*sigh....*')

	# Guide: "(Sighs heavily)..."
	await say('Guide', '"(Sighs heavily) You really shouldn\'t have dug into this..."')

	# Guide long exposition
	await say('Guide', '"The truth is, Sugarcube Pastures is no utopia."')
	await say('Guide', '"King Cane came to power by enslaving my people."')
	await say('Guide', '"He exploits our labor to feed his own kind on the surface."')
	await say('Guide', '"And those golems? They aren\'t monsters."')
	await say('Guide', '"They\'ve been the protectors of our underground tribe for centuries."')
	await say('Guide', '"Now, they\'re hunted down just to harvest their chocolate."')
	# Player steps back shocked
	move_character(player, Vector2(350, player.global_position.y), 0.8)
	await move_character(guide, Vector2(330, guide.global_position.y), 1.0)
	player.get_node("AnimatedSprite2D").flip_h = true

	# Player: "That\'s awful..."
	await say('Player', '"That\'s awful... But if you know all this, why are you helping him? Why are you tricking people like me into doing his dirty work?"')

	# Guide looks down, pause
	await get_tree().create_timer(1.0).timeout

	# Guide: "Because every time..."
	await say('Guide', '"Because every time a visitor stumbles into our world, I am forced to recruit them. If I don\'t do his bidding... King Cane will melt my family down."')

	# Guide: "I am so sorry..."
	await say('Guide', '"I am so sorry, kid. I really didn\'t want it to come to this."')

	# Player steps back alarmed
	move_character(player, Vector2(330, player.global_position.y), 0.5)
	await move_character(guide, Vector2(300, guide.global_position.y), 1.0)
	player.get_node("AnimatedSprite2D").flip_h = true

	# Player: "You don\'t have to do this!"
	await say('Player', '"You don\'t have to do this!"')

	# Guide final line
	await say('Guide', '"You\'ve seen too much. And I cannot risk my family."')

	# Brief pause at end
	await get_tree().create_timer(1.0).timeout

	# Done
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

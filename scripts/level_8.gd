extends Node
@onready var player = get_tree().get_first_node_in_group("player")
@onready var kid: CharacterBody2D = $Kid
@onready var kid_2: CharacterBody2D = $Kid2
@onready var kid_3: CharacterBody2D = $Kid3
var is_playing = false
@onready var dialogue_box = get_tree().current_scene.get_node("Overlay/DialogueBox")

func _ready() -> void:
	await get_tree().process_frame
	kid.visible = false
	kid_2.visible = false
	kid_3.visible = false
	for trigger in get_tree().get_nodes_in_group("trigger"):
		trigger.triggered_signal.connect(_on_trigger)

func _on_trigger(trigger_id: String) -> void:
	match trigger_id:
		"cutscene_1":
			await _cutscene_1()

func say(speaker: String, text: String) -> void:
	dialogue_box.show()
	dialogue_box.get_node("Panel/Label").text = speaker
	await dialogue_box.display_line(text)
	#await _wait_for_input()
	dialogue_box.hide()

#func _wait_for_input() -> void:
	#if dialogue_box.is_typing:
		#while not Input.is_action_just_pressed("skip typing"):
			#await get_tree().process_frame
		#dialogue_box.skip_typing()
		#await get_tree().process_frame
		#return
	#var timer = get_tree().create_timer(5.0)
	#while not Input.is_action_just_pressed("skip typing"):
		#if timer.time_left <= 0:
			#break
		#await get_tree().process_frame

func _cutscene_1() -> void:
	if is_playing:
		return
	is_playing = true
	player.set_process(false)
	player.set_physics_process(false)
	player.is_dead = true
	player.get_node("AnimatedSprite2D").play("idle")
	player.get_node("HealthBarContainer").hide()

	# Opening dialogue
	await say("Player", "That old man was saying some really strange things back there...")
	await say("Guide", "His mind is just going sour in his old age. We should visit that nice lady again.")
	await say("Player", "Actually, that makes me wonder... how come everyone here looks different from you? Where are the rest of the adults from your species?")
	await say("Guide", "Oh, we're, uh... a very solitary people. Yes. Very private.")

	# Kids dart across the screen
	await get_tree().create_timer(0.5).timeout
	kid.visible = true
	kid_2.visible = true
	kid_3.visible = true

	# Kids run across and into the hidden passage
	move_character(kid, Vector2(1440, kid.global_position.y), 2.5)
	await get_tree().create_timer(0.15).timeout
	move_character(kid_2, Vector2(1440, kid_2.global_position.y), 2.5)
	await get_tree().create_timer(0.15).timeout
	move_character(kid_3, Vector2(1440, kid_3.global_position.y), 2.5)
	await get_tree().create_timer(0.5).timeout

	await say("Guide", "Ugh, those brats again!")

	# Player follows kids toward passage
	await get_tree().create_timer(0.3).timeout
	move_character(player, Vector2(1440, player.global_position.y), 2.0)

	await say("Guide", "Wait! Where are you going?! We aren't supposed to go down there!")

	# Hand control back
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

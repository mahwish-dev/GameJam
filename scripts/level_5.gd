extends Node
@onready var player = get_tree().get_first_node_in_group("player")
var is_playing = false
@onready var dialogue_box = get_tree().current_scene.get_node("Overlay/DialogueBox")

func _ready() -> void:
	await get_tree().process_frame
	
	for trigger in get_tree().get_nodes_in_group("trigger"):
		trigger.triggered_signal.connect(_on_trigger)
		
		
	await play_cutscene()

func _on_trigger(trigger_id: String) -> void:
	match trigger_id:
		"before portal":
			await _golem_defeated()

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
	if is_playing:
		return
	is_playing = true
	player.set_process(false)
	player.set_physics_process(false)
	player.is_dead = true
	player.get_node("HealthBarContainer").hide()
	await get_tree().create_timer(1.0).timeout
	player.get_node("AnimatedSprite2D").play("idle")

	await say("Guide", "Careful now! That's a hostile golem. They're violent menaces to all candyfolk. Jump and attack it to deplete its health, that'll put it right to sleep.")

	player.is_dead = false
	player.set_process(true)
	player.set_physics_process(true)
	player.get_node("HealthBarContainer").show()
	is_playing = false

func _golem_defeated() -> void:
	is_playing = true
	player.set_process(false)
	player.set_physics_process(false)
	player.is_dead = true
	player.get_node("AnimatedSprite2D").play("idle")
	player.get_node("HealthBarContainer").hide()

	await say("Player", "Uh... that didn't really look like it's 'sleeping'. It looks dead.")
	await say("Guide", "Ah, it's just taking a very deep nap. Oh, it dropped chocolate! King [King Name] highly rewards those who bring him chocolate!")

	player.is_dead = false
	player.set_process(true)
	player.set_physics_process(true)
	player.get_node("HealthBarContainer").show()
	is_playing = false

extends Node

@export var dialogue_lines: Array[String] = [
	"Welcome to the level!",
	"Watch out for the Iron Golem!",
	"Good luck..."
]

@onready var player = get_tree().get_first_node_in_group("player")
@onready var dialogue_box = get_node_or_null("Overlay/DialogueBox")
@onready var camera = get_node("../Player/Camera2D")

var is_playing = false

func _ready() -> void:
	await get_tree().process_frame
	play_cutscene()

func play_cutscene() -> void:
	is_playing = true
	player.set_process(false)
	player.set_physics_process(false)
	player.get_node("HealthBarContainer").hide()

	await move_character(player, Vector2(119, 60), 1.5)
	
	for line in dialogue_lines:
		await show_dialogue(line)

	player.set_process(true)
	player.set_physics_process(true)
	player.get_node("HealthBarContainer").show()
	is_playing = false

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

func show_dialogue(text: String) -> void:
	dialogue_box.show()
	dialogue_box.get_node("Panel/Label").text = text
	await get_tree().create_timer(0.1).timeout
	await wait_for_input()
	dialogue_box.hide()

func wait_for_input() -> void:
	while not Input.is_action_just_pressed("ui_accept"):
		await get_tree().process_frame

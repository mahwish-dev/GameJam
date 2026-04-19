extends Area2D

@export var dialogue_lines: Array[String] = [
	"This is a trigger dialogue!",
	"It only shows once."
]

var triggered = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("body entered trigger: ", body.name)
	if triggered:
		return
	if body.is_in_group("player"):
		triggered = true
		var dialogue_box = get_tree().current_scene.get_node("Overlay/DialogueBox")
		_show_dialogue(dialogue_box)

func _show_dialogue(dialogue_box) -> void:
	for line in dialogue_lines:
		dialogue_box.show()
		dialogue_box.get_node("Panel/Label").text = line
		await get_tree().create_timer(0.1).timeout
		await _wait_for_input()
	dialogue_box.hide()

func _wait_for_input() -> void:
	while not Input.is_action_just_pressed("ui_accept"):
		await get_tree().process_frame

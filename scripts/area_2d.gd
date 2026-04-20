extends Area2D

signal triggered_signal(id: String)

@export var dialogue_lines: Array[String] = [
	"This is a trigger dialogue!",
]
@export var trigger_id: String = "cutscene_1"

var triggered = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("body entered trigger: ", body.name)
	if triggered:
		return
	if body.is_in_group("player"):
		triggered = true
		if dialogue_lines.size() > 0:
			var dialogue_box = get_tree().current_scene.get_node("Overlay/DialogueBox")
			_show_dialogue(dialogue_box)
		triggered_signal.emit(trigger_id)

func _show_dialogue(dialogue_box) -> void:
	for line in dialogue_lines:
		dialogue_box.show()
		dialogue_box.get_node("Panel/RichTextLabel").text = line
		await get_tree().create_timer(0.1).timeout
		await _wait_for_input()
	dialogue_box.hide()

func _wait_for_input() -> void:
	var timer = get_tree().create_timer(3.0)
	while not Input.is_action_just_pressed("skip typing"):
		if timer.time_left <= 0:
			break
		await get_tree().process_frame

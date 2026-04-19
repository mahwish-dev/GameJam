extends Control

@onready var text_label: RichTextLabel = $Panel/RichTextLabel

var dialogue_lines = ["Hello there! (Press Shift to go to next dialogue)", "Press A/<- to move left", "Press D/-> to move right"]
var current_line = 0
var is_typing = false

func _ready():
	display_line(current_line)

# typing animation
func display_line(index: int):
	text_label.text = ""
	is_typing = true
	for char in dialogue_lines[index]:
		if is_typing:
			text_label.text += char
			await get_tree().create_timer(0.05).timeout
	is_typing = false

func _input(event):
	if event.is_action_pressed("skip typing"):
		if is_typing:
			text_label.text = dialogue_lines[current_line]
			is_typing = false
		else:
			current_line += 1
			if current_line < dialogue_lines.size():
				display_line(current_line)
			else:
				visible = false

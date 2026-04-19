extends Control

@onready var text_label: RichTextLabel = $Panel/TextLabel
@onready var name_label: Label = $Panel/NameLabel

var dialogue_lines = [
	{"speaker": "Alice", "text": "Hello there!"},
	{"speaker": "Bob",   "text": "Hi! How are you?"},
]
var current_line = 0
var is_typing = false

func show_dialogue():
	visible = true
	display_line(current_line)

func display_line(index: int):
	var line = dialogue_lines[index]
	name_label.text = line["speaker"]
	text_label.text = ""
	is_typing = true
	# Typewriter effect
	for char in line["text"]:
		text_label.text += char
		await get_tree().create_timer(0.05).timeout
	is_typing = false

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if is_typing:
			# Skip to full text
			text_label.text = dialogue_lines[current_line]["text"]
			is_typing = false
		else:
			current_line += 1
			if current_line < dialogue_lines.size():
				display_line(current_line)
			else:
				visible = false  # End dialogue
				current_line = 0

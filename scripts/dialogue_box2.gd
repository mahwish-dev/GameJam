extends Control

@onready var text_label: RichTextLabel = $Panel/RichTextLabel

var is_typing = false

# typing animation
func display_line(str: String):
	text_label.text = ""
	is_typing = true
	for char in str:
		if is_typing:
			text_label.text += char
			await get_tree().create_timer(0.05).timeout
	is_typing = false
	

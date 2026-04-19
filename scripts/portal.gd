extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Move the print statement inside so the console doesn't get spammed by the floor/enemies
	if body.is_in_group("player"):
		print("portal touched by: ", body.name)
		print("changing scene!")
		
		var next_scene = _get_next_scene()
		
		if next_scene != "":
			get_tree().change_scene_to_file(next_scene)
		else:
			print("No next scene found!")

func _get_next_scene() -> String:
	var current_scene = get_tree().current_scene.scene_file_path
	# Extract the level number using regex
	var regex = RegEx.new()
	regex.compile("(\\D*)(\\d+)(.*\\.tscn)")
	var result = regex.search(current_scene)
	if result:
		var prefix = result.get_string(1)   # e.g. "res://scenes/level"
		var number = result.get_string(2).to_int()  # e.g. 2
		var suffix = result.get_string(3)   # e.g. ".tscn"
		return prefix + str(number + 1) + suffix
	return ""

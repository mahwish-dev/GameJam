extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# THIS IS THE TEST: It will print the name of absolutely anything that touches it
	print("SOMETHING TOUCHED THE INGOT: ", body.name)
	
	if body.is_in_group("player"):
		print("Got chocolate!")
		Global.ingots += 1
		get_tree().call_group("score_label", "update_text")
		queue_free()

extends Label

func _ready() -> void:
	update_text()

# Both the coin and the ingot will call this same function when collected!
func update_text() -> void:
	# This puts them side-by-side! (e.g., "Coins: 10  |  Chocolate: 2")
	text = "Coins: " + str(Global.coins) + "  |  Chocolate: " + str(Global.ingots)

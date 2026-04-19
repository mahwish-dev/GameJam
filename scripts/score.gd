extends Label

var score = 0

func add_score(amount):
	score += amount
	text = "No of Candies collected: " + str(score)

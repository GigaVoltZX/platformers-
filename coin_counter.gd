extends Control
class_name Coin_Counter
var coins = 0
func add_coins(amount):
	coins += amount
	$Label.text = str(coins)

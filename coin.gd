extends Area2D

@export var coin_counter: Coin_Counter
@export var value = 1
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		coin_counter.add_coins(value)
		queue_free()

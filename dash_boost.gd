extends Area2D


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword"):
		Engine.time_scale = 0.25
		$Timer.start()
		var player = area.get_parent()
		player.state = player.Dash
		player.get_node("DASHTIMER").start(0.2)
		var x = Input.get_axis("Left","Right")
		var y = Input.get_axis("up","down")
		player.Dash_dir = Vector2(x,y).normalized()


func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	$Timer.stop()

extends AnimatedSprite2D

@onready var animated_sprite_2d: AnimatedSprite2D = $"../AnimatedSprite2D"

func _ready() -> void:
	#visible = false
	pass
func _on_frame_changed() -> void:
	print(animated_sprite_2d.frame)
	if animated_sprite_2d.animation == "fire breath":
		if animated_sprite_2d.frame == 8:
			visible = true
			$fire/CollisionShape2D.disabled = false
			print("playing default")
			set_frame_and_progress(0, 0)
			play("default")
	

func _on_animated_sprite_2d_animation_finished() -> void:
	visible = false
	
	
func _process(delta: float) -> void:
	if animated_sprite_2d.flip_h:
		flip_h = true
		position.x = -abs(position.x)
	else:
		flip_h = false
		position.x = abs(position.x)


func _on_animation_finished() -> void:
	visible = false
	$fire/CollisionShape2D.disabled = true

extends Area2D
@export var door:Node2D
var follow_target = null 
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		follow_target = body
func _process(delta: float) -> void:
	if follow_target != null:
		var dir:Vector2 = follow_target.global_position - global_position
		global_position = global_position.move_toward(follow_target.global_position,delta * 110) 
func _ready():
	if door:
		door.get_node("%Area2D").connect("area_entered",on_key_open_door)
func on_key_open_door(area: Area2D):
	door.queue_free()
	queue_free()

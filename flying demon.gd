extends CharacterBody2D

@export var speed = 35
@export var damage = 2
var attackcooldown = 1
var health = 5

var startpoint = Vector2.ZERO
var endpoint = Vector2.ZERO
var impulse = Vector2.ZERO
var movement = Vector2.ZERO
@export var path: PathFollow2D
var pathPoint = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	impulse = impulse.move_toward(Vector2.ZERO,delta * 2000) 
	
	path.progress_ratio += delta * 0.07
	pathPoint = path.global_position
	
	var sprite = $AnimatedSprite2D
	var direction = pathPoint - global_position
	var normal = direction.normalized()
	if normal.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	movement = normal * speed
	
func _physics_process(delta):
	velocity = movement + impulse
	move_and_slide()
func hit(damage,pos):
	health -= damage
	var direction = global_position - pos
	print("%s damage!" % damage)
	var knockback = 300
	if direction.x > 0:
		impulse = Vector2(knockback,-knockback)
	else:
		impulse = Vector2(-knockback,-knockback)
	if health < 1:
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hit(damage,global_position)
		

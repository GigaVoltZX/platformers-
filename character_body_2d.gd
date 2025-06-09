extends CharacterBody2D
const Normal = 0
const Attack = 1
const Hurt = 2
const Crouch = 3
const Wall_slide = 4
const Roll = 5
var state = Normal
var impulse = Vector2()
var movement = Vector2()
var gravity = Vector2()
var wall_left = false
var wall_right = false
var Dash_dir = Vector2()
var Can_dash = true
const Dash = 5
@export var speed = 150.0
@export var footsteps: Array [AudioStream]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
func flip_char():
	$AnimatedSprite2D.flip_h = not $AnimatedSprite2D.flip_h
	$swordHitbox/CollisionShape2D.position.x = -($swordHitbox/CollisionShape2D. position.x)
	$RayCast2D.target_position.x = -($RayCast2D.target_position.x)
func flip():
	if movement.x < 0:
		$AnimatedSprite2D.flip_h = true
	if movement.x > 0:
		$AnimatedSprite2D.flip_h = false

func animate():
	if is_on_floor():
		if gravity.y > 0:
			gravity = Vector2.ZERO
		if movement.x < 0:
			$AnimatedSprite2D.flip_h = true
			if state == Crouch:
				$AnimatedSprite2D.play("CrouchWalk")
			else:
				
				$AnimatedSprite2D.play("Run")
		if movement.x > 0:
			$AnimatedSprite2D.flip_h = false
			if state == Normal:
			
				$AnimatedSprite2D.play("Run")
			else:
				$AnimatedSprite2D.play("CrouchWalk")
	else:
		if movement.x < 0:
			$AnimatedSprite2D.flip_h = true
			
		if movement.x > 0:
			$AnimatedSprite2D.flip_h = false
			
		if gravity.y < 0:
			$AnimatedSprite2D.play("jump")
		else:
			$AnimatedSprite2D.play("fall")
func movement2():
	var crouching = state == Crouch
	var crouching_speed = 0.7
	var current_speed = speed
	if crouching:
		current_speed = speed * crouching_speed
	var direction: float = Input.get_axis("Left","Right")
	movement.x = 0
	movement.y = 0
	if direction:
		if direction < 0:
			$swordHitbox/CollisionShape2D.position.x = -abs($swordHitbox/CollisionShape2D. position.x)
			$RayCast2D.target_position.x = -abs($RayCast2D.target_position.x)
		else:
			$swordHitbox/CollisionShape2D.position.x = abs($swordHitbox/CollisionShape2D. position.x)
			$RayCast2D.target_position.x = abs($RayCast2D.target_position.x)
		movement.x = direction * current_speed
	else:
		if state == Crouch:
			$AnimatedSprite2D.play("Crouch")
		else:
			$AnimatedSprite2D.play("default")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	impulse = impulse.move_toward(Vector2.ZERO, delta * 500)
	$CanvasLayer/Label.text = str(impulse)
	if not is_on_floor():
		gravity += get_gravity() * delta
	else:
		Can_dash = true
	if state == Normal:
		movement2()
		if is_on_wall():
			if $RayCast2D.is_colliding():
				if not is_on_floor():
					var wall_dir = $RayCast2D.get_collision_normal()
					if wall_dir.x > 0:
						wall_right = false
						wall_left = true
						state = Wall_slide
					elif wall_dir.x < 0:
						wall_left = false
						wall_right = true
						state = Wall_slide
		if Input.is_action_just_pressed("Crouch")and is_on_floor():
			state = Crouch
		if Input.is_action_pressed("Jump"):
			if is_on_floor_only():
				gravity.y = -370
		if Input.is_action_just_released("Jump") and velocity.y < 0:
			gravity.y /= 2.0
		animate()
		
		if  Input.is_action_just_pressed("roll")and is_on_floor():
			state = Roll
		
		if Input.is_action_just_pressed("dash")and Can_dash and not is_on_floor() and state != Dash:
			Can_dash = false
			state = Dash
			$DASHTIMER.start(0.2)
			var x = Input.get_axis("Left","Right")
			var y = Input.get_axis("up","down")
			Dash_dir = Vector2(x,y).normalized()
			
		
		if Input.is_action_just_pressed("attack") and state != Attack:
			state = Attack
			$SwordAttack.play()
			$AnimatedSprite2D.play("Attack")
	elif state == Wall_slide:
		if is_on_floor():
			state = Normal
		if Input.is_action_just_pressed("Jump"):
			flip_char()
			state = Normal
			gravity.y = 1.5
			if wall_left:
				impulse = Vector2(300,-500)
			elif wall_right:
				impulse = Vector2(-300,-500)
				
	
	
		
	elif state == Roll:
		$AnimatedSprite2D.play("roll")
		set_collision_layer_value(2,false)
		if movement.x > 0:
			$AnimatedSprite2D.flip_h == true
		else:
			$AnimatedSprite2D.flip_h == false
	
	elif state == Dash:
		dash()
	
		
	elif state == Crouch:
		movement2()
		flip()
		if not Input.is_action_pressed("Crouch"):
			state = Normal
		if movement.x == 0.0:
			$AnimatedSprite2D.play("CrouchWalk")
		else:
			$AnimatedSprite2D.play("Crouch")
	elif state == Attack:
		if $AnimatedSprite2D.flip_h == false:
			movement.x = 20
		else:
			movement.x = -20
	elif state == Hurt:
		movement.x = 0.0
		animate()
	
		
	velocity = movement + impulse + gravity
	if is_on_floor():
		if movement.x != 0:
			if $footsteps.playing == false:
				$footsteps.stream = footsteps.pick_random()
				$footsteps.pitch_scale = randf_range(0.94,1.1)
				$footsteps.play()
func dash():
	if Dash_dir.is_zero_approx():
		if $AnimatedSprite2D.flip_h:
			movement.x = -490
		elif not $AnimatedSprite2D.flip_h:
			movement.x = 490
	else:
		movement = Dash_dir * 490
	$AnimatedSprite2D.play("Dash")
	impulse.x = 0
	gravity = Vector2.ZERO
func _physics_process(delta: float) -> void:
	move_and_slide()
	#var real = get_real_velocity()
	#movement.x = real.x
func hit(damage,pos):
	$Timer.start(0.4)
	state = Hurt
	var direction = global_position - pos
	gravity.y = 100
	print("oof!")
	print("%s damage!" % damage)
	var knockback = 300
	if direction.x > 0:
		impulse = Vector2(knockback,-knockback)
	else:
		impulse = Vector2(-knockback,-knockback)
		
func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "Attack" and state == Attack:
		state = Normal
	if $AnimatedSprite2D.animation == "roll" and state == Roll:
		state = Normal
		set_collision_layer_value(2,true)
	

func _on_timer_timeout() -> void:
	state = Normal
	$Timer.stop()

func _on_sword_hitbox_body_entered(body: Node2D) -> void:
	print(body)
	if body.is_in_group("Enemy"):
		body.hit(1,global_position)

func _on_animated_sprite_2d_frame_changed() -> void:
	if $AnimatedSprite2D.animation != "Attack":
		$swordHitbox/CollisionShape2D.disabled = true
	if $AnimatedSprite2D.animation == "Attack":
		if $AnimatedSprite2D.frame == 1:
			$swordHitbox/CollisionShape2D.disabled = false
		if $AnimatedSprite2D.frame == 3:
			$swordHitbox/CollisionShape2D.disabled = true


func _on_dashtimer_timeout() -> void:
	$DASHTIMER.stop()
	state = Normal

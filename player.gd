extends CharacterBody2D

const SPEED = 300
const MAX_JUMP_VELOCITY = -380
const ON_JUMP_VELOCITY = 150
const ACCELERATION = 500
const FRICTION = 1000
var ACCUM_VELOCITY = -80
var is_jumping = false
var last_facing_direction: int = 1

var charging_jump = false
@onready var anim = $Sprite2D/AnimationPlayer
@onready var sprite = $Sprite2D
var was_on_floor

func _physics_process(delta: float) -> void:
	var input_axis = Input.get_axis("ui_left", "ui_right")
	apply_gravity(delta)
	handle_movement(delta, input_axis)
	move_and_slide()
	handle_animations(delta, input_axis)
	
	if not was_on_floor and is_on_floor():
		$Sprite2D/land.play()
		anim.stop(false)
		anim.play("RESET")
		if get_real_velocity().length() > 100:
			print($Sprite2D/AnimationPlayer.get_current_animation())
			anim.play("splat")
			print($Sprite2D/AnimationPlayer.get_current_animation())
		else:
			print("not enough gravity")
	was_on_floor = is_on_floor()

func apply_gravity(_delta:float):
	if !is_on_floor():
		velocity.y += 10   
	else:
		is_jumping = false
	
	
func handle_movement(delta:float, input_axis: int):
	if !charging_jump && !is_jumping:
		if input_axis < 0 :
			velocity.x = move_toward(velocity.x, SPEED * input_axis, delta * ACCELERATION)
		elif input_axis > 0 :
			velocity.x = move_toward(velocity.x, SPEED * input_axis, delta * ACCELERATION)
		else:
			velocity.x = move_toward(velocity.x, 0, delta * FRICTION)
	
	if Input.is_action_just_pressed("ui_accept") && is_on_floor():
		velocity.x = 0
		charging_jump = true
		while ACCUM_VELOCITY >= MAX_JUMP_VELOCITY:                                                 
			await  get_tree().create_timer(0.1).timeout
			ACCUM_VELOCITY -= 50
	if Input.is_action_just_released("ui_accept"):
			$Sprite2D/jump.play()
			var normalized = Vector2(ON_JUMP_VELOCITY * input_axis,ACCUM_VELOCITY)
			velocity = lerp(velocity, normalized, 1)
			charging_jump = false
			is_jumping = true
	
	if !is_on_floor() && is_on_wall_only():
		var wall_normal = get_wall_normal()
		velocity.x = ON_JUMP_VELOCITY / 1.5 * wall_normal.x
		
			

func handle_animations(delta, input_axis: int):
	last_facing_direction = input_axis
	if input_axis < 0:
		sprite.flip_h = true
	elif input_axis > 0:     
		sprite.flip_h = false
	else:
		last_facing_direction = -1 if last_facing_direction < 0 else 1
		
	if input_axis && !charging_jump && is_on_floor() && $Sprite2D/AnimationPlayer.get_current_animation() != "splat": 
		anim.play("run")
		pass
	elif !input_axis || is_on_floor()  :
		anim.play("idle")
		pass
		
	
	if charging_jump:
		anim.play("crouch")
		pass
	if Input.is_action_just_released("ui_accept"):
		anim.play("jump")
		pass
	if velocity.y > 0 : 
		anim.play("fall")
		pass

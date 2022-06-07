extends KinematicBody2D

var wheel_base = 70
var steering_angle = deg2rad(20)
var steer_angle = 0

var velocity = Vector2(10, 0)
var animating = false

func _ready():
	$WheelFront.position = Vector2(wheel_base/2, 0)
	$WheelRear.position = Vector2(-wheel_base/2, 0)
	
func get_input():
	if animating: return
	if Input.is_action_just_pressed("ui_focus_next"):
		$WheelRear.visible = !$WheelRear.visible
		$WheelFront.visible = !$WheelFront.visible
	velocity = Vector2.ZERO
	var rot = 0
	if Input.is_action_pressed("ui_right"):
		rot += 1
	if Input.is_action_pressed("ui_left"):
		rot -= 1
	rotation = rot * steering_angle
	if rot != 0:
		if Input.is_action_pressed("accelerate"):
			velocity = Vector2(100, 0)
			animate_ghost(velocity)
#			$Ghost.position = velocity#.rotated(rotation)
			return

	var turn = 0
	if Input.is_action_pressed("steer_right"):
		turn += 1
	if Input.is_action_pressed("steer_left"):
		turn -= 1
	steer_angle = turn * steering_angle
	$WheelFront.rotation = steer_angle
	
	if Input.is_action_pressed("accelerate"):
		velocity = Vector2(100, 0)
		calculate_steering()
		animate_ghost(($WheelFront.position + $WheelRear.position)/2, ($WheelFront.position - $WheelRear.position).angle() + PI/2)

func calculate_steering():
	$WheelRear.position = Vector2(-wheel_base/2, 0) + velocity
	$WheelFront.position = Vector2(wheel_base/2, 0) + velocity.rotated(steer_angle)
#	$Ghost.position = ($WheelFront.position + $WheelRear.position)/2
#	$Ghost.rotation = ($WheelFront.position - $WheelRear.position).angle() + PI/2

func _physics_process(delta):
	get_input()

func animate_ghost(pos, rot=0):
	if animating:
		return
	$Ghost.show()
	$Sprite.modulate.a = 0.5
	$Tween.interpolate_property($Ghost, "position",
		Vector2(0, 0), pos, 1.0,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	if rot:
		$Tween.interpolate_property($Ghost, "rotation",
			PI/2, rot, 1.0,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	animating = true
	
func _on_Tween_tween_completed(object, key):
	yield(get_tree().create_timer(0.5), "timeout")
	animating = false
	$Sprite.modulate.a = 1
	$Ghost.rotation = PI/2
	$Ghost.hide()

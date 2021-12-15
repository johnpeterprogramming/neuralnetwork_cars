extends KinematicBody2D

var debug_draw = true

var wheel_base = 70
var steering_angle = deg2rad(15)
var steering_angle_slow = deg2rad(15)
var engine_power = 800
var braking = -450
#var max_speed = 650
var max_speed_reverse = 250
var friction = -0.9
var drag = -0.001
var traction_fast = 0.1
var traction_slow = 0.5
var slip_speed = 400

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var steer_angle
#var front_wheel
#var rear_wheel

func _ready():
	$Node2D.visible = debug_draw

func _draw():
	if debug_draw:
		draw_circle(Vector2(wheel_base/2.0, 0), 5, Color(1, 0, 0))
		draw_circle(Vector2(-wheel_base/2.0, 0), 5, Color(1, 0, 0))

func get_input():
	var turn = 0
	if Input.is_action_pressed("steer_right"):
		turn += 1
	if Input.is_action_pressed("steer_left"):
		turn -= 1
	steer_angle = turn * steering_angle
	if velocity.length() < slip_speed:
		steer_angle = turn * steering_angle_slow
	if Input.is_action_pressed("accelerate"):
		acceleration = transform.x * engine_power
	if Input.is_action_pressed("brake"):
		acceleration = transform.x * braking

func _physics_process(delta):
	if debug_draw:
		$Node2D.global_rotation = 0
		$Node2D/Label.text = str("%5.1f" % velocity.length())
	acceleration = Vector2.ZERO
	get_input()
	apply_friction()
	calculate_steering(delta)
	velocity += acceleration * delta
	velocity = move_and_slide(velocity)
	
func apply_friction():
	var f = velocity * friction
	var d = velocity * velocity.length() * drag
	if velocity.length() < 100:
		f *= 3
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	acceleration += d + f

func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_angle) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()

	var traction = traction_slow
	$SkidLeft.emitting = false
	if velocity.length() > slip_speed:
		traction = traction_fast
	var d = new_heading.dot(velocity.normalized())
#	if d > 0.1 and d < 1 and velocity.length() > slip_speed:
#		$SkidLeft.emitting = true
	if d > 0:
		velocity = velocity.linear_interpolate(new_heading * velocity.length(), traction)
	elif d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	rotation = new_heading.angle()

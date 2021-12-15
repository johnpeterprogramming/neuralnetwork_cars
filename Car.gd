extends KinematicBody2D
# car mechanics
var wheel_base = 70
var steering_angle = 10
var engine_power = 3000
var friction = -0.9
var drag = -0.0001
var braking = -450
var max_speed_reverse = 250
var slip_speed = 400
var traction_fast = 0.1
var traction_slow = 0.7

var acceleration = Vector2.ZERO
var velocity = Vector2.ZERO
var steer_direction

# waypoints
var time = 0
var current_waypoint = 0
var waypoints
var total_waypoints_passed = 0

# neural network layers
var hidden_layer
var output_layer

export var engine_on = false
export var using_ai = true

func _ready():
	waypoints = get_tree().get_nodes_in_group("Waypoint")
	for waypoint in waypoints:
		waypoint.connect("body_entered", self, "_waypoint", [waypoint])

func _physics_process(delta):
	if engine_on:
		acceleration = Vector2.ZERO
		if using_ai:
			apply_choices(calculate_layers(get_node("Raycasts").distances))
		else:
			get_input()
			
		apply_friction()
		calculate_steering(delta)
		velocity += acceleration * delta
		if using_ai:
			time += delta
			
			var collisions = move_and_collide(velocity*delta)
			if collisions:
#				pass
#				visible = false
				engine_on = false
		else:
			move_and_slide(velocity)

func apply_friction():
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction
	var drag_force = velocity * velocity.length() * drag
	acceleration += drag_force + friction_force
	
func get_input():
	var turn = 0
	if Input.is_action_pressed("steer_right"):
		turn += 1
	if Input.is_action_pressed("steer_left"):
		turn -= 1
	steer_direction = turn * deg2rad(steering_angle)
	if Input.is_action_pressed("accelerate"):
		acceleration = transform.x * engine_power
	if Input.is_action_pressed("brake"):
		acceleration = transform.x * braking
		
func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base/2.0
	var front_wheel = position + transform.x * wheel_base/2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = velocity.linear_interpolate(new_heading * velocity.length(), traction)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	rotation = new_heading.angle()

func calculate_layers(distances):
	var hidden_outputs = hidden_layer.forward(distances)
	return output_layer.forward(hidden_outputs)

func apply_choices(neural_output):
	var left = neural_output[0]
	var right = neural_output[1]
#	var accelerate = neural_output[2]
	
	var turn = 0
		
	if left > right:
		turn = -1
	if right > left:
		turn = 1
	
#	if accelerate > 0.5:
	acceleration = transform.x * engine_power

	steer_direction = turn * deg2rad(steering_angle)
#	acceleration = transform.x * engine_power#heeltyd besig om te ry

func _waypoint(body, waypoint):
	if body == self and waypoint == waypoints[current_waypoint]:
		current_waypoint = (current_waypoint + 1)%len(waypoints)
		total_waypoints_passed += 1


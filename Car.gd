extends KinematicBody2D

var wheel_base = 70
var steering_angle = 30
var engine_power = 500
var braking_power = 450
var friction = -0.9
var drag = -0.0015

var steer_angle = 0
var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO

func _physics_process(delta):
	get_input()
	calculate_steering(delta)
	apply_friction()

	velocity += acceleration * delta
	velocity = move_and_slide(velocity)

func get_input():
	var turn = 0
	if Input.is_action_pressed("ui_right"):
		turn += 1
	if Input.is_action_pressed("ui_left"):
		turn -= 1
	steer_angle = turn * deg2rad(steering_angle)

	acceleration = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		acceleration = transform.x * engine_power
	if Input.is_action_pressed("ui_down"):
		acceleration = transform.x * -braking_power

func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_angle) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = new_heading * velocity.length()
	if d < 0:
		velocity = -new_heading * velocity.length()
	rotation = new_heading.angle()

func apply_friction():
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction
	var drag_force = velocity * velocity.length() * drag
	if velocity.length() < 100:
		friction_force *= 3
	acceleration += drag_force + friction_force

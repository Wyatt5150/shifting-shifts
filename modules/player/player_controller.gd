extends CharacterBody3D
class_name Player

const SPEED := 5.0
const SPRINT_MULT := 1.5
const JUMP_VELOCITY := 1.5

var is_running := false

const MAX_LOOK_UP := 90.0
const MAX_LOOK_DOWN := -90.0

const horizontal_mouse_sensitivity := 0.002
const vertical_mouse_sensitivity := 0.003

@onready var head: Node3D = %Head
@onready var v_head: Node3D = %VHead

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		handle_head_movement(event.relative.x,event.relative.y)

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	
	if Input.is_action_just_pressed("jump"):
		handle_jump()
	
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	handle_move(input_dir.x, input_dir.y)
	
	move_and_slide()

func handle_gravity(delta: float) -> void:
	if !is_on_floor():
		velocity += get_gravity() * delta

func handle_jump() -> void:
	if self.is_on_floor():
		self.velocity.y = JUMP_VELOCITY

func handle_move(x: float, z: float):
	var speed := SPEED 
	if is_running:
		speed *= SPRINT_MULT
	
	var direction := (head.transform.basis * Vector3(x, 0, z)).normalized()
	var current_velocity : Vector3 = self.velocity
	if direction:
		current_velocity.x = direction.x * speed
		current_velocity.z = direction.z * speed
	else:
		current_velocity.x = move_toward(current_velocity.x, 0, speed)
		current_velocity.z = move_toward(current_velocity.z, 0, speed)
	
	self.velocity = current_velocity

func toggle_sprint(toggle : bool) -> void:
	is_running = toggle

func handle_head_movement(x: float, y: float) -> void:
	head.rotate_y(-x * horizontal_mouse_sensitivity)
	
	v_head.rotate_x(-y * vertical_mouse_sensitivity)
	v_head.rotation.x = clampf(
		v_head.rotation.x,
		deg_to_rad(MAX_LOOK_DOWN),
		deg_to_rad(MAX_LOOK_UP)
	)

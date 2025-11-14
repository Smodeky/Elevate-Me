extends Camera3D

@export var ray_length: float = 1000.0
@export var rotation_step_deg: float = 90.0
@export var rotate_speed: float = 5.0
var target_rotation_y: float = 0.0


func _ready():
	target_rotation_y = rotation.y

func _process(delta):
	rotation.y = lerp_angle(rotation.y, target_rotation_y, delta * rotate_speed)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_interact_with_object(event.position)

	if event.is_action_pressed("rotate_left"):
		target_rotation_y += deg_to_rad(rotation_step_deg)

	if event.is_action_pressed("rotate_right"):
		target_rotation_y -= deg_to_rad(rotation_step_deg)

func _interact_with_object(mouse_position: Vector2):
	var from = project_ray_origin(mouse_position)
	var to = from + project_ray_normal(mouse_position) * ray_length

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)

	var result = space_state.intersect_ray(query)

	if result and result.collider:
		var obj = result.collider
		if obj.has_method("interact"):
			obj.interact()

extends RigidBody2D

@export var cake_textures: Array[Texture2D]

# Cake size settings.
@export_range(0.65, 1.0, 0.05) var minimum_scale: float = 0.85
@export_range(0.9, 1.1, 0.01) var random_scale_min: float = 0.95
@export_range(0.9, 1.1, 0.01) var random_scale_max: float = 1.05

# Slightly inset the collision shape.
@export_range(0.85, 1.0, 0.01) var collision_size_factor: float = 0.95

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	var material := PhysicsMaterial.new()
	material.bounce = 0.0
	material.friction = 0.8

	physics_material_override = material

	can_sleep = true
	continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE


func set_difficulty(level: int, cake_count_in_level: int) -> void:
	# Select a random texture.
	var valid_textures: Array[Texture2D] = []

	for texture in cake_textures:
		if texture != null:
			valid_textures.append(texture)

	if valid_textures.is_empty():
		push_error("Cake.gd: Assign at least one texture in the Inspector.")
		return

	sprite_2d.texture = valid_textures.pick_random()

	# Reduce size gradually as difficulty increases.
	var level_shrink: float = float(level - 1) * 0.025
	var cake_shrink: float = float(cake_count_in_level) * 0.01

	var difficulty_scale: float = maxf(
		minimum_scale,
		1.0 - level_shrink - cake_shrink
	)

	var variation: float = randf_range(
		random_scale_min,
		random_scale_max
	)

	var final_scale: float = difficulty_scale * variation

	# Apply uniform scaling to the artwork.
	sprite_2d.scale = Vector2.ONE * final_scale

	# Generate a collision shape that matches the displayed sprite.
	update_collision()


func update_collision() -> void:
	if sprite_2d.texture == null:
		push_error("Cake.gd: Cannot create collision without a texture.")
		return

	var texture_size: Vector2 = sprite_2d.texture.get_size()

	# Create a fresh shape for this cake.
	var rectangle := RectangleShape2D.new()

	rectangle.size = Vector2(
		texture_size.x * absf(sprite_2d.scale.x) * collision_size_factor,
		texture_size.y * absf(sprite_2d.scale.y) * collision_size_factor
	)

	collision_shape.shape = rectangle

	# Do not scale the collision a second time.
	collision_shape.scale = Vector2.ONE

	# Match the Sprite2D's local placement.
	collision_shape.position = sprite_2d.position + (
		sprite_2d.offset * sprite_2d.scale
	)

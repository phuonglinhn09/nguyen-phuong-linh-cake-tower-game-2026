extends Node2D

@export var cake_scene: PackedScene
@export var move_limit: float = 200.0

# UI nodes
@onready var timer_label: Label = $UI/TimerLabel
@onready var level_label: Label = $UI/LevelLabel
@onready var result_panel: Control = $UI/ResultPanel
@onready var result_label: Label = $UI/ResultPanel/ResultLabel
@onready var restart_button: Button = $UI/ResultPanel/RestartButton

# Scene nodes
@onready var spawner: Node2D = $Spawner
@onready var camera: Camera2D = $Camera2D
@onready var finish_line: ColorRect = $FinishLine
@onready var drop_sound: AudioStreamPlayer2D = $DropSound

# Game variables
var current_level: int = 1
var move_speed: float = 250.0
var game_time: float = 30.0
var time_left: float = 30.0

var direction: int = 1
var current_cake: RigidBody2D = null

var is_dropping: bool = false
var is_game_ended: bool = false
var reached_finish_line: bool = false

# Number of cakes dropped in the current level.
var cakes_dropped_in_level: int = 0


func _ready() -> void:
	result_panel.hide()

	restart_button.pressed.connect(_on_restart_button_pressed)

	# Make the result panel fill the viewport.
	result_panel.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	# Center the result label.
	result_label.anchor_left = 0.0
	result_label.anchor_right = 1.0
	result_label.anchor_top = 0.5
	result_label.anchor_bottom = 0.5

	result_label.offset_left = 0.0
	result_label.offset_right = 0.0
	result_label.offset_top = -80.0
	result_label.offset_bottom = -20.0

	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# Center the restart button.
	restart_button.anchor_left = 0.5
	restart_button.anchor_right = 0.5
	restart_button.anchor_top = 0.5
	restart_button.anchor_bottom = 0.5

	restart_button.offset_left = -125.0
	restart_button.offset_right = 125.0
	restart_button.offset_top = 20.0
	restart_button.offset_bottom = 80.0

	current_level = GameData.selected_level

	start_level(current_level)


func start_level(level: int) -> void:
	# Reset game state.
	is_game_ended = false
	reached_finish_line = false
	is_dropping = false

	current_cake = null
	cakes_dropped_in_level = 0

	result_panel.hide()

	# Remove old cakes from the active scene immediately.
	for child in get_children():
		if child is RigidBody2D:
			remove_child(child)
			child.queue_free()

	# Reset spawner movement.
	direction = 1

	camera.position = Vector2.ZERO
	spawner.position = Vector2(
	0.0,
	-320.0 - float(current_level - 1) * 20.0
)


	# Configure the level timer.
	game_time = maxf(15.0, 35.0 - (level * 2.0))
	time_left = game_time

	# Increase movement speed with difficulty.
	move_speed = minf(550.0, 200.0 + (level * 40.0))

	# Configure finish-line height.
	var finish_height: float = 220.0 - (level * 120.0)
	finish_line.position.y = maxf(-250.0, finish_height)

	print(
		"Level ",
		level,
		" -> FinishLine Y = ",
		finish_line.global_position.y
	)

	level_label.text = "LEVEL: " + str(current_level)

	spawn_cake()


func _process(delta: float) -> void:
	if is_game_ended:
		return

	# Update the timer.
	time_left -= delta

	timer_label.text = str(maxi(0, ceili(time_left))) + "s"

	if time_left <= 0.0:
		end_game(false)
		return

	# Move the spawner horizontally.
	spawner.position.x += move_speed * direction * delta

	if spawner.position.x >= move_limit:
		spawner.position.x = move_limit
		direction = -1
	elif spawner.position.x <= -move_limit:
		spawner.position.x = -move_limit
		direction = 1

	# Move the preview cake with the spawner.
	if is_instance_valid(current_cake) and current_cake.freeze:
		current_cake.global_position = spawner.global_position

	# Check whether the stack has reached the finish line.
	check_finish_line()


func _unhandled_input(event: InputEvent) -> void:
	if is_game_ended:
		return

	var should_drop: bool = false

	if event.is_action_pressed("ui_accept"):
		should_drop = true
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			should_drop = true

	if should_drop and not is_dropping:
		drop_cake()


func spawn_cake() -> void:
	if is_game_ended:
		return

	if cake_scene == null:
		push_error("Cake scene is not assigned in the Inspector!")
		return

	var new_cake := cake_scene.instantiate() as RigidBody2D

	if new_cake == null:
		push_error("Cake scene root must be a RigidBody2D!")
		return

	# Freeze the cake before it enters the physics simulation.
	new_cake.freeze = true

	# Add it to the tree so @onready variables initialize.
	add_child(new_cake)

	# Configure the texture, scale, and collision.
	new_cake.set_difficulty(
		current_level,
		cakes_dropped_in_level
	)

	# Position it at the spawner.
	new_cake.global_position = spawner.global_position

	# Clear residual movement.
	new_cake.linear_velocity = Vector2.ZERO
	new_cake.angular_velocity = 0.0

	current_cake = new_cake
	is_dropping = false

	print("Spawned cake: ", new_cake.global_position)
	print("Cake visible: ", new_cake.visible)
	print("Cake texture: ", new_cake.get_node("Sprite2D").texture)


func drop_cake() -> void:
	if is_game_ended or is_dropping:
		return

	if not is_instance_valid(current_cake):
		return

	if not current_cake.freeze:
		return

	is_dropping = true

	# Play the drop sound.
	drop_sound.play(1.865)

	# Count the dropped cake.
	cakes_dropped_in_level += 1

	# Clear residual movement.
	current_cake.linear_velocity = Vector2.ZERO
	current_cake.angular_velocity = 0.0

	# Restore collisions before releasing the cake.
	if current_cake.has_method("set_aiming"):
		current_cake.set_aiming(false)

	# Release the cake into the physics simulation.
	current_cake.freeze = false

	# The cake is now falling; the next cake will be spawned later.
	current_cake = null

	await get_tree().create_timer(0.8).timeout

	if not is_game_ended:
		spawn_cake()


func check_finish_line() -> void:
	if is_game_ended:
		return

	for child in get_children():
		if not child is RigidBody2D:
			continue

		var cake := child as RigidBody2D

		# Ignore the preview cake.
		if cake == current_cake or cake.freeze:
			continue

		# Require the cake to be nearly stationary.
		if cake.linear_velocity.length() >= 5.0:
			continue

		# Ignore cakes that have not fallen far enough.
		if cake.global_position.y <= spawner.global_position.y + 150.0:
			continue

		var collision_shape := cake.get_node_or_null(
			"CollisionShape2D"
		) as CollisionShape2D

		if collision_shape == null:
			continue

		if not collision_shape.shape is RectangleShape2D:
			continue

		var rectangle := collision_shape.shape as RectangleShape2D

		# Calculate the vertical extent of the rotated rectangle.
		var half_width: float = rectangle.size.x * 0.5
		var half_height: float = rectangle.size.y * 0.5
		var angle: float = collision_shape.global_rotation

		var vertical_extent: float = (
			absf(cos(angle)) * half_height
			+ absf(sin(angle)) * half_width
		)

		# Use the collision shape's actual world position.
		var cake_top_y: float = (
			collision_shape.global_position.y - vertical_extent
		)

		# The cake's upper edge must reach the finish line.
		if cake_top_y <= finish_line.global_position.y:
			reached_finish_line = true
			end_game(true)
			return


func end_game(is_win: bool) -> void:
	if is_game_ended:
		return

	is_game_ended = true
	result_panel.show()

	if is_win:
		GameData.complete_level(
			current_level,
			maxf(0.0, time_left)
		)

		result_label.text = "HOÀN THÀNH LEVEL " + str(current_level) + "!"
		result_label.modulate = Color("39cf5bff")

		restart_button.text = "TIẾP"

		current_level += 1
	else:
		result_label.text = "THẤT BẠI!\nChưa chạm vạch đích."
		result_label.modulate = Color("e35250ff")

		restart_button.text = "THỬ LẠI"


func _on_restart_button_pressed() -> void:
	start_level(current_level)

extends Control

const GAME_SCENE = "res://Main.tscn"
const MENU_SCENE = "res://main_menu.tscn"

const TOTAL_LEVELS = 20
const COLUMNS = 4

# --------------------------------------------------
# RESPONSIVE LAYOUT
# --------------------------------------------------

@export_group("Layout")

@export_range(1, 8, 1) var columns: int = 4
@export_range(1, 50, 1) var total_levels: int = 20

@export var button_size: Vector2 = Vector2(180, 180)
@export_range(0.0, 100.0, 1.0) var button_gap: float = 35.0

@export var title_height: float = 180.0
@export var back_button_size: Vector2 = Vector2(360, 100)
@export var vertical_spacing: float = 50.0

@export_range(0.5, 1.0, 0.05) var viewport_usage: float = 0.90

@export var minimum_button_size: Vector2 = Vector2(65, 65)

# --------------------------------------------------
# BUTTON COLORS
# --------------------------------------------------

@export_group("Button Colors")

@export var unlocked_color: Color = Color("#F0BA2F")
@export var unlocked_border_color: Color = Color("#A85D16")

@export var locked_color: Color = Color("#C76B32")
@export var locked_border_color: Color = Color("#783F20")

@export var hover_brightness: float = 0.12
@export var pressed_darkness: float = 0.15

# --------------------------------------------------
# BUTTON APPEARANCE
# --------------------------------------------------

@export_group("Button Appearance")

@export_range(0, 90, 1) var corner_radius: int = 36
@export_range(0, 15, 1) var border_width: int = 4

@export var button_padding: float = 8.0

# --------------------------------------------------
# TEXT
# --------------------------------------------------

@export_group("Text")

@export var level_font: Font

@export var unlocked_font_size: int = 56
@export var locked_font_size: int = 28
@export var back_font_size: int = 40
@export var title_font_size: int = 56

@export var text_color: Color = Color.WHITE
@export var outline_color: Color = Color.BLACK

@export_range(0, 30, 1) var outline_size: int = 10

# --------------------------------------------------
# NODES
# --------------------------------------------------

@onready var background: ColorRect = $Background
@onready var title_label: Label = $TitleLabel
@onready var level_grid: GridContainer = $LevelGrid
@onready var back_button: Button = $BackButton


func _ready() -> void:
	# Fill the viewport.
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Configure title.
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	title_label.add_theme_font_size_override(
		"font_size",
		title_font_size
	)

	if level_font != null:
		title_label.add_theme_font_override("font", level_font)

	# Configure grid.
	level_grid.columns = columns
	level_grid.add_theme_constant_override(
		"h_separation",
		int(button_gap)
	)
	level_grid.add_theme_constant_override(
		"v_separation",
		int(button_gap)
	)

	create_level_buttons()
	style_back_button()

	if not back_button.pressed.is_connected(_on_back_pressed):
		back_button.pressed.connect(_on_back_pressed)

	if not get_viewport().size_changed.is_connected(_on_viewport_resized):
		get_viewport().size_changed.connect(_on_viewport_resized)

	call_deferred("center_layout")


# ==================================================
# CREATE LEVEL BUTTONS
# ==================================================

func create_level_buttons() -> void:
	for child in level_grid.get_children():
		level_grid.remove_child(child)
		child.queue_free()

	var level_count: int = maxi(1, total_levels)

	for level in range(1, level_count + 1):
		var button := Button.new()

		button.custom_minimum_size = button_size
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		button.size = button_size

		if level <= GameData.unlocked_level:
			# Unlocked levels.
			button.text = str(level)

			if GameData.completed_levels.has(level):
				button.text += "\n✓"

			style_level_button(
				button,
				unlocked_color,
				unlocked_border_color,
				unlocked_font_size
			)

			button.pressed.connect(
				_on_level_pressed.bind(level)
			)

		else:
			# Locked levels.
			button.text = str(level) + "\nLOCKED"

			style_level_button(
				button,
				locked_color,
				locked_border_color,
				locked_font_size
			)

			button.disabled = true

		level_grid.add_child(button)


# ==================================================
# STYLE LEVEL BUTTONS
# ==================================================

func style_level_button(
	button: Button,
	bg_color: Color,
	border_color: Color,
	font_size: int
) -> void:
	var normal_style := create_button_style(
		bg_color,
		border_color
	)

	var hover_style := create_button_style(
		bg_color.lightened(hover_brightness),
		border_color
	)

	var pressed_style := create_button_style(
		bg_color.darkened(pressed_darkness),
		border_color
	)

	var disabled_style := create_button_style(
		bg_color.darkened(0.08),
		border_color
	)

	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_stylebox_override("disabled", disabled_style)

	# Remove the default focus rectangle.
	button.add_theme_stylebox_override(
		"focus",
		StyleBoxEmpty.new()
	)

	# Font.
	if level_font != null:
		button.add_theme_font_override("font", level_font)

	button.add_theme_font_size_override(
		"font_size",
		font_size
	)

	# Consistent white text and black outline.
	button.add_theme_color_override("font_color", text_color)
	button.add_theme_color_override("font_hover_color", text_color)
	button.add_theme_color_override("font_pressed_color", text_color)
	button.add_theme_color_override("font_disabled_color", text_color)

	button.add_theme_color_override(
		"font_outline_color",
		outline_color
	)

	button.add_theme_constant_override(
		"outline_size",
		outline_size
	)

	button.alignment = HORIZONTAL_ALIGNMENT_CENTER


# ==================================================
# SHARED BUTTON STYLE
# ==================================================

func create_button_style(
	bg_color: Color,
	border_color: Color
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()

	style.bg_color = bg_color

	style.corner_radius_top_left = corner_radius
	style.corner_radius_top_right = corner_radius
	style.corner_radius_bottom_left = corner_radius
	style.corner_radius_bottom_right = corner_radius

	style.border_width_left = border_width
	style.border_width_right = border_width
	style.border_width_top = border_width
	style.border_width_bottom = border_width

	style.border_color = border_color

	style.content_margin_left = button_padding
	style.content_margin_right = button_padding
	style.content_margin_top = button_padding
	style.content_margin_bottom = button_padding

	return style


# ==================================================
# BACK BUTTON
# ==================================================

func style_back_button() -> void:
	var normal_style := create_button_style(
		unlocked_color,
		unlocked_border_color
	)

	var hover_style := create_button_style(
		unlocked_color.lightened(hover_brightness),
		unlocked_border_color
	)

	var pressed_style := create_button_style(
		unlocked_color.darkened(pressed_darkness),
		unlocked_border_color
	)

	back_button.add_theme_stylebox_override("normal", normal_style)
	back_button.add_theme_stylebox_override("hover", hover_style)
	back_button.add_theme_stylebox_override("pressed", pressed_style)
	back_button.add_theme_stylebox_override(
		"focus",
		StyleBoxEmpty.new()
	)

	if level_font != null:
		back_button.add_theme_font_override("font", level_font)

	back_button.add_theme_font_size_override(
		"font_size",
		back_font_size
	)

	back_button.add_theme_color_override("font_color", text_color)
	back_button.add_theme_color_override("font_hover_color", text_color)
	back_button.add_theme_color_override("font_pressed_color", text_color)

	back_button.add_theme_color_override(
		"font_outline_color",
		outline_color
	)

	back_button.add_theme_constant_override(
		"outline_size",
		outline_size
	)


# ==================================================
# RESPONSIVE LAYOUT
# ==================================================

func _on_viewport_resized() -> void:
	center_layout()


func center_layout() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size

	# Prevent invalid layouts.
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	# Update the number of columns.
	level_grid.columns = clampi(columns, 1, 8)

	# Calculate the available width.
	var available_width: float = viewport_size.x * viewport_usage

	var horizontal_gaps: float = (
		float(level_grid.columns - 1) * button_gap
	)

	var calculated_button_width: float = (
		available_width - horizontal_gaps
	) / float(level_grid.columns)

	# Do not make buttons wider than their configured size.
	var final_button_width: float = minf(
		button_size.x,
		calculated_button_width
	)

	# Maintain button proportions.
	var scale_factor: float = final_button_width / maxf(
		button_size.x,
		1.0
	)

	var final_button_height: float = maxf(
		minimum_button_size.y,
		button_size.y * scale_factor
	)

	# Apply responsive sizing to every button.
	for child in level_grid.get_children():
		if child is Button:
			var button := child as Button

			button.custom_minimum_size = Vector2(
				final_button_width,
				final_button_height
			)

	# Recalculate grid dimensions after resizing.
	var grid_size: Vector2 = level_grid.get_combined_minimum_size()

	# Calculate the available vertical space.
	var total_height: float = (
		title_height
		+ vertical_spacing
		+ grid_size.y
		+ vertical_spacing
		+ back_button_size.y
	)

	# Center the complete group vertically.
	var start_y: float = maxf(
		10.0,
		(viewport_size.y - total_height) / 2.0
	)

	# Title.
	title_label.position = Vector2.ZERO
	title_label.position.y = start_y
	title_label.size = Vector2(
		viewport_size.x,
		title_height
	)

	# Grid.
	level_grid.position = Vector2(
		(viewport_size.x - grid_size.x) / 2.0,
		start_y + title_height + vertical_spacing
	)

	# Back button.
	var final_back_width: float = minf(
		back_button_size.x,
		viewport_size.x * 0.8
	)

	back_button.size = Vector2(
		final_back_width,
		back_button_size.y
	)

	back_button.position = Vector2(
		(viewport_size.x - final_back_width) / 2.0,
		level_grid.position.y + grid_size.y + vertical_spacing
	)


# ==================================================
# BUTTON CALLBACKS
# ==================================================

func _on_level_pressed(level: int) -> void:
	GameData.selected_level = level
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)

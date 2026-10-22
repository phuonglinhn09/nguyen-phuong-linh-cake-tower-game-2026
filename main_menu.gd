extends Control

const GAME_SCENE = "res://Main.tscn"
const LEVEL_SELECT_SCENE = "res://Level_Select.tscn"

# ==================================================
# FIXED LAYOUT
# ==================================================

@export_group("Layout")

@export var button_size: Vector2 = Vector2(660, 130)
@export var button_gap: float = 35.0

# Distance from the top of the screen to the title.
@export var title_top_margin: float = 40.0
@export var title_height: float = 120.0

# Distance between the title and the first button.
@export var title_button_spacing: float = 100.0

# High-score label.
@export var high_score_height: float = 100.0
@export var high_score_spacing: float = 35.0

# Extra space before Quit.
@export var quit_spacing: float = 80.0

@export var screen_margin: float = 20.0

# ==================================================
# BUTTON COLORS
# ==================================================

@export_group("Button Colors")

@export var button_color: Color = Color("#F0BA2F")
@export var button_border_color: Color = Color("#A85D16")

@export var hover_brightness: float = 0.12
@export var pressed_darkness: float = 0.15

# ==================================================
# BUTTON APPEARANCE
# ==================================================

@export_group("Button Appearance")

@export_range(0, 90, 1) var corner_radius: int = 36
@export_range(0, 15, 1) var border_width: int = 4

@export var button_padding: float = 8.0

# ==================================================
# TEXT
# ==================================================

@export_group("Text")

@export var menu_font: Font

@export var button_font_size: int = 44
@export var title_font_size: int = 64
@export var high_score_font_size: int = 32

@export var text_color: Color = Color.WHITE
@export var outline_color: Color = Color.BLACK

@export_range(0, 30, 1) var outline_size: int = 10

@export var title_text: String = "CAKE TOWER"

# ==================================================
# EXISTING NODES
# ==================================================

@onready var background: ColorRect = $Background

@onready var center_container: CenterContainer = \
	$Background/CenterContainer

@onready var vbox: VBoxContainer = \
	$Background/CenterContainer/VBoxContainer

@onready var play_button: Button = \
	$Background/CenterContainer/VBoxContainer/PlayButton

@onready var level_select_button: Button = \
	$Background/CenterContainer/VBoxContainer/LevelSelectButton

@onready var high_score_label: Label = \
	$Background/CenterContainer/VBoxContainer/HighScoreLabel

@onready var quit_button: Button = \
	$Background/CenterContainer/VBoxContainer/QuitButton

# Created once and reused.
var title_label: Label
var quit_spacer: Control
var score_spacer: Control


# ==================================================
# READY
# ==================================================

func _ready() -> void:
	# Fill the screen.
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE

	center_container.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	# Create the title only once.
	create_title()

	# Configure the VBoxContainer.
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override(
		"separation",
		int(button_gap)
	)

	# Style the buttons.
	for button in [
		play_button,
		level_select_button,
		quit_button
	]:
		style_menu_button(button)

	# Style the high-score label.
	style_high_score_label()

	# Create spacers once.
	create_spacers()

	# Connect signals safely.
	if not play_button.pressed.is_connected(_on_play_pressed):
		play_button.pressed.connect(_on_play_pressed)

	if not level_select_button.pressed.is_connected(_on_level_select_pressed):
		level_select_button.pressed.connect(_on_level_select_pressed)

	if not quit_button.pressed.is_connected(_on_quit_pressed):
		quit_button.pressed.connect(_on_quit_pressed)

	# Update the menu when the viewport changes.
	if not get_viewport().size_changed.is_connected(_on_viewport_resized):
		get_viewport().size_changed.connect(_on_viewport_resized)

	update_high_score()
	update_layout()


# ==================================================
# TITLE
# ==================================================

func create_title() -> void:
	title_label = Label.new()
	title_label.name = "MenuTitle"
	title_label.text = title_text

	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	title_label.add_theme_font_size_override(
		"font_size",
		title_font_size
	)

	title_label.add_theme_color_override(
		"font_color",
		text_color
	)

	title_label.add_theme_color_override(
		"font_outline_color",
		outline_color
	)

	title_label.add_theme_constant_override(
		"outline_size",
		outline_size
	)

	if menu_font != null:
		title_label.add_theme_font_override(
			"font",
			menu_font
		)

	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(title_label)


# ==================================================
# SPACERS
# ==================================================

func create_spacers() -> void:
	# Add space before High Scores.
	score_spacer = Control.new()
	score_spacer.name = "ScoreSpacer"
	score_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE

	vbox.add_child(score_spacer)
	vbox.move_child(
		score_spacer,
		high_score_label.get_index()
	)

	# Add extra space before Quit.
	quit_spacer = Control.new()
	quit_spacer.name = "QuitSpacer"
	quit_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE

	vbox.add_child(quit_spacer)
	vbox.move_child(
		quit_spacer,
		quit_button.get_index()
	)


# ==================================================
# HIGH SCORES
# ==================================================

func style_high_score_label() -> void:
	high_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	high_score_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	high_score_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	high_score_label.add_theme_font_size_override(
		"font_size",
		high_score_font_size
	)

	high_score_label.add_theme_color_override(
		"font_color",
		text_color
	)

	high_score_label.add_theme_color_override(
		"font_outline_color",
		outline_color
	)

	high_score_label.add_theme_constant_override(
		"outline_size",
		outline_size
	)

	if menu_font != null:
		high_score_label.add_theme_font_override(
			"font",
			menu_font
		)


func update_high_score() -> void:
	var best_level := 0
	var best_time := 0.0

	for key in GameData.high_scores:
		var score := float(GameData.high_scores[key])

		if score > best_time:
			best_time = score
			best_level = int(key)

	if best_level == 0:
		high_score_label.text = "HIGH SCORES\nNO RECORDS YET"
	else:
		high_score_label.text = (
			"HIGH SCORES\nBEST TIME: LEVEL %d — %.1f SECONDS"
			% [best_level, best_time]
		)


# ==================================================
# BUTTON STYLING
# ==================================================

func style_menu_button(button: Button) -> void:
	button.add_theme_stylebox_override(
		"normal",
		create_button_style(
			button_color,
			button_border_color
		)
	)

	button.add_theme_stylebox_override(
		"hover",
		create_button_style(
			button_color.lightened(hover_brightness),
			button_border_color
		)
	)

	button.add_theme_stylebox_override(
		"pressed",
		create_button_style(
			button_color.darkened(pressed_darkness),
			button_border_color
		)
	)

	button.add_theme_stylebox_override(
		"focus",
		StyleBoxEmpty.new()
	)

	if menu_font != null:
		button.add_theme_font_override(
			"font",
			menu_font
		)

	button.add_theme_font_size_override(
		"font_size",
		button_font_size
	)

	button.add_theme_color_override("font_color", text_color)
	button.add_theme_color_override("font_hover_color", text_color)
	button.add_theme_color_override("font_pressed_color", text_color)

	button.add_theme_color_override(
		"font_outline_color",
		outline_color
	)

	button.add_theme_constant_override(
		"outline_size",
		outline_size
	)

	button.alignment = HORIZONTAL_ALIGNMENT_CENTER


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
# FIXED LAYOUT
# ==================================================

func _on_viewport_resized() -> void:
	update_layout()


func update_layout() -> void:
	if not is_inside_tree():
		return

	var viewport_size := get_viewport_rect().size

	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	# Calculate a fixed button size, limited by screen width.
	var final_width := minf(
		button_size.x,
		maxf(1.0, viewport_size.x - screen_margin * 2.0)
	)

	var final_size := Vector2(
		final_width,
		button_size.y
	)

	for button in [
		play_button,
		level_select_button,
		quit_button
	]:
		button.custom_minimum_size = final_size

	# Set the high-score label size.
	high_score_label.custom_minimum_size = Vector2(
		final_width,
		high_score_height
	)

	# Configure spacing.
	vbox.add_theme_constant_override(
		"separation",
		int(button_gap)
	)

	score_spacer.custom_minimum_size = Vector2(
		0.0,
		high_score_spacing
	)

	quit_spacer.custom_minimum_size = Vector2(
		0.0,
		quit_spacing
	)

	# Keep the title centered horizontally.
	title_label.position = Vector2(
		0.0,
		title_top_margin
	)

	title_label.size = Vector2(
		viewport_size.x,
		title_height
	)

	# IMPORTANT:
	# CenterContainer must fill the viewport.
	# Do not manually position the VBoxContainer.
	center_container.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	# Position the VBoxContainer's parent using a top offset.
	# The CenterContainer still controls the VBoxContainer itself.
	var menu_top := (
		title_top_margin
		+ title_height
		+ title_button_spacing
	)

	# Use a top-level Control transform for the menu group.
	center_container.position = Vector2(0.0, menu_top)
	center_container.size = Vector2(
		viewport_size.x,
		maxf(1.0, viewport_size.y - menu_top)
	)


# ==================================================
# REFRESH WHEN RETURNING TO MENU
# ==================================================

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if is_node_ready() and is_visible_in_tree():
			call_deferred("_refresh_menu")


func _refresh_menu() -> void:
	if not is_inside_tree():
		return

	update_high_score()
	update_layout()


# ==================================================
# BUTTON CALLBACKS
# ==================================================

func _on_play_pressed() -> void:
	GameData.selected_level = GameData.unlocked_level
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_level_select_pressed() -> void:
	get_tree().change_scene_to_file(LEVEL_SELECT_SCENE)


func _on_quit_pressed() -> void:
	get_tree().quit()

###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name AdvancedPanelContainer extends PanelContainer

@export var label: String = "advanced":
	set = set_label
@export var accent_color: Color = Color(0.283, 0.124, 0.101, 0.57):
	set = set_accent_color

var _text_buffer: TextLine = TextLine.new()
var _panel: StyleBox = null


func _init() -> void:
	theme_type_variation = &"AdvancedPanelContainer"


func _ready() -> void:
	_update_text_buffer()
	_update_panel()


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_update_text_buffer()
		_update_panel()


func _draw() -> void:
	# Redraw the background with a custom color.
	_panel.draw(get_canvas_item(), Rect2(Vector2.ZERO, size))

	# Draw the label on top.
	var font_color := get_theme_color("font_color")
	var label_offset := Vector2(
		get_theme_constant("label_offset_x"),
		get_theme_constant("label_offset_y")
	)
	var label_position := Vector2(0.0, 0.0 - _text_buffer.get_size().y) + label_offset
	_text_buffer.draw(get_canvas_item(), label_position, font_color)


# Label management.

func set_label(value: String) -> void:
	if label == value:
		return

	label = value
	_update_text_buffer()


func _update_text_buffer() -> void:
	var font := get_theme_font("font")
	var font_size := get_theme_font_size("font_size")

	_text_buffer.clear()
	_text_buffer.add_string(label, font, font_size)
	queue_redraw()


# Color management.

func set_accent_color(value: Color) -> void:
	if accent_color == value:
		return

	accent_color = value
	_update_panel()


func _update_panel() -> void:
	_panel = get_theme_stylebox("panel").duplicate()
	if _panel is StyleBoxFlat:
		_panel.bg_color = accent_color

	queue_redraw()

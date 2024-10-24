###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name OptionFlipper extends MarginContainer

signal selected()

const FLIP_DURATION := 0.12
const JERK_DURATION := 0.04
const BUTTON_DURATION := 0.04
const BUTTON_HOLD := 0.2

@export var options: Array[String] = []:
	set = set_options
@export var option_colors: Array[Color] = []:
	set = set_option_colors
@export var option_text_colors: Array[Color] = []:
	set = set_option_text_colors
@export var selected_index: int = 0:
	set = select_option

var _option_buffers: Array[TextLine] = []
var _selected_transition: float = 0.0

var _button_position: float = 0.0
var _button_hold_position: int = 0
var _button_hold_timer: float = 0.0

var _button_tweener: Tween = null
var _display_tweener: Tween = null

@onready var _flip_button: Button = %FlipButton
@onready var _option_display: Control = %Display


func _ready() -> void:
	_flip_button.button_down.connect(_handle_flip_pressed)
	_flip_button.button_up.connect(_handle_flip_released)

	_flip_button.draw.connect(_draw_flip_button)
	_option_display.draw.connect(_draw_option_display)


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_update_option_buffers()


func _process(delta: float) -> void:
	if _flip_button.button_pressed:
		_button_hold_timer -= delta

		if _button_hold_timer <= 0.0:
			select_option(selected_index + _button_hold_position)
			_button_hold_timer = BUTTON_HOLD


func _draw_flip_button() -> void:
	_flip_button.draw_rect(Rect2(Vector2.ZERO, _flip_button.size), Color.BLACK)


func _draw_option_display() -> void:
	var background_color := get_theme_color("display_color")
	var font_color := get_theme_color("display_font_color")

	_option_display.draw_rect(Rect2(Vector2.ZERO, _option_display.size), background_color)
	var option_size := _option_display.size

	for i in _option_buffers.size():
		var option_offset := Vector2(0.0, option_size.y) * (i - _selected_transition)

		# Draw the background for the buffer, if applicable.
		if option_colors.size() > i:
			var color := option_colors[i]
			_option_display.draw_rect(Rect2(option_offset, option_size), color)

		var option_font_color := font_color
		if option_text_colors.size() > i:
			option_font_color = option_text_colors[i]

		# Draw the text buffer.
		var buffer := _option_buffers[i]
		var label_position := (option_size - buffer.get_size()) / 2.0 + option_offset

		buffer.draw(_option_display.get_canvas_item(), label_position, option_font_color)


func _handle_flip_pressed() -> void:
	var mouse_position := _flip_button.get_local_mouse_position()
	if mouse_position.y < (_flip_button.size.y / 2.0):
		_transition_button(-1.0)
		_button_hold_position = -1
	else:
		_transition_button(1.0)
		_button_hold_position = 1

	select_option(selected_index + _button_hold_position)
	_button_hold_timer = BUTTON_HOLD


func _handle_flip_released() -> void:
	_transition_button(0.0)

	_button_hold_position = 0
	_button_hold_timer = 0.0


# Option management.

func set_options(value: Array[String]) -> void:
	options = value
	_update_option_buffers()


func set_option_colors(value: Array[Color]) -> void:
	option_colors = value

	if is_node_ready():
		_option_display.queue_redraw()


func set_option_text_colors(value: Array[Color]) -> void:
	option_text_colors = value

	if is_node_ready():
		_option_display.queue_redraw()


func _update_option_buffers() -> void:
	var font := get_theme_font("font")
	var font_size := get_theme_font_size("font_size")

	if options.size() < _option_buffers.size():
		_option_buffers.resize(options.size())
	else:
		while options.size() > _option_buffers.size():
			_option_buffers.push_back(TextLine.new())

	for i in options.size():
		var buffer := _option_buffers[i]
		buffer.clear()
		buffer.add_string(options[i], font, font_size)

	if is_node_ready():
		_option_display.queue_redraw()


func select_option(value: int) -> void:
	var normalized_value := clampi(value, 0, options.size() - 1)
	if selected_index == normalized_value:
		if value < 0:
			_transition_selection(selected_index - 1)
		elif value >= options.size():
			_transition_selection(selected_index + 1)
		return

	selected_index = normalized_value
	_transition_selection(selected_index)

	selected.emit()


func _transition_selection(target_offset: float) -> void:
	if not is_node_ready():
		_selected_transition = target_offset
		return

	if is_instance_valid(_display_tweener):
		_display_tweener.kill()

	_display_tweener = create_tween()

	# Trying to flip out of bounds, do a jerk and return to the current value.
	if target_offset < 0 || target_offset >= options.size():
		var current_offset := _selected_transition
		target_offset = current_offset + (target_offset - current_offset) / 2.0

		_display_tweener.tween_method(_tween_selection, current_offset, target_offset, JERK_DURATION)
		_display_tweener.tween_method(_tween_selection, target_offset, current_offset, JERK_DURATION)
	else:
		_display_tweener.tween_method(_tween_selection, _selected_transition, target_offset, FLIP_DURATION)


func _tween_selection(value: float) -> void:
	_selected_transition = value
	_option_display.queue_redraw()


# Button transitions.

func _transition_button(target_position: float) -> void:
	if is_instance_valid(_button_tweener):
		_button_tweener.kill()

	_button_tweener = create_tween()
	_button_tweener.tween_method(_tween_button, _button_position, target_position, BUTTON_DURATION)


func _tween_button(value: float) -> void:
	_button_position = value
	(_flip_button.material as ShaderMaterial).set_shader_parameter("switch_position", value)

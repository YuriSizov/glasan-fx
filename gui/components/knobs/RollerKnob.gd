###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name RollerKnob extends PanelContainer

signal value_changed()

const ROLLER_SHIFTED_FACTOR := 4.0
const ROLLER_SCROLL_FACTOR := 0.01
const VALUE_SCROLL_FACTOR := 1.0

const SCROLL_RESET_DURATION := 0.12

@export_multiline var text: String = "XX":
	set = set_text

@export var knob_value: int = 0:
	set = set_knob_value
@export var min_value: int = 0:
	set = set_min_value
@export var max_value: int = 1:
	set = set_max_value
@export var safe_min_value: int = 0:
	set = set_safe_min_value
@export var safe_max_value: int = 1:
	set = set_safe_max_value

@onready var _name_label: Label = %NameLabel
@onready var _value_back: Control = %Value
@onready var _value_bar: Control = %ValueBar
@onready var _value_overlay: Control = %ValueOverlay
@onready var _roller_control: Control = %Roller

var _value_buffers: Array[TextLine] = []
var _value_scroll: float = 0.0
var _value_scroll_step: float = 0.0

var _pressed: bool = false
var _dragged: bool = false
var _drag_accumulator: Vector2 = Vector2.ZERO

var _scroll_tweener: Tween = null


func _ready() -> void:
	_update_name_label()
	_update_value_scroll_step()

	_create_value_buffers()
	_update_value_buffers()

	_value_back.draw.connect(_draw_value_back)
	_value_bar.draw.connect(_draw_value_bar)
	_value_bar.resized.connect(_update_value_scroll_step)
	_value_overlay.draw.connect(_draw_value_overlay)
	_roller_control.draw.connect(_draw_roller)
	_roller_control.gui_input.connect(_gui_input_roller)


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		if is_node_ready():
			_name_label.add_theme_color_override("font_color", get_theme_color("label_color"))
			_value_back.queue_redraw()
			_value_bar.queue_redraw()

		_update_value_buffers()

	elif what == NOTIFICATION_EDITOR_PRE_SAVE:
		_name_label.remove_theme_color_override("font_color")
	elif what == NOTIFICATION_EDITOR_POST_SAVE:
		_name_label.add_theme_color_override("font_color", get_theme_color("label_color"))


# Drawing subroutines.

func _draw_value_back() -> void:
	_value_back.draw_rect(Rect2(Vector2.ZERO, _value_back.size), Color.BLACK)

	# Draw safe margins, if applicable.

	var margin_color := get_theme_color("unsafe_margin_color")
	var position_step := Vector2(_value_scroll_step, 0.0)
	var index_offset := knob_value - min_value

	if safe_min_value > min_value:
		var value_span := safe_min_value - min_value
		var value_index := value_span

		var margin_size := Vector2(_value_scroll_step, _value_back.size.y) * value_span
		var margin_position := position_step * (value_index - index_offset + 0.5) + Vector2(_value_scroll, 0)
		margin_position.x -= margin_size.x

		_value_back.draw_rect(Rect2(margin_position, margin_size), margin_color)

	if safe_max_value < max_value:
		var value_span := max_value - safe_max_value
		var value_index := safe_max_value - min_value

		var margin_size := Vector2(_value_scroll_step, _value_back.size.y) * value_span
		var margin_position := position_step * (value_index - index_offset + 1.5) + Vector2(_value_scroll, 0)

		_value_back.draw_rect(Rect2(margin_position, margin_size), margin_color)


func _draw_value_bar() -> void:
	var font_color := get_theme_color("value_color")
	var position_step := Vector2(_value_scroll_step, 0.0)
	var index_offset := knob_value - min_value

	for i in _value_buffers.size():
		var buffer := _value_buffers[i]
		var buffer_position := (_value_bar.size - buffer.get_size()) / 2.0
		buffer_position += position_step * (i - index_offset) + Vector2(_value_scroll, 0)

		if buffer_position.x > size.x || (buffer_position.x + buffer.get_size().x) < 0.0:
			continue

		buffer.draw(_value_bar.get_canvas_item(), buffer_position, font_color)


func _draw_value_overlay() -> void:
	_value_overlay.draw_rect(Rect2(Vector2.ZERO, _value_overlay.size), Color.WHITE)


func _draw_roller() -> void:
	_roller_control.draw_rect(Rect2(Vector2.ZERO, _roller_control.size), Color.WHITE)


# Input subroutines.

func _input(event: InputEvent) -> void:
	if not _pressed && not _dragged:
		return

	_gui_input_roller(event)
	accept_event()


func _gui_input_roller(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton

		if mb.button_index == MOUSE_BUTTON_LEFT && mb.pressed:
			_pressed = true
		elif mb.button_index == MOUSE_BUTTON_LEFT && not mb.pressed:
			if _dragged:
				_update_value_after_scroll()
			elif _pressed:
				_update_value_on_click()
			else:
				_drag_accumulator = Vector2.ZERO
				_update_scrollables()

			_pressed = false
			_dragged = false

	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion

		if _pressed:
			var drag_relative := mm.relative
			if Input.is_key_pressed(KEY_SHIFT):
				drag_relative *= ROLLER_SHIFTED_FACTOR

			_drag_accumulator += drag_relative

			if not _dragged && _drag_accumulator.length_squared() > 48.0:
				_dragged = true

			if _dragged:
				_update_scrollables()


func _update_scrollables() -> void:
	var raw_scroll := _drag_accumulator.x

	var roller_scroll := fmod(raw_scroll * ROLLER_SCROLL_FACTOR, 2.0)
	(_roller_control.material as ShaderMaterial).set_shader_parameter("scroll", roller_scroll)

	_value_scroll = raw_scroll * VALUE_SCROLL_FACTOR
	_value_back.queue_redraw()
	_value_bar.queue_redraw()


func _update_value_after_scroll() -> void:
	var values_passed := -1 * roundi(_value_scroll / _value_scroll_step)
	_update_value(knob_value + values_passed)


func _update_value_on_click() -> void:
	var mouse_position := _roller_control.get_local_mouse_position()
	if mouse_position.x > (_roller_control.size.x / 2.0):
		_update_value(knob_value + 1)
	else:
		_update_value(knob_value - 1)


func _update_value(value: int) -> void:
	knob_value = clampi(value, min_value, max_value)
	value_changed.emit()


func _animate_scroll_to_zero() -> void:
	if is_instance_valid(_scroll_tweener):
		_scroll_tweener.kill()

	_scroll_tweener = create_tween()
	_scroll_tweener.tween_method(_update_drag_accumulator, _drag_accumulator, Vector2.ZERO, SCROLL_RESET_DURATION)


func _update_drag_accumulator(value: Vector2) -> void:
	_drag_accumulator = value
	_update_scrollables()


# Properties.

func set_text(value: String) -> void:
	if text == value:
		return

	text = value
	_update_name_label()


func _update_name_label() -> void:
	if not is_node_ready():
		return

	_name_label.text = text


func set_knob_value(value: int) -> void:
	if knob_value == value:
		if is_node_ready():
			_animate_scroll_to_zero()
		return

	var old_value := knob_value
	knob_value = value

	if is_node_ready():
		_value_back.queue_redraw()
		_value_bar.queue_redraw()

		var actually_passed := knob_value - old_value
		_drag_accumulator.x += actually_passed * _value_scroll_step
		_animate_scroll_to_zero()


func set_min_value(value: int) -> void:
	if min_value == value:
		return

	min_value = value

	if is_node_ready():
		_create_value_buffers()
		_update_value_buffers()


func set_max_value(value: int) -> void:
	if max_value == value:
		return

	max_value = value

	if is_node_ready():
		_create_value_buffers()
		_update_value_buffers()


func set_safe_min_value(value: int) -> void:
	if safe_min_value == value:
		return

	safe_min_value = value

	if is_node_ready():
		_value_back.queue_redraw()


func set_safe_max_value(value: int) -> void:
	if safe_max_value == value:
		return

	safe_max_value = value

	if is_node_ready():
		_value_back.queue_redraw()


# Value management and text buffers.

func _create_value_buffers() -> void:
	_value_buffers.clear()

	var total_values = (max_value - min_value) + 1

	for i in total_values:
		var buffer := TextLine.new()
		_value_buffers.push_back(buffer)


func _update_value_buffers() -> void:
	var font := get_theme_font("font")
	var font_size := get_theme_font_size("value_size")

	var value := min_value
	for buffer in _value_buffers:
		buffer.clear()
		buffer.add_string("%d" % value, font, font_size)

		value += 1

	if is_node_ready():
		_value_bar.queue_redraw()


func _update_value_scroll_step() -> void:
	_value_scroll_step = _value_bar.size.x * 0.46

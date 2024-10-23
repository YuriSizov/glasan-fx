###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name TunerSlider extends MarginContainer

const SLIDER_DURATION := 0.08
const SLIDER_SAFEZONE := 0.2

signal value_changed()

@export var slider_value: float = 0.0:
	set = set_slider_value

@export var left_icon: Texture2D = null:
	set = set_left_icon
@export var right_icon: Texture2D = null:
	set = set_right_icon
@export var left_text: String = "L":
	set = set_left_text
@export var right_text: String = "R":
	set = set_right_text

var _pressed: bool = false
var _dragged: bool = false
var _drag_accumulator: Vector2 = Vector2.ZERO
var _knob_value: float = 0.0

var _slider_tweener: Tween = null

@onready var _slider: Control = %Slider
@onready var _left_icon_rect: TextureRect = %LeftIcon
@onready var _right_icon_rect: TextureRect = %RightIcon
@onready var _left_label: Label = %LeftLabel
@onready var _right_label: Label = %RightLabel


func _ready() -> void:
	_update_icons()
	_update_labels()
	_update_shader_size()
	_update_slider_knob(slider_value)

	_slider.draw.connect(_draw_slider)
	_slider.resized.connect(_update_shader_size)


func _draw_slider() -> void:
	_slider.draw_rect(Rect2(Vector2.ZERO, _slider.size), Color.BLACK)


# Input handling.

func _input(event: InputEvent) -> void:
	if not _pressed && not _dragged:
		return

	_gui_input(event)
	accept_event()


func _gui_input(event: InputEvent) -> void:
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

			_pressed = false
			_dragged = false

	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion

		if _pressed:
			_drag_accumulator += mm.relative

			if _drag_accumulator.length_squared() > 48.0:
				_dragged = true

			if _dragged:
				_update_value_on_scroll()


func _get_value_at_mouse() -> float:
	var effective_size := _slider.size.x * (1.0 - SLIDER_SAFEZONE)
	var safezone_size := _slider.size.x * SLIDER_SAFEZONE
	var mouse_position := _slider.get_local_mouse_position().x - safezone_size / 2.0

	return clampf(mouse_position / effective_size, 0.0, 1.0)


func _update_value_on_scroll() -> void:
	var dragged_value := _get_value_at_mouse()
	_update_slider_knob(dragged_value)


func _update_value_after_scroll() -> void:
	slider_value = _knob_value
	value_changed.emit()


func _update_value_on_click() -> void:
	slider_value = _get_value_at_mouse()
	value_changed.emit()


func _animate_slider_knob() -> void:
	if is_instance_valid(_slider_tweener):
		_slider_tweener.kill()

	_slider_tweener = create_tween()
	_slider_tweener.tween_method(_update_slider_knob, _knob_value, slider_value, SLIDER_DURATION)


func _update_slider_knob(value: float) -> void:
	_knob_value = value

	var knob_position := value * 2.0 - 1.0
	(_slider.material as ShaderMaterial).set_shader_parameter("knob_position", knob_position)


# Properties.

func set_slider_value(value: float) -> void:
	var normalized_value := clampf(value, 0.0, 1.0)
	if slider_value == normalized_value:
		return

	slider_value = normalized_value

	if is_node_ready():
		_animate_slider_knob()


func set_value_normalized(value: int, min_value: int, max_value: int) -> void:
	slider_value = (value - min_value) / float(max_value - min_value)


func get_normalized_value(min_value: int, max_value: int) -> int:
	return int(slider_value * (max_value - min_value)) + min_value


func set_left_icon(value: Texture2D) -> void:
	if left_icon == value:
		return

	left_icon = value
	_update_icons()


func set_right_icon(value: Texture2D) -> void:
	if right_icon == value:
		return

	right_icon = value
	_update_icons()


func set_left_text(value: String) -> void:
	if left_text == value:
		return

	left_text = value
	_update_labels()


func set_right_text(value: String) -> void:
	if right_text == value:
		return

	right_text = value
	_update_labels()


# Visuals management.

func _update_icons() -> void:
	if not is_node_ready():
		return

	_left_icon_rect.texture = left_icon
	_left_icon_rect.visible = is_instance_valid(left_icon)
	_right_icon_rect.texture = right_icon
	_right_icon_rect.visible = is_instance_valid(right_icon)


func _update_labels() -> void:
	if not is_node_ready():
		return

	_left_label.text = left_text
	_left_label.visible = not left_text.is_empty()
	_right_label.text = right_text
	_right_label.visible = not right_text.is_empty()


func _update_shader_size() -> void:
	if not is_node_ready():
		return

	(_slider.material as ShaderMaterial).set_shader_parameter("slider_size", _slider.size)

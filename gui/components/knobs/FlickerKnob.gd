###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name FlickerKnob extends MarginContainer

signal value_changed()

const FLICK_DURATION := 0.08

@export var flicker_value: bool = false:
	set = set_flicker_value
@export var on_text: String = "ON":
	set = set_on_text
@export var off_text: String = "OFF":
	set = set_off_text
@export var on_color: Color = Color.GREEN:
	set = set_on_color
@export var off_color: Color = Color.RED:
	set = set_off_color

var _pressed: bool = false
var _dragged: bool = false
var _drag_accumulator: Vector2 = Vector2.ZERO
var _drag_start_position: Vector2 = Vector2.ZERO

var _flicker_tweener: Tween = null
var _flicker_position: float = 0.0

@onready var _flicker_control: Control = %Flicker
@onready var _on_label: Label = %OnLabel
@onready var _off_label: Label = %OffLabel


func _ready() -> void:
	_update_flicker_size()
	_animate_flicker()
	_update_labels()

	_flicker_control.draw.connect(_draw_flicker_control)
	_flicker_control.resized.connect(_update_flicker_size)


func _draw_flicker_control() -> void:
	_flicker_control.draw_rect(Rect2(Vector2.ZERO, _flicker_control.size), Color.BLACK)


func _update_flicker_size() -> void:
	if not is_node_ready():
		return

	(_flicker_control.material as ShaderMaterial).set_shader_parameter("control_size", _flicker_control.size)


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

			_drag_accumulator = Vector2.ZERO
			_drag_start_position = Vector2.ZERO
			_pressed = false
			_dragged = false

	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion

		if _pressed:
			_drag_accumulator += mm.relative

			if not _dragged && _drag_accumulator.length_squared() > 48.0:
				_dragged = true
				_drag_start_position = get_local_mouse_position()

			if _dragged:
				_update_value_on_scroll()


func _update_value_on_scroll() -> void:
	var base_value := 1.0 - float(flicker_value)
	var dragged_distance := get_local_mouse_position() - _drag_start_position
	var maximum_distance := _flicker_control.size.y * 0.6

	var dragged_value := clampf(base_value + dragged_distance.y / maximum_distance, 0.0, 1.0)
	_update_flicker_position(dragged_value)


func _update_value_after_scroll() -> void:
	flicker_value = (_flicker_position < 0.5)
	value_changed.emit()


func _update_value_on_click() -> void:
	flicker_value = not flicker_value
	value_changed.emit()


# Properties.

func set_flicker_value(value: bool) -> void:
	if flicker_value == value:
		_animate_flicker()
		return

	flicker_value = value
	_animate_flicker()


func _animate_flicker() -> void:
	if not is_node_ready():
		return

	if is_instance_valid(_flicker_tweener):
		_flicker_tweener.kill()

	_flicker_tweener = create_tween()
	_flicker_tweener.tween_method(_update_flicker_position, _flicker_position, 0.0 if flicker_value else 1.0, FLICK_DURATION)


func _update_flicker_position(value: float) -> void:
	_flicker_position = value
	var rim_color = on_color.lerp(off_color, _flicker_position)

	(_flicker_control.material as ShaderMaterial).set_shader_parameter("position", _flicker_position * 2.0 - 1.0)
	(_flicker_control.material as ShaderMaterial).set_shader_parameter("rim_color", rim_color)


func set_on_text(value: String) -> void:
	if on_text == value:
		return

	on_text = value
	_update_labels()


func set_off_text(value: String) -> void:
	if off_text == value:
		return

	off_text = value
	_update_labels()


func _update_labels() -> void:
	if not is_node_ready():
		return

	_on_label.text = on_text
	_off_label.text = off_text


func set_on_color(value: Color) -> void:
	if on_color == value:
		return

	on_color = value
	_update_flicker_color()


func set_off_color(value: Color) -> void:
	if off_color == value:
		return

	off_color = value
	_update_flicker_color()


func _update_flicker_color() -> void:
	if not is_node_ready():
		return

	var rim_color = on_color.lerp(off_color, _flicker_position)
	(_flicker_control.material as ShaderMaterial).set_shader_parameter("rim_color", rim_color)

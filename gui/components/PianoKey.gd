###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name PianoKey extends ColorRect

const PRESSED_DURATION := 0.1

@export var base_width: float = 24.0
@export var inset_left: bool = false:
	set = set_inset_left
@export var inset_right: bool = false:
	set = set_inset_right

const LIGHT_COLOR := Color(1.0, 0.98, 0.95)
const DARK_COLOR := Color(0.35, 0.36, 0.38)

var _pressed: bool = false

var _pressed_tweener: Tween = null
var _pressed_value: float = 0.0


func _ready() -> void:
	_set_pressed(false)
	mouse_exited.connect(_set_pressed.bind(false))


func _notification(what: int) -> void:
	if what == NOTIFICATION_ENTER_TREE:
		_update_color()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton

		if mb.button_index == MOUSE_BUTTON_LEFT:
			_set_pressed(mb.pressed)
			accept_event()

	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && not _pressed:
			_set_pressed(true)
			accept_event()


func _get_minimum_size() -> Vector2:
	if not is_inside_tree():
		return Vector2.ZERO

	var child_index = get_index()
	return Vector2(base_width, 0.0) if Note.is_note_sharp(child_index) else Vector2(base_width * 1.5, 0.0)


# Properties.

func set_inset_left(value: bool) -> void:
	if inset_left == value:
		return

	inset_left = value
	_update_insets()

func set_inset_right(value: bool) -> void:
	if inset_right == value:
		return

	inset_right = value
	_update_insets()


func _update_color() -> void:
	var child_index = get_index()
	if Note.is_note_sharp(child_index):
		color = DARK_COLOR
		(material as ShaderMaterial).set_shader_parameter("shadow_compensation", 0.05)
	else:
		color = LIGHT_COLOR
		(material as ShaderMaterial).set_shader_parameter("shadow_compensation", 0.0)


func _update_insets() -> void:
	(material as ShaderMaterial).set_shader_parameter("inset_left", inset_left)
	(material as ShaderMaterial).set_shader_parameter("inset_right", inset_right)


# State management.

func _set_pressed(value: bool) -> void:
	if _pressed == value:
		return

	_pressed = value
	_animate_pressed()


func _animate_pressed() -> void:
	if is_instance_valid(_pressed_tweener):
		_pressed_tweener.kill()

	_pressed_tweener = create_tween()
	_pressed_tweener.tween_method(_tween_pressed, _pressed_value, float(_pressed), PRESSED_DURATION)


func _tween_pressed(value: float) -> void:
	_pressed_value = value
	(material as ShaderMaterial).set_shader_parameter("state_pressed", _pressed_value)
###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name OperatorIndicator extends HBoxContainer

const LABEL_DURATION := 0.2

@export_range(0, 4) var operator_count: int = 0:
	set = set_operator_count

var _label_tweener: Tween = null
var _intensity_values: Dictionary = {}

@onready var _a_label: Label = %ALabel
@onready var _b_label: Label = %BLabel
@onready var _c_label: Label = %CLabel
@onready var _d_label: Label = %DLabel

@onready var _a2b_label: Label = %A2BLabel
@onready var _b2c_label: Label = %B2CLabel
@onready var _c2d_label: Label = %C2DLabel


func _ready() -> void:
	_intensity_values[_a_label] = 0.0
	_intensity_values[_b_label] = 0.0
	_intensity_values[_c_label] = 0.0
	_intensity_values[_d_label] = 0.0
	_intensity_values[_a2b_label] = 0.0
	_intensity_values[_b2c_label] = 0.0
	_intensity_values[_c2d_label] = 0.0

	_setup_labels()
	_update_labels()


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_update_labels()
	elif what == NOTIFICATION_EDITOR_PRE_SAVE:
		_clear_labels()
	elif what == NOTIFICATION_EDITOR_POST_SAVE:
		_update_labels()


func set_operator_count(value: int) -> void:
	if operator_count == value:
		return

	operator_count = value
	_update_label_state()


func _setup_labels() -> void:
	if not is_node_ready():
		return

	# Give it proper initial color before transitioning to the actual state.
	# This removes flickering that would appear otherwise.
	var inactive_color := get_theme_color("font_inactive_color")

	_a_label.self_modulate   = inactive_color
	_b_label.self_modulate   = inactive_color
	_c_label.self_modulate   = inactive_color
	_d_label.self_modulate   = inactive_color
	_a2b_label.self_modulate = inactive_color
	_b2c_label.self_modulate = inactive_color
	_c2d_label.self_modulate = inactive_color


func _update_labels() -> void:
	if not is_node_ready():
		return

	var font_size := get_theme_font_size("font_size")

	_a_label.add_theme_font_size_override("font_size",   font_size)
	_a2b_label.add_theme_font_size_override("font_size", font_size)
	_b_label.add_theme_font_size_override("font_size",   font_size)
	_b2c_label.add_theme_font_size_override("font_size", font_size)
	_c_label.add_theme_font_size_override("font_size",   font_size)
	_c2d_label.add_theme_font_size_override("font_size", font_size)
	_d_label.add_theme_font_size_override("font_size",   font_size)

	_update_label_state()


func _clear_labels() -> void:
	if not is_node_ready():
		return

	_a_label.remove_theme_font_size_override("font_size")
	_a2b_label.remove_theme_font_size_override("font_size")
	_b_label.remove_theme_font_size_override("font_size")
	_b2c_label.remove_theme_font_size_override("font_size")
	_c_label.remove_theme_font_size_override("font_size")
	_c2d_label.remove_theme_font_size_override("font_size")
	_d_label.remove_theme_font_size_override("font_size")

	_a_label.self_modulate   = Color.WHITE
	_b_label.self_modulate   = Color.WHITE
	_c_label.self_modulate   = Color.WHITE
	_d_label.self_modulate   = Color.WHITE
	_a2b_label.self_modulate = Color.WHITE
	_b2c_label.self_modulate = Color.WHITE
	_c2d_label.self_modulate = Color.WHITE

	(_a_label.material as ShaderMaterial).set_shader_parameter("intensity",   0.0)
	(_a2b_label.material as ShaderMaterial).set_shader_parameter("intensity", 0.0)
	(_b_label.material as ShaderMaterial).set_shader_parameter("intensity",   0.0)
	(_b2c_label.material as ShaderMaterial).set_shader_parameter("intensity", 0.0)
	(_c_label.material as ShaderMaterial).set_shader_parameter("intensity",   0.0)
	(_c2d_label.material as ShaderMaterial).set_shader_parameter("intensity", 0.0)
	(_d_label.material as ShaderMaterial).set_shader_parameter("intensity",   0.0)


func _update_label_state() -> void:
	if not is_node_ready():
		return

	if is_instance_valid(_label_tweener):
		_label_tweener.kill()

	_label_tweener = create_tween()
	_label_tweener.set_parallel(true)

	# Update the colors based on the number of active operators.

	var active_color := get_theme_color("font_active_color")
	var inactive_color := get_theme_color("font_inactive_color")
	var label_intensity := get_theme_constant("label_intensity") / 100.0

	_label_tweener.tween_property(_a_label,   "self_modulate", active_color if operator_count >= 1 else inactive_color, LABEL_DURATION)
	_label_tweener.tween_property(_a2b_label, "self_modulate", active_color if operator_count >= 2 else inactive_color, LABEL_DURATION)
	_label_tweener.tween_property(_b_label,   "self_modulate", active_color if operator_count >= 2 else inactive_color, LABEL_DURATION)
	_label_tweener.tween_property(_b2c_label, "self_modulate", active_color if operator_count >= 3 else inactive_color, LABEL_DURATION)
	_label_tweener.tween_property(_c_label,   "self_modulate", active_color if operator_count >= 3 else inactive_color, LABEL_DURATION)
	_label_tweener.tween_property(_c2d_label, "self_modulate", active_color if operator_count >= 4 else inactive_color, LABEL_DURATION)
	_label_tweener.tween_property(_d_label,   "self_modulate", active_color if operator_count >= 4 else inactive_color, LABEL_DURATION)

	_label_tweener.tween_method(_tween_shader_param.bind(_a_label),   _intensity_values[_a_label],   label_intensity if operator_count >= 1 else 0.0, LABEL_DURATION)
	_label_tweener.tween_method(_tween_shader_param.bind(_a2b_label), _intensity_values[_a2b_label], label_intensity if operator_count >= 2 else 0.0, LABEL_DURATION)
	_label_tweener.tween_method(_tween_shader_param.bind(_b_label),   _intensity_values[_b_label],   label_intensity if operator_count >= 2 else 0.0, LABEL_DURATION)
	_label_tweener.tween_method(_tween_shader_param.bind(_b2c_label), _intensity_values[_b2c_label], label_intensity if operator_count >= 3 else 0.0, LABEL_DURATION)
	_label_tweener.tween_method(_tween_shader_param.bind(_c_label),   _intensity_values[_c_label],   label_intensity if operator_count >= 3 else 0.0, LABEL_DURATION)
	_label_tweener.tween_method(_tween_shader_param.bind(_c2d_label), _intensity_values[_c2d_label], label_intensity if operator_count >= 4 else 0.0, LABEL_DURATION)
	_label_tweener.tween_method(_tween_shader_param.bind(_d_label),   _intensity_values[_d_label],   label_intensity if operator_count >= 4 else 0.0, LABEL_DURATION)


func _tween_shader_param(value: float, label: Label) -> void:
	_intensity_values[label] = value
	(label.material as ShaderMaterial).set_shader_parameter("intensity", value)

###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name ElectronicLabel extends PanelContainer

const TRANSITION_DURATION := 0.12

@export var text: String = "":
	set = set_text

var _label_tweener: Tween = null

@onready var _label: Label = %Label


func _ready() -> void:
	_update_theme()
	_update_label()


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_update_theme()
	elif what == NOTIFICATION_EDITOR_PRE_SAVE:
		_clear_theme()
	elif what == NOTIFICATION_EDITOR_POST_SAVE:
		_update_theme()


func _update_theme() -> void:
	if not is_node_ready():
		return

	_label.add_theme_color_override("font_color", get_theme_color("font_color"))
	_label.add_theme_font_override("font", get_theme_font("font"))
	_label.add_theme_font_size_override("font_size", get_theme_font_size("font_size"))

	(_label.material as ShaderMaterial).set_shader_parameter("intensity", get_theme_constant("full_intensity") / 100.0)


func _clear_theme() -> void:
	if not is_node_ready():
		return

	_label.remove_theme_color_override("font_color")
	_label.remove_theme_font_override("font")
	_label.remove_theme_font_size_override("font_size")

	(_label.material as ShaderMaterial).set_shader_parameter("intensity", 0.0)


# Text property.

func set_text(value: String) -> void:
	if text == value:
		return

	text = value
	_animate_text_changes()


func _update_label() -> void:
	if not is_node_ready():
		return

	_label.text = text


func _animate_text_changes() -> void:
	if not is_node_ready():
		return

	if is_instance_valid(_label_tweener):
		_label_tweener.kill()

	_label_tweener = create_tween()
	_label_tweener.tween_method(_tween_text_visibility, _label.self_modulate.a, 0.0, TRANSITION_DURATION)
	_label_tweener.tween_callback(_update_label)
	_label_tweener.tween_method(_tween_text_visibility, 0.0, 1.0, TRANSITION_DURATION)


func _tween_text_visibility(value: float) -> void:
	_label.self_modulate.a = value

	var full_intensity := get_theme_constant("full_intensity") / 100.0
	(_label.material as ShaderMaterial).set_shader_parameter("intensity", value * full_intensity)

###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name ContentPanel extends PanelContainer

@onready var _background: Panel = %Background
@onready var _content: MarginContainer = %Content


func _ready() -> void:
	_update_theme()
	_update_shader_params()

	resized.connect(_update_shader_params)


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

	var background_panel := get_theme_stylebox("panel_background")
	_background.add_theme_stylebox_override("panel", background_panel)
	_content.add_theme_constant_override("margin_left",   int(background_panel.content_margin_left))
	_content.add_theme_constant_override("margin_top",    int(background_panel.content_margin_top))
	_content.add_theme_constant_override("margin_right",  int(background_panel.content_margin_right))
	_content.add_theme_constant_override("margin_bottom", int(background_panel.content_margin_bottom))

	(_background.material as ShaderMaterial).set_shader_parameter("light_intensity", get_theme_constant("light_intensity") / 1000.0)
	(_background.material as ShaderMaterial).set_shader_parameter("border_width", get_theme_constant("border_width"))


func _clear_theme() -> void:
	if not is_node_ready():
		return

	_background.remove_theme_stylebox_override("panel")
	_content.remove_theme_constant_override("margin_left")
	_content.remove_theme_constant_override("margin_top")
	_content.remove_theme_constant_override("margin_right")
	_content.remove_theme_constant_override("margin_bottom")

	(_background.material as ShaderMaterial).set_shader_parameter("light_intensity", 0.0)
	(_background.material as ShaderMaterial).set_shader_parameter("border_width", 0)


func _update_shader_params() -> void:
	if not is_node_ready():
		return

	(_background.material as ShaderMaterial).set_shader_parameter("size", size)

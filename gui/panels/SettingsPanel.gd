###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name SettingsPanel extends ContentPanel

@onready var _scale_100_button: GlowButton = %Scale100Button
@onready var _scale_125_button: GlowButton = %Scale125Button
@onready var _scale_150_button: GlowButton = %Scale150Button
@onready var _scale_200_button: GlowButton = %Scale200Button


func _ready() -> void:
	super()
	_update_settings_controls()

	if not Engine.is_editor_hint():
		_scale_100_button.pressed.connect(Controller.settings_manager.set_gui_scale.bind(100))
		_scale_125_button.pressed.connect(Controller.settings_manager.set_gui_scale.bind(125))
		_scale_150_button.pressed.connect(Controller.settings_manager.set_gui_scale.bind(150))
		_scale_200_button.pressed.connect(Controller.settings_manager.set_gui_scale.bind(200))


# Settings management.

func _update_settings_controls() -> void:
	if Engine.is_editor_hint():
		return

	var gui_scale := Controller.settings_manager.get_gui_scale()

	_scale_100_button.button_pressed = (gui_scale == 100)
	_scale_125_button.button_pressed = (gui_scale == 125)
	_scale_150_button.button_pressed = (gui_scale == 150)
	_scale_200_button.button_pressed = (gui_scale == 200)

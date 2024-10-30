###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name MenuPanel extends ContentPanel

signal settings_toggled()
signal about_toggled()

@onready var _save_button: Button = %SaveButton
@onready var _load_button: Button = %LoadButton
@onready var _export_button: Button = %ExportButton

@onready var _settings_button: Button = %SettingsButton
@onready var _about_button: Button = %AboutButton


func _ready() -> void:
	super()

	if not Engine.is_editor_hint():
		_save_button.pressed.connect(Controller.save_to_file)
		_load_button.pressed.connect(Controller.load_from_file)
		_export_button.pressed.connect(Controller.export_sample)

		_settings_button.pressed.connect(settings_toggled.emit)
		_about_button.pressed.connect(about_toggled.emit)

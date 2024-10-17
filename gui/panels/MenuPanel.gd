###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name MenuPanel extends ContentPanel

@onready var _save_button: Button = %SaveButton
@onready var _load_button: Button = %LoadButton
@onready var _export_button: Button = %ExportButton


func _ready() -> void:
	super()

	if not Engine.is_editor_hint():
		_save_button.pressed.connect(Controller.save_to_file)
		_load_button.pressed.connect(Controller.load_from_file)
		_export_button.pressed.connect(Controller.export_sample)
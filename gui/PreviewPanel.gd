###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name PreviewPanel extends MarginContainer

@onready var _preview_area: Control = %PreviewArea
@onready var _preview_button: Button = %PreviewButton


func _ready() -> void:
	_preview_button.pressed.connect(_update_preview)


func _update_preview() -> void:
	Controller.voice_manager.play_note()

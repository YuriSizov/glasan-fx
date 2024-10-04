###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name PreviewPanel extends MarginContainer

var _current_sample: Sample = null

@onready var _preview_button: Button = %PreviewButton
@onready var _length_knob_control: KnobControl = %LengthKnob
@onready var _note_knob_control: KnobControl = %NoteKnob


func _ready() -> void:
	_preview_button.pressed.connect(_play_sample)

	_edit_current_sample()
	Controller.voice_manager.sample_changed.connect(_edit_current_sample)


func _edit_current_sample() -> void:
	_current_sample = Controller.voice_manager.get_sample_params()

	_length_knob_control.knob_data = _current_sample.length
	_note_knob_control.knob_data = _current_sample.note


func _play_sample() -> void:
	Controller.voice_manager.play_sample()

###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name PreviewPanel extends ContentPanel

var _current_sample: Sample = null

@onready var _preview_area: PreviewArea = %PreviewArea
@onready var _preview_button: GlowButton = %PreviewButton
@onready var _spectrum_mode_button: GlowButton = %SpectrumButton
@onready var _wave_mode_button: GlowButton = %WaveButton

@onready var _length_knob_control: KnobControl = %LengthKnob
@onready var _piano_roll: PianoRoll = %PianoRoll


func _ready() -> void:
	super()
	_edit_current_sample()

	if not Engine.is_editor_hint():
		_preview_button.pressed.connect(_play_sample)
		_spectrum_mode_button.pressed.connect(_preview_area.change_preview_style.bind(PreviewArea.PreviewStyle.PREVIEW_SPECTRUM))
		_wave_mode_button.pressed.connect(_preview_area.change_preview_style.bind(PreviewArea.PreviewStyle.PREVIEW_WAVE))
		_piano_roll.note_changed.connect(_change_note)

		Controller.voice_manager.sample_changed.connect(_edit_current_sample)


# Sample management.

func _edit_current_sample() -> void:
	if Engine.is_editor_hint():
		return

	_current_sample = Controller.voice_manager.get_sample_params()

	_length_knob_control.knob_data = _current_sample.length
	_piano_roll.note_value = _current_sample.note.value


func _play_sample() -> void:
	Controller.voice_manager.play_sample()


func _change_note() -> void:
	_current_sample.note.value = _piano_roll.note_value
	_play_sample()

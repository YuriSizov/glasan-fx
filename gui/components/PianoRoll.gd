###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name PianoRoll extends MarginContainer

signal note_changed()

var note_value: int = -1:
	set = set_note_value

var _octave_value: int = 1

@onready var _piano_container: PianoContainer = %PianoContainer

@onready var _octave_up_button: GlowButton = %UpOctaveButton
@onready var _octave_down_button: GlowButton = %DownOctaveButton
@onready var _octave_label: Label = %OctaveLabel


func _ready() -> void:
	_update_octave_label()

	_piano_container.key_pressed.connect(_change_note)
	_octave_up_button.pressed.connect(_shift_octave.bind(1))
	_octave_down_button.pressed.connect(_shift_octave.bind(-1))


func set_note_value(value: int) -> void:
	if note_value == value:
		return

	# There are technically only 128 note values allowed, but for simplicity we
	# don't reflect that in the UI. The last few notes in the last octave are just
	# clamped behind the scenes to the largest allowed value.

	note_value = value
	if note_value >= 0:
		_octave_value = int(note_value / float(Note.MAX)) + 1
	else:
		_octave_value = 1

	_update_octave_label()
	_update_selected_note()


func _change_note(raw_value: int) -> void:
	note_value = raw_value + (_octave_value - 1) * Note.MAX
	note_changed.emit()


func _shift_octave(delta: int) -> void:
	var value := clampi(_octave_value + delta, 1, Note.MAX_OCTAVES)
	if _octave_value == value:
		return

	_octave_value = value
	_update_octave_label()
	_update_selected_note()


# Widget management.

func _update_selected_note() -> void:
	if not is_node_ready():
		return

	_piano_container.selected_key = note_value - (_octave_value - 1) * Note.MAX


func _update_octave_label() -> void:
	if not is_node_ready():
		return

	_octave_label.text = "%02d" % [ _octave_value ]

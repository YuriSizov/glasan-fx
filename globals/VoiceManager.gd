###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name VoiceManager extends RefCounted

signal voice_changed()
signal sample_changed()

const MIN_NOTE_LENGTH := 2
const MAX_NOTE_LENGTH := 16
const DEFAULT_NOTE_LENGTH := 8
const MIN_NOTE_VALUE := 0
const MAX_NOTE_VALUE := 127
const DEFAULT_NOTE_VALUE := 42

## SiON tool with a bunch of pre-configured voices.
var _preset_util: SiONVoicePresetUtil = null

var _driver: SiONDriver = null
var _voices: Array[Voice] = []
var _current_voice: Voice = null
var _current_sample: Sample = null

var _off_timer: int = -1


func _init(controller: Node) -> void:
	_driver = SiONDriver.create(controller.buffer_size)
	_driver.ready.connect(_initialize_driver)
	controller.add_child(_driver)

	_initialize_voices()
	_current_sample = Sample.new()

	print("Created synthesizer driver (v%s-%s)" % [ SiONDriver.get_version(), SiONDriver.get_version_flavor() ])


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(_preset_util):
			_preset_util.free()


func _initialize_driver() -> void:
	_driver.set_bpm(Controller.bpm)
	_driver.set_timer_interval(1)
	_driver.timer_interval.connect(_handle_driver_timer)

	_driver.play()


func _handle_driver_timer() -> void:
	if _off_timer <= 0:
		return

	_off_timer -= 1

	if _off_timer <= 0:
		_driver.note_off(-1, 0, 0, 0, true) # Prevent runaway notes.


# Voice management.

func _initialize_voices() -> void:
	_voices.resize(6)

	_voices[SiONDriver.CHIP_SIOPM] = SiOPMVoice.new()
	_voices[SiONDriver.CHIP_OPL] = OPLVoice.new()
	_voices[SiONDriver.CHIP_OPM] = OPMVoice.new()
	_voices[SiONDriver.CHIP_OPN] = OPNVoice.new()
	_voices[SiONDriver.CHIP_OPX] = OPXVoice.new()
	_voices[SiONDriver.CHIP_MA3] = MA3Voice.new()

	for voice in _voices:
		voice.randomize_data()

	_current_voice = _voices[0]


func get_voice_params() -> Voice:
	return _current_voice


func set_voice_params(voice: Voice) -> void:
	_current_voice = voice
	voice_changed.emit()


func replace_voice_params(voice: Voice) -> void:
	if not voice || not voice.voice:
		return

	var type := voice.voice.get_chip_type()
	if type < 0 || type >= _voices.size():
		return

	_voices[type] = voice


func change_voice_type(type: int) -> void:
	if type < 0 || type >= _voices.size():
		return

	_current_voice = _voices[type]
	voice_changed.emit()


# Sample management.

func get_sample_params() -> Sample:
	return _current_sample


func set_sample_params(sample: Sample) -> void:
	_current_sample = sample
	sample_changed.emit()


func play_sample() -> void:
	if not _current_voice:
		return

	_off_timer = _current_sample.length.value * 2

	_driver.note_off(-1, 0, 0, 0, true) # Prevent overlaps.
	_driver.note_on(_current_sample.note.value, _current_voice.voice, _current_sample.length.value)

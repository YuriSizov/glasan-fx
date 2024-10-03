###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name VoiceManager extends RefCounted

const NOTE_LENGTH := 8

## SiON tool with a bunch of pre-configured voices.
var _preset_util: SiONVoicePresetUtil = SiONVoicePresetUtil.new()

var _driver: SiONDriver = null
var _current_voice: Voice = null

var _off_timer: int = -1


func _init(controller: Node) -> void:
	_driver = SiONDriver.create(controller.buffer_size)
	_driver.ready.connect(_initialize_driver)
	controller.add_child(_driver)

	print("Created synthesizer driver (v%s-%s)" % [ SiONDriver.get_version(), SiONDriver.get_version_flavor() ])


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
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


# Voice editing.

func set_voice(voice: Voice) -> void:
	_current_voice = voice


func play_note(note: int = 42, length: int = NOTE_LENGTH) -> void:
	if not _current_voice:
		return

	_off_timer = length * 2

	_driver.note_off(-1, 0, 0, 0, true) # Prevent overlaps.
	_driver.note_on(note, _current_voice.voice, length)

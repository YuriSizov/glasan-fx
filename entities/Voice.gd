###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name Voice extends RefCounted

const MAX_VOLUME := 256
const MAX_OPERATORS := 4

var voice: SiONVoice = SiONVoice.new()
var data: Array[VoiceKnob] = []:
	set = set_data

var _channel_param_count: int = 0
var _operator_param_count: int = 0
var _update_suspended: bool = false


func _init(_op_count: int = 1) -> void:
	voice.update_volumes = true
	voice.velocity = int(MAX_VOLUME * 0.75)

	var channel := voice.get_channel_params()
	channel.operator_count = 0


# Data management.

func _update_voice_data() -> void:
	if _update_suspended:
		return

	var params: Array[int] = []
	for knob in data:
		params.push_back(knob.value)

	var chip_type := voice.get_chip_type()

	match chip_type:
		SiONDriver.CHIP_SIOPM:
			voice.set_params(params)

		SiONDriver.CHIP_OPL:
			voice.set_params_opl(params)

		SiONDriver.CHIP_OPM:
			voice.set_params_opm(params)

		SiONDriver.CHIP_OPN:
			voice.set_params_opn(params)

		SiONDriver.CHIP_OPX:
			voice.set_params_opx(params)

		SiONDriver.CHIP_MA3:
			voice.set_params_ma3(params)

		_:
			printerr("Voice: Cannot set parameters for the unsupported chip type (%d)." % [ chip_type ])


func set_data(value: Array[VoiceKnob]) -> void:
	for knob in data:
		knob.value_changed.disconnect(_update_voice_data)

	data = value

	for knob in data:
		knob.value_changed.connect(_update_voice_data)

	_update_voice_data()


# Virtual. Must be implemented by extending classes.
func _add_operator() -> void:
	pass


func add_operator() -> void:
	_add_operator()
	_update_voice_data()


# Virtual. Must be implemented by extending classes.
func _randomize_data() -> void:
	pass


func randomize_data() -> void:
	_update_suspended = true
	_randomize_data()
	_update_suspended = false

	_update_voice_data()


func get_channel_data() -> Array[VoiceKnob]:
	var ch_data: Array[VoiceKnob] = []

	for i in _channel_param_count:
		ch_data.push_back(data[i])

	return ch_data


func get_operator_count() -> int:
	var channel := voice.get_channel_params()
	return channel.operator_count


func get_operator_data(op_index: int) -> Array[VoiceKnob]:
	var op_data: Array[VoiceKnob] = []

	var channel := voice.get_channel_params()
	if op_index < 0 || op_index >= channel.operator_count:
		return op_data

	for i in _operator_param_count:
		var j = _channel_param_count + _operator_param_count * op_index + i
		op_data.push_back(data[j])

	return op_data

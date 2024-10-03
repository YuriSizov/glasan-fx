###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name Voice extends RefCounted

const MAX_VOLUME := 256

const SIOPM_CH_PARAMS := 3
const SIOPM_OP_PARAMS := 15

const PARAM_COUNTS := [
	[ SIOPM_CH_PARAMS, SIOPM_OP_PARAMS ],
]

var voice: SiONVoice = SiONVoice.new()
var data: Array[VoiceKnob] = []:
	set = set_data

var _update_suspended: bool = false


# Constructors.

static func create_siopm_voice(op_count: int = 1) -> Voice:
	var instance := Voice.new()
	instance.voice.set_chip_type(SiONDriver.CHIP_SIOPM)
	instance.voice.update_volumes = true
	instance.voice.velocity = int(MAX_VOLUME * 0.75)

	var voice_data: Array[VoiceKnob] = []
	voice_data.resize(SIOPM_CH_PARAMS + SIOPM_OP_PARAMS * op_count)

	# Channel params.

	voice_data[0] = VoiceKnob.new("AL", 0, 15)
	voice_data[1] = VoiceKnob.new("FB", 0, 7)
	voice_data[2] = VoiceKnob.new("FC", 0, 3)

	# Operator params.

	for i in op_count:
		var data_index := SIOPM_CH_PARAMS + SIOPM_OP_PARAMS * i

		voice_data[data_index + 0]  = VoiceKnob.new("WS", 0, 255) # Out of 511 valid total.
		voice_data[data_index + 0].set_safe_range(0, 26) # There are some gaps which don't have wave shapes.

		voice_data[data_index + 1]  = VoiceKnob.new("AR", 0, 63)
		voice_data[data_index + 1].value = 63
		voice_data[data_index + 2]  = VoiceKnob.new("DR", 0, 63)
		voice_data[data_index + 3]  = VoiceKnob.new("SR", 0, 63)
		voice_data[data_index + 3].value = 32
		voice_data[data_index + 4]  = VoiceKnob.new("RR", 0, 63)
		voice_data[data_index + 4].value = 32

		voice_data[data_index + 5]  = VoiceKnob.new("SL", 0, 15)
		voice_data[data_index + 6]  = VoiceKnob.new("TL", 0, 127)
		voice_data[data_index + 7]  = VoiceKnob.new("KR", 0, 3)
		voice_data[data_index + 8]  = VoiceKnob.new("KL", 0, 3)

		voice_data[data_index + 9]  = VoiceKnob.new("ML", 0, 15)
		voice_data[data_index + 9].value = 1
		voice_data[data_index + 10] = VoiceKnob.new("D1", 0, 7)
		voice_data[data_index + 11] = VoiceKnob.new("D2", 0, 999) # No known limit.
		voice_data[data_index + 11].value = 0
		voice_data[data_index + 12] = VoiceKnob.new("AM", 0, 3)
		voice_data[data_index + 13] = VoiceKnob.new("PH", -1, 255)
		voice_data[data_index + 13].value = 0
		voice_data[data_index + 14] = VoiceKnob.new("FN", 0, 127)

	instance.data = voice_data

	return instance


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

		_:
			printerr("Voice: Cannot set parameters for the unsupported chip type (%d)." % [ chip_type ])


func set_data(value: Array[VoiceKnob]) -> void:
	for knob in data:
		knob.value_changed.disconnect(_update_voice_data)

	data = value

	for knob in data:
		knob.value_changed.connect(_update_voice_data)

	_update_voice_data()


func randomize_data() -> void:
	_update_suspended = true

	var chip_type := voice.get_chip_type()
	match chip_type:
		SiONDriver.CHIP_SIOPM:
			var ch_data := get_channel_data()
			ch_data[1].randomize_value() # FB

			for i in get_operator_count():
				var op_data := get_operator_data(i)

				op_data[0].randomize_value() # WS
				op_data[7].randomize_value() # KR
				op_data[9].randomize_value() # ML
				op_data[14].randomize_value() # FN

	_update_suspended = false
	_update_voice_data()


func get_channel_data() -> Array[VoiceKnob]:
	var ch_data: Array[VoiceKnob] = []

	var chip_type := voice.get_chip_type()
	if chip_type < 0 || chip_type >= PARAM_COUNTS.size():
		return ch_data

	var param_count: int = PARAM_COUNTS[chip_type][0]
	for i in param_count:
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

	var chip_type := voice.get_chip_type()
	if chip_type < 0 || chip_type >= PARAM_COUNTS.size():
		return op_data

	var ch_param_count: int = PARAM_COUNTS[chip_type][0]
	var param_count: int = PARAM_COUNTS[chip_type][1]
	for i in param_count:
		var j = ch_param_count + param_count * op_index + i

		op_data.push_back(data[j])

	return op_data

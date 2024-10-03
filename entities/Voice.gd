###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name Voice extends RefCounted

const MAX_VOLUME := 256

const SIOPM_CH_PARAMS := 3
const OPL_CH_PARAMS := 2
const OPM_CH_PARAMS := 2
const OPN_CH_PARAMS := 2
const OPX_CH_PARAMS := 2
const MA3_CH_PARAMS := 2

const SIOPM_OP_PARAMS := 15
const OPL_OP_PARAMS := 11
const OPM_OP_PARAMS := 11
const OPN_OP_PARAMS := 10
const OPX_OP_PARAMS := 12
const MA3_OP_PARAMS := 12

const PARAM_COUNTS := [
	[ SIOPM_CH_PARAMS, SIOPM_OP_PARAMS ],
	[ OPL_CH_PARAMS, OPL_OP_PARAMS ],
	[ OPM_CH_PARAMS, OPM_OP_PARAMS ],
	[ OPN_CH_PARAMS, OPN_OP_PARAMS ],
	[ OPX_CH_PARAMS, OPX_OP_PARAMS ],
	[ MA3_CH_PARAMS, MA3_OP_PARAMS ],
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
		voice_data[data_index + 0].set_safe_range(0, 31) # There are some gaps which don't have wave shapes.

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
		voice_data[data_index + 12] = VoiceKnob.new("AM", 0, 3)
		voice_data[data_index + 13] = VoiceKnob.new("PH", -1, 255)
		voice_data[data_index + 13].value = 0
		voice_data[data_index + 14] = VoiceKnob.new("FN", 0, 127)

	instance.data = voice_data

	return instance


static func create_opl_voice(op_count: int = 1) -> Voice:
	var instance := Voice.new()
	instance.voice.set_chip_type(SiONDriver.CHIP_OPL)
	instance.voice.update_volumes = true
	instance.voice.velocity = int(MAX_VOLUME * 0.75)

	var voice_data: Array[VoiceKnob] = []
	voice_data.resize(OPL_CH_PARAMS + OPL_OP_PARAMS * op_count)

	# Channel params.

	voice_data[0] = VoiceKnob.new("AL", 0, 5)
	voice_data[1] = VoiceKnob.new("FB", 0, 7)

	# Operator params.

	for i in op_count:
		var data_index := OPL_CH_PARAMS + OPL_OP_PARAMS * i

		voice_data[data_index + 0]  = VoiceKnob.new("WS", 0, 31)

		voice_data[data_index + 1]  = VoiceKnob.new("AR", 0, 15)
		voice_data[data_index + 1].value = 15
		voice_data[data_index + 2]  = VoiceKnob.new("DR", 0, 15)
		voice_data[data_index + 3]  = VoiceKnob.new("RR", 0, 15)
		voice_data[data_index + 3].value = 8

		voice_data[data_index + 4]  = VoiceKnob.new("EG", 0, 1)
		voice_data[data_index + 5]  = VoiceKnob.new("SL", 0, 15)
		voice_data[data_index + 6]  = VoiceKnob.new("TL", 0, 63)
		voice_data[data_index + 7]  = VoiceKnob.new("KR", 0, 1)
		voice_data[data_index + 8]  = VoiceKnob.new("KL", 0, 3)

		voice_data[data_index + 9]  = VoiceKnob.new("ML", 0, 15)
		voice_data[data_index + 9].value = 1
		voice_data[data_index + 10] = VoiceKnob.new("AM", 0, 3)

	instance.data = voice_data

	return instance


static func create_opm_voice(op_count: int = 1) -> Voice:
	var instance := Voice.new()
	instance.voice.set_chip_type(SiONDriver.CHIP_OPM)
	instance.voice.update_volumes = true
	instance.voice.velocity = int(MAX_VOLUME * 0.75)

	var voice_data: Array[VoiceKnob] = []
	voice_data.resize(OPM_CH_PARAMS + OPM_OP_PARAMS * op_count)

	# Channel params.

	voice_data[0] = VoiceKnob.new("AL", 0, 7)
	voice_data[1] = VoiceKnob.new("FB", 0, 7)

	# Operator params.

	for i in op_count:
		var data_index := OPM_CH_PARAMS + OPM_OP_PARAMS * i

		voice_data[data_index + 0]  = VoiceKnob.new("AR", 0, 31)
		voice_data[data_index + 0].value = 31
		voice_data[data_index + 1]  = VoiceKnob.new("DR", 0, 31)
		voice_data[data_index + 2]  = VoiceKnob.new("SR", 0, 31)
		voice_data[data_index + 2].value = 16
		voice_data[data_index + 3]  = VoiceKnob.new("RR", 0, 15)
		voice_data[data_index + 3].value = 8

		voice_data[data_index + 4]  = VoiceKnob.new("SL", 0, 15)
		voice_data[data_index + 5]  = VoiceKnob.new("TL", 0, 127)
		voice_data[data_index + 6]  = VoiceKnob.new("KR", 0, 3)

		voice_data[data_index + 7]  = VoiceKnob.new("ML", 0, 15)
		voice_data[data_index + 7].value = 1
		voice_data[data_index + 8]  = VoiceKnob.new("D1", 0, 7)
		voice_data[data_index + 9]  = VoiceKnob.new("D2", 0, 3)
		voice_data[data_index + 10] = VoiceKnob.new("AM", 0, 3)

	instance.data = voice_data

	return instance


static func create_opn_voice(op_count: int = 1) -> Voice:
	var instance := Voice.new()
	instance.voice.set_chip_type(SiONDriver.CHIP_OPN)
	instance.voice.update_volumes = true
	instance.voice.velocity = int(MAX_VOLUME * 0.75)

	var voice_data: Array[VoiceKnob] = []
	voice_data.resize(OPN_CH_PARAMS + OPN_OP_PARAMS * op_count)

	# Channel params.

	voice_data[0] = VoiceKnob.new("AL", 0, 7)
	voice_data[1] = VoiceKnob.new("FB", 0, 7)

	# Operator params.

	for i in op_count:
		var data_index := OPN_CH_PARAMS + OPN_OP_PARAMS * i

		voice_data[data_index + 0] = VoiceKnob.new("AR", 0, 31)
		voice_data[data_index + 0].value = 31
		voice_data[data_index + 1] = VoiceKnob.new("DR", 0, 31)
		voice_data[data_index + 2] = VoiceKnob.new("SR", 0, 31)
		voice_data[data_index + 2].value = 16
		voice_data[data_index + 3] = VoiceKnob.new("RR", 0, 15)
		voice_data[data_index + 3].value = 8

		voice_data[data_index + 4] = VoiceKnob.new("SL", 0, 15)
		voice_data[data_index + 5] = VoiceKnob.new("TL", 0, 127)
		voice_data[data_index + 6] = VoiceKnob.new("KR", 0, 3)

		voice_data[data_index + 7] = VoiceKnob.new("ML", 0, 15)
		voice_data[data_index + 7].value = 1
		voice_data[data_index + 8] = VoiceKnob.new("D1", 0, 7)
		voice_data[data_index + 9] = VoiceKnob.new("AM", 0, 3)

	instance.data = voice_data

	return instance


static func create_opx_voice(op_count: int = 1) -> Voice:
	var instance := Voice.new()
	instance.voice.set_chip_type(SiONDriver.CHIP_OPX)
	instance.voice.update_volumes = true
	instance.voice.velocity = int(MAX_VOLUME * 0.75)

	var voice_data: Array[VoiceKnob] = []
	voice_data.resize(OPX_CH_PARAMS + OPX_OP_PARAMS * op_count)

	# Channel params.

	voice_data[0] = VoiceKnob.new("AL", 0, 15)
	voice_data[1] = VoiceKnob.new("FB", 0, 7)

	# Operator params.

	for i in op_count:
		var data_index := OPX_CH_PARAMS + OPX_OP_PARAMS * i

		voice_data[data_index + 0]  = VoiceKnob.new("WS", 0, 135) # 0-7 for MA3, 8-135 for custom.
		voice_data[data_index + 0].set_safe_range(0, 7)

		voice_data[data_index + 1]  = VoiceKnob.new("AR", 0, 31)
		voice_data[data_index + 1].value = 31
		voice_data[data_index + 2]  = VoiceKnob.new("DR", 0, 31)
		voice_data[data_index + 3]  = VoiceKnob.new("SR", 0, 31)
		voice_data[data_index + 3].value = 16
		voice_data[data_index + 4]  = VoiceKnob.new("RR", 0, 15)
		voice_data[data_index + 4].value = 8

		voice_data[data_index + 5]  = VoiceKnob.new("SL", 0, 15)
		voice_data[data_index + 6]  = VoiceKnob.new("TL", 0, 127)
		voice_data[data_index + 7]  = VoiceKnob.new("KR", 0, 3)

		voice_data[data_index + 8]  = VoiceKnob.new("ML", 0, 15)
		voice_data[data_index + 8].value = 1
		voice_data[data_index + 9]  = VoiceKnob.new("D1", 0, 7)
		voice_data[data_index + 10] = VoiceKnob.new("D2", 0, 999) # No known limit.
		voice_data[data_index + 11] = VoiceKnob.new("AM", 0, 3)

	instance.data = voice_data

	return instance


static func create_ma3_voice(op_count: int = 1) -> Voice:
	var instance := Voice.new()
	instance.voice.set_chip_type(SiONDriver.CHIP_MA3)
	instance.voice.update_volumes = true
	instance.voice.velocity = int(MAX_VOLUME * 0.75)

	var voice_data: Array[VoiceKnob] = []
	voice_data.resize(MA3_CH_PARAMS + MA3_OP_PARAMS * op_count)

	# Channel params.

	voice_data[0] = VoiceKnob.new("AL", 0, 15)
	voice_data[1] = VoiceKnob.new("FB", 0, 7)

	# Operator params.

	for i in op_count:
		var data_index := MA3_CH_PARAMS + MA3_OP_PARAMS * i

		voice_data[data_index + 0]  = VoiceKnob.new("WS", 0, 31)

		voice_data[data_index + 1]  = VoiceKnob.new("AR", 0, 15)
		voice_data[data_index + 1].value = 15
		voice_data[data_index + 2]  = VoiceKnob.new("DR", 0, 15)
		voice_data[data_index + 3]  = VoiceKnob.new("SR", 0, 15)
		voice_data[data_index + 3].value = 8
		voice_data[data_index + 4]  = VoiceKnob.new("RR", 0, 15)
		voice_data[data_index + 4].value = 8

		voice_data[data_index + 5]  = VoiceKnob.new("SL", 0, 15)
		voice_data[data_index + 6]  = VoiceKnob.new("TL", 0, 63)
		voice_data[data_index + 7]  = VoiceKnob.new("KR", 0, 1)
		voice_data[data_index + 8]  = VoiceKnob.new("KL", 0, 3)

		voice_data[data_index + 9]  = VoiceKnob.new("ML", 0, 15)
		voice_data[data_index + 9].value = 1
		voice_data[data_index + 10] = VoiceKnob.new("D1", 0, 7)
		voice_data[data_index + 11] = VoiceKnob.new("AM", 0, 3)

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
				op_data[10].randomize_value() # D1
				op_data[11].randomize_value() # D2
				op_data[14].randomize_value() # FN

		SiONDriver.CHIP_OPL:
			var ch_data := get_channel_data()
			ch_data[1].randomize_value() # FB

			for i in get_operator_count():
				var op_data := get_operator_data(i)

				op_data[0].randomize_value() # WS
				op_data[7].randomize_value() # KR
				op_data[9].randomize_value() # ML

		SiONDriver.CHIP_OPM:
			var ch_data := get_channel_data()
			ch_data[1].randomize_value() # FB

			for i in get_operator_count():
				var op_data := get_operator_data(i)

				op_data[6].randomize_value() # KR
				op_data[7].randomize_value() # ML
				op_data[8].randomize_value() # D1
				op_data[9].randomize_value() # D2

		SiONDriver.CHIP_OPN:
			var ch_data := get_channel_data()
			ch_data[1].randomize_value() # FB

			for i in get_operator_count():
				var op_data := get_operator_data(i)

				op_data[6].randomize_value() # KR
				op_data[7].randomize_value() # ML
				op_data[8].randomize_value() # D1

		SiONDriver.CHIP_OPX:
			var ch_data := get_channel_data()
			ch_data[1].randomize_value() # FB

			for i in get_operator_count():
				var op_data := get_operator_data(i)

				op_data[0].randomize_value() # WS
				op_data[7].randomize_value() # KR
				op_data[8].randomize_value() # ML
				op_data[9].randomize_value() # D1
				op_data[10].randomize_value() # D2

		SiONDriver.CHIP_MA3:
			var ch_data := get_channel_data()
			ch_data[1].randomize_value() # FB

			for i in get_operator_count():
				var op_data := get_operator_data(i)

				op_data[0].randomize_value() # WS
				op_data[7].randomize_value() # KR
				op_data[9].randomize_value() # ML
				op_data[10].randomize_value() # D1

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

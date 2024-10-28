###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name SiOPMVoice extends Voice

const SIOPM_CH_PARAMS := 3
const SIOPM_OP_PARAMS := 15

enum ChannelParam {
	AL, FB, FC
}
enum OperatorParam {
	WS, AR, DR, SR, RR, SL, TL, KR, KL, ML, D1, D2, AM, PH, FN
}


func _init(op_count: int = 1) -> void:
	super(op_count)

	voice.set_chip_type(SiONDriver.CHIP_SIOPM)
	_channel_param_count = SIOPM_CH_PARAMS
	_operator_param_count = SIOPM_OP_PARAMS

	data.clear()
	data.resize(SIOPM_CH_PARAMS + SIOPM_OP_PARAMS * op_count)

	# Channel params.

	# Subindices follow the ChannelParam enum.
	data[0] = VoiceKnob.new("AL", 0, 15)
	data[1] = VoiceKnob.new("FB", 0, 7)
	data[2] = VoiceKnob.new("FC", 0, 3)

	# Operator params.

	for i in op_count:
		add_operator()

	_connect_voice_data()
	_update_voice_data()


func _add_operator() -> void:
	var operator_index := get_operator_count()
	if operator_index >= MAX_OPERATORS:
		return

	var data_index := SIOPM_CH_PARAMS + SIOPM_OP_PARAMS * operator_index
	data.resize(SIOPM_CH_PARAMS + SIOPM_OP_PARAMS * (operator_index + 1))

	# Subindices follow the OperatorParam enum.
	data[data_index + 0]  = VoiceKnob.new("WS", 0, 255) # Out of 511 valid total.

	data[data_index + 1]  = VoiceKnob.new("AR", 0, 63)
	data[data_index + 1].set_safe_range(16, 63)
	data[data_index + 1].value = 63
	data[data_index + 2]  = VoiceKnob.new("DR", 0, 63)
	data[data_index + 2].set_safe_range(0, 47)
	data[data_index + 3]  = VoiceKnob.new("SR", 0, 63)
	data[data_index + 3].set_safe_range(16, 47)
	data[data_index + 3].value = 32
	data[data_index + 4]  = VoiceKnob.new("RR", 0, 63)
	data[data_index + 4].set_safe_range(16, 47)
	data[data_index + 4].value = 32

	data[data_index + 5]  = VoiceKnob.new("SL", 0, 15)
	data[data_index + 6]  = VoiceKnob.new("TL", 0, 127)
	data[data_index + 7]  = VoiceKnob.new("KR", 0, 3)
	data[data_index + 8]  = VoiceKnob.new("KL", 0, 3)

	data[data_index + 9]  = VoiceKnob.new("ML", 0, 15)
	data[data_index + 9].value = 1
	data[data_index + 10] = VoiceKnob.new("D1", 0, 7)
	data[data_index + 11] = VoiceKnob.new("D2", 0, 999) # No known limit.
	data[data_index + 12] = VoiceKnob.new("AM", 0, 3)
	data[data_index + 13] = VoiceKnob.new("PH", -1, 255)
	data[data_index + 13].value = 0
	data[data_index + 14] = VoiceKnob.new("FN", 0, 127)


func _remove_operator() -> void:
	var operator_index := get_operator_count()
	if operator_index == 1:
		return

	data.resize(SIOPM_CH_PARAMS + SIOPM_OP_PARAMS * (operator_index - 1))


func _randomize_channel() -> void:
	var ch_data := get_channel_data()
	ch_data[ChannelParam.FB].randomize_value()

	if get_operator_count() > 1: # Algorithm doesn't make a difference if there are no operators to mix.
		ch_data[ChannelParam.AL].randomize_value()
	else:
		ch_data[ChannelParam.AL].value = 0


func _randomize_operator(index: int) -> void:
	var op_data := get_operator_data(index)

	op_data[OperatorParam.WS].value = _randomize_wave_shape()

	op_data[OperatorParam.AR].randomize_value()
	op_data[OperatorParam.DR].randomize_value()
	op_data[OperatorParam.SR].randomize_value()
	op_data[OperatorParam.RR].randomize_value()

	op_data[OperatorParam.KR].randomize_value()
	op_data[OperatorParam.ML].randomize_value()
	op_data[OperatorParam.D1].randomize_value()
	op_data[OperatorParam.D2].randomize_value()


func _randomize_wave_shape() -> int:
	# First decide on the wave shape group.
	var wave_group := randi_range(0, WaveShape.MAX - 1)
	var wave_range: Array = WaveShape.RANGES[wave_group]

	# Then pick a value from the range for this wave shape group.
	var wave_shape := randi_range(wave_range[0], wave_range[0] + wave_range[1] - 1)

	# Special cases.

	# Basic waves have an "offset" wave, which is not a wave at all.
	if wave_group == WaveShape.SHAPE_BASIC && wave_shape == SiONDriver.PULSE_OFFSET:
		wave_shape -= 1

	# MA-3 waves support user defined shapes, which we must exclude here.
	if wave_group == WaveShape.SHAPE_MA3 && wave_shape in [ SiONDriver.PULSE_MA3_USER1, SiONDriver.PULSE_MA3_USER2, SiONDriver.PULSE_MA3_USER3 ]:
		wave_shape -= 1

	return wave_shape


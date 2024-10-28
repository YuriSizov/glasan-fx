###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name OPXVoice extends Voice

const OPX_CH_PARAMS := 2
const OPX_OP_PARAMS := 12
const OPX_MA3_RANGE := 8

enum ChannelParam {
	AL, FB
}
enum OperatorParam {
	WS, AR, DR, SR, RR, SL, TL, KR, ML, D1, D2, AM
}


func _init(op_count: int = 1) -> void:
	super(op_count)

	voice.set_chip_type(SiONDriver.CHIP_OPX)
	_channel_param_count = OPX_CH_PARAMS
	_operator_param_count = OPX_OP_PARAMS

	data.clear()
	data.resize(OPX_CH_PARAMS + OPX_OP_PARAMS * op_count)

	# Channel params.

	# Subindices follow the ChannelParam enum.
	data[0] = VoiceKnob.new("AL", 0, 15)
	data[1] = VoiceKnob.new("FB", 0, 7)

	# Operator params.

	for i in op_count:
		add_operator()

	_connect_voice_data()
	_update_voice_data()


func _add_operator() -> void:
	var operator_index := get_operator_count()
	if operator_index >= MAX_OPERATORS:
		return

	var data_index := OPX_CH_PARAMS + OPX_OP_PARAMS * operator_index
	data.resize(OPX_CH_PARAMS + OPX_OP_PARAMS * (operator_index + 1))

	# Subindices follow the OperatorParam enum.
	data[data_index + 0]  = VoiceKnob.new("WS", 0, 135) # 0-7 for MA-3, 8-135 for custom.
	data[data_index + 0].set_safe_range(0, 7)

	data[data_index + 1]  = VoiceKnob.new("AR", 0, 31)
	data[data_index + 1].set_safe_range(8, 31)
	data[data_index + 1].value = 31
	data[data_index + 2]  = VoiceKnob.new("DR", 0, 31)
	data[data_index + 2].set_safe_range(0, 23)
	data[data_index + 3]  = VoiceKnob.new("SR", 0, 31)
	data[data_index + 3].set_safe_range(8, 23)
	data[data_index + 3].value = 16
	data[data_index + 4]  = VoiceKnob.new("RR", 0, 15)
	data[data_index + 4].set_safe_range(4, 11)
	data[data_index + 4].value = 8

	data[data_index + 5]  = VoiceKnob.new("SL", 0, 15)
	data[data_index + 6]  = VoiceKnob.new("TL", 0, 127)
	data[data_index + 7]  = VoiceKnob.new("KR", 0, 3)

	data[data_index + 8]  = VoiceKnob.new("ML", 0, 15)
	data[data_index + 8].value = 1
	data[data_index + 9]  = VoiceKnob.new("D1", 0, 7)
	data[data_index + 10] = VoiceKnob.new("D2", 0, 999) # No known limit.
	data[data_index + 11] = VoiceKnob.new("AM", 0, 3)


func _remove_operator() -> void:
	var operator_index := get_operator_count()
	if operator_index == 1:
		return

	data.resize(OPX_CH_PARAMS + OPX_OP_PARAMS * (operator_index - 1))


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
	# OPX supports the first 8 shapes of MA-3, and the rest are custom, which we don't allow here.

	# First pick a random value using the main enum values.
	var wave_range: Array = WaveShape.RANGES[WaveShape.SHAPE_MA3]
	var wave_shape := randi_range(wave_range[0], wave_range[0] + OPX_MA3_RANGE - 1)

	# Remove the offset so the value is in the MA-3 range.
	return wave_shape - wave_range[0]

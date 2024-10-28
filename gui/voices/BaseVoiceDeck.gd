###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name BaseVoiceDeck extends PanelContainer

signal voice_changed()

var voice: Voice = null:
	set = set_voice


# Voice management.

func set_voice(value: Voice) -> void:
	if voice == value:
		return

	if voice:
		voice.data_changed.disconnect(voice_changed.emit)

	voice = value

	if voice:
		voice.data_changed.connect(voice_changed.emit)

	voice_changed.emit()


# Helpers.

static func setup_roller_knob(knob: RollerKnob, data: VoiceKnob) -> void:
	# Clear previous connections, if any.
	var connections := knob.value_changed.get_connections()
	for connection : Dictionary in connections:
		knob.value_changed.disconnect(connection["callable"])

	# Set up properties.
	knob.min_value = data.min_value
	knob.max_value = data.max_value
	knob.safe_min_value = data.min_safe
	knob.safe_max_value = data.max_safe
	knob.knob_value = data.value

	# Connect to changes.
	knob.value_changed.connect(func() -> void:
		data.value = knob.knob_value
	)


static func setup_tuner_slider(slider: TunerSlider, data: VoiceKnob) -> void:
	# Clear previous connections, if any.
	var connections := slider.value_changed.get_connections()
	for connection : Dictionary in connections:
		slider.value_changed.disconnect(connection["callable"])

	# Set up properties.
	slider.set_value_normalized(data.value, data.min_value, data.max_value)

	# Connect to changes.
	slider.value_changed.connect(func() -> void:
		data.value = slider.get_normalized_value(data.min_value, data.max_value)
	)


static func setup_flicker_knob(flicker: FlickerKnob, data: VoiceKnob) -> void:
	# Clear previous connections, if any.
	var connections := flicker.value_changed.get_connections()
	for connection : Dictionary in connections:
		flicker.value_changed.disconnect(connection["callable"])

	flicker.flicker_value = bool(data.value)

	# Connect to changes.
	flicker.value_changed.connect(func() -> void:
		data.value = int(flicker.flicker_value)
	)


static func setup_knob_control(knob: KnobControl, data: VoiceKnob) -> void:
	knob.knob_data = data
	knob.force_update()

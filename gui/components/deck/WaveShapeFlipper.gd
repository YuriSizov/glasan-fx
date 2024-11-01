###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name WaveShapeFlipper extends MarginContainer

signal shape_changed()

const WAVE_SHAPE_MAP := {
	WaveShape.SHAPE_BASIC:       0,
	WaveShape.SHAPE_NOISE:       1,
	WaveShape.SHAPE_PC_NOISE:    1,
	WaveShape.SHAPE_MA3:         5,
	WaveShape.SHAPE_PULSE:       2,
	WaveShape.SHAPE_PULSE_SPIKE: 3,
	WaveShape.SHAPE_RAMP:        4,
}

@export var wave_shape: int = -1:
	set = set_wave_shape

var _basic_wave_buttons: Array[GlowButton] = []
var _noise_wave_buttons: Array[GlowButton] = []
var _pc_noise_wave_buttons: Array[GlowButton] = []
var _pulse_wave_buttons: Array[GlowButton] = []
var _pulse_spike_wave_buttons: Array[GlowButton] = []
var _ramp_wave_slider: TunerSlider = null
var _ma3_wave_buttons: Array[GlowButton] = []

@onready var _content_panel: PanelContainer = %Content

@onready var _shape_flipper: OptionFlipper = %ShapeFlipper
@onready var _shapes_container: Control = %Shapes


func _ready() -> void:
	_collect_buttons_and_sliders()
	_update_shape_filter()
	_update_shape_selection()
	_switch_shape_list()
	_shape_flipper.selected.connect(_switch_shape_list)


# Shape management.

func set_wave_shape(value: int) -> void:
	if wave_shape == value:
		return

	wave_shape = value
	_update_shape_filter()
	_update_shape_selection()


func _update_shape_filter() -> void:
	if not is_node_ready():
		return
	if wave_shape < 0:
		return

	var wave_group := -1
	for i in WaveShape.MAX:
		var wave_range: Array = WaveShape.RANGES[i]
		if wave_shape >= wave_range[0] && wave_shape < (wave_range[0] + wave_range[1]):
			wave_group = i

	if wave_group >= 0:
		var filter_index = WAVE_SHAPE_MAP[wave_group]

		# A hack to split MA-3 waves into two groups.
		if wave_group == WaveShape.SHAPE_MA3:
			var wave_range: Array = WaveShape.RANGES[wave_group]
			var shape_index: int = wave_shape - wave_range[0]
			if shape_index > 15:
				filter_index += 1

		_shape_flipper.selected_index = filter_index


func _update_shape_selection() -> void:
	if not is_node_ready():
		return

	_update_shape_buttons(WaveShape.SHAPE_BASIC,       _basic_wave_buttons)
	_update_shape_buttons(WaveShape.SHAPE_NOISE,       _noise_wave_buttons)
	_update_shape_buttons(WaveShape.SHAPE_PC_NOISE,    _pc_noise_wave_buttons)
	_update_shape_buttons(WaveShape.SHAPE_PULSE,       _pulse_wave_buttons)
	_update_shape_buttons(WaveShape.SHAPE_PULSE_SPIKE, _pulse_spike_wave_buttons)
	_update_shape_buttons(WaveShape.SHAPE_MA3,         _ma3_wave_buttons)

	_update_shape_slider(WaveShape.SHAPE_RAMP, _ramp_wave_slider)


func _switch_shape_list() -> void:
	# TODO: Perhaps do a transition somehow? Not sure if there is a natural way to do this that fits the style.

	for child_node in _shapes_container.get_children():
		child_node.visible = (child_node.get_index() == _shape_flipper.selected_index)

	var active_color := _shape_flipper.option_colors[_shape_flipper.selected_index]
	_content_panel.self_modulate = active_color.darkened(0.4)
	if _content_panel.self_modulate.s > 0.5:
		_content_panel.self_modulate.s = 0.5


# Buttons and sliders.

func _collect_buttons_and_sliders() -> void:
	_basic_wave_buttons       = _collect_shape_buttons(WaveShape.SHAPE_BASIC,       "BasicButton")
	_noise_wave_buttons       = _collect_shape_buttons(WaveShape.SHAPE_NOISE,       "NoiseButton")
	_pc_noise_wave_buttons    = _collect_shape_buttons(WaveShape.SHAPE_PC_NOISE,    "PCNoiseButton")
	_pulse_wave_buttons       = _collect_shape_buttons(WaveShape.SHAPE_PULSE,       "PulseButton")
	_pulse_spike_wave_buttons = _collect_shape_buttons(WaveShape.SHAPE_PULSE_SPIKE, "PulseSpikeButton")
	_ma3_wave_buttons         = _collect_shape_buttons(WaveShape.SHAPE_MA3,         "MA3Button")

	_ramp_wave_slider = _collect_shape_slider(WaveShape.SHAPE_RAMP, "RampSlider")


func _collect_shape_buttons(shape_id: int, button_name: String) -> Array[GlowButton]:
	var wave_range: Array = WaveShape.RANGES[shape_id]
	var wave_buttons: Array[GlowButton] = []
	wave_buttons.resize(wave_range[1])

	for i in wave_range[1]:
		var node_path := NodePath("%%%s%d" % [ button_name, i ])
		var node: GlowButton = get_node(node_path)
		if not node:
			printerr("WaveShapeFlipper: Missing button %d for wave shape %d (expected '%s')." % [ i, shape_id, node_path ])
			continue

		wave_buttons[i] = node

		# We want the button to be in toggle mode and users should be able to press it,
		# but never unpress it. We still want it to be unpressable through code.
		# So, uhhm... this works.
		node.toggle_mode = true
		node.button_down.connect(func() -> void:
			if node.button_pressed:
				var bg := ButtonGroup.new()
				bg.allow_unpress = false
				node.button_group = bg
		)
		node.button_up.connect(func() -> void:
			node.button_group = null
		)
		node.toggled.connect(_handle_button_toggled.bind(node, wave_range[0] + i))

	return wave_buttons


func _collect_shape_slider(shape_id: int, slider_name: String) -> TunerSlider:
	var node_path := NodePath("%%%s" % [ slider_name ])
	var node: TunerSlider = get_node(node_path)
	if not node:
		printerr("WaveShapeFlipper: Missing slider for wave shape %d (expected '%s')." % [ shape_id, node_path ])
		return null

	var wave_range: Array = WaveShape.RANGES[shape_id]
	node.slider_value = 0.0
	node.value_changed.connect(_handle_slider_changed.bind(node, wave_range))

	return node


func _update_shape_buttons(shape_id: int, buttons: Array[GlowButton]) -> void:
	var wave_range: Array = WaveShape.RANGES[shape_id]

	for i in buttons.size():
		var button := buttons[i]
		var button_id: int = wave_range[0] + i
		button.button_pressed = (wave_shape == button_id)


func _update_shape_slider(shape_id: int, slider: TunerSlider) -> void:
	var wave_range: Array = WaveShape.RANGES[shape_id]

	if wave_shape >= wave_range[0] && wave_shape < (wave_range[0] + wave_range[1]):
		slider.set_value_normalized(wave_shape, wave_range[0], wave_range[0] + wave_range[1] - 1)
	else:
		slider.slider_value = 0.0


func _handle_button_toggled(toggled: bool, _button: GlowButton, shape_id: int) -> void:
	if toggled:
		_change_shape(shape_id)


func _handle_slider_changed(slider: TunerSlider, wave_range: Array) -> void:
	var value := slider.get_normalized_value(wave_range[0], wave_range[0] + wave_range[1] - 1)
	_change_shape(value)


func _change_shape(shape_id: int) -> void:
	if wave_shape == shape_id:
		return

	wave_shape = shape_id
	shape_changed.emit()

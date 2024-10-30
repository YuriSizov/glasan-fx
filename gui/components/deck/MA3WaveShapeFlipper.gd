###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name MA3WaveShapeFlipper extends MarginContainer

signal shape_changed()

@export var wave_shape: int = -1:
	set = set_wave_shape
@export var short_form: bool = false:
	set = set_short_form
@export var accent_color: Color = Color.WHITE:
	set = set_accent_color

var _ma3_wave_buttons: Array[GlowButton] = []

@onready var _content_panel: PanelContainer = %Content
@onready var _row1: Control = %Row1
@onready var _row2: Control = %Row2
@onready var _row3: Control = %Row3
@onready var _row4: Control = %Row4


func _ready() -> void:
	_collect_ma3_buttons()
	_update_ma3_buttons()
	_update_available_rows()
	_update_panel_style()


# Shape management.

func set_wave_shape(value: int) -> void:
	if wave_shape == value:
		return

	wave_shape = value
	_update_ma3_buttons()


func set_short_form(value: bool) -> void:
	if short_form == value:
		return

	short_form = value
	_update_available_rows()


func _update_available_rows() -> void:
	if not is_node_ready():
		return

	_row1.visible = true
	_row2.visible = not short_form
	_row3.visible = not short_form
	_row4.visible = not short_form


func set_accent_color(value: Color) -> void:
	if accent_color == value:
		return

	accent_color = value
	_update_panel_style()


func _update_panel_style() -> void:
	if not is_node_ready():
		return

	_content_panel.self_modulate = accent_color.darkened(0.4)
	if _content_panel.self_modulate.s > 0.5:
		_content_panel.self_modulate.s = 0.5


# Buttons and sliders.

func _collect_ma3_buttons() -> void:
	var button_name := "MA3Button"
	var wave_range: Array = WaveShape.RANGES[WaveShape.SHAPE_MA3]
	var wave_buttons: Array[GlowButton] = []
	wave_buttons.resize(wave_range[1])

	for i in wave_range[1]:
		var node_path := NodePath("%%%s%d" % [ button_name, i ])
		var node: GlowButton = get_node(node_path)
		if not node:
			printerr("MA3WaveShapeFlipper: Missing button %d for wave shape %d (expected '%s')." % [ i, WaveShape.SHAPE_MA3, node_path ])
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
		node.toggled.connect(_handle_button_toggled.bind(node, i))

	_ma3_wave_buttons = wave_buttons


func _update_ma3_buttons() -> void:
	# Unlike the big WaveShapeFlipper, we're only working with a subset of waves here.
	# So indices start with 0 and we don't need the range information.

	for i in _ma3_wave_buttons.size():
		var button := _ma3_wave_buttons[i]
		var button_id: int = i
		button.button_pressed = (wave_shape == button_id)


func _handle_button_toggled(toggled: bool, _button: GlowButton, shape_id: int) -> void:
	if toggled:
		_change_shape(shape_id)


func _change_shape(shape_id: int) -> void:
	if wave_shape == shape_id:
		return

	wave_shape = shape_id
	shape_changed.emit()

###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name WaveShapeFlipper extends MarginContainer

@export var wave_shape: int = -1:
	set = set_wave_shape

@onready var _shape_flipper: OptionFlipper = %ShapeFlipper
@onready var _shapes_container: Control = %Shapes


func _ready() -> void:
	_shape_flipper.selected.connect(_switch_shape_list)


# Shape management.

func set_wave_shape(value: int) -> void:
	if wave_shape == value:
		return

	wave_shape = value
	_update_shape_filter()
	_update_shape_list()


func _update_shape_filter() -> void:
	if wave_shape < 0:
		return

	var wave_group := -1
	for i in WaveShape.MAX:
		var wave_range: Array = WaveShape.RANGES[i]
		if wave_shape >= wave_range[0] && wave_shape <= (wave_range[0] + wave_range[1]):
			wave_group = i

	if wave_group >= 0:
		_shape_flipper.selected_index = wave_group


func _update_shape_list() -> void:
	pass


func _switch_shape_list() -> void:
	for child_node in _shapes_container.get_children():
		child_node.visible = (child_node.get_index() == _shape_flipper.selected_index)

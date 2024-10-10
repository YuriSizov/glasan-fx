###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name RollerKnob extends PanelContainer

@onready var _knob_label: Label = %Label
@onready var _roller_control: Control = %Roller


func _ready() -> void:
	_roller_control.draw.connect(_draw_roller)


func _draw_roller() -> void:
	_roller_control.draw_rect(Rect2(Vector2.ZERO, _roller_control.size), Color.WHITE)

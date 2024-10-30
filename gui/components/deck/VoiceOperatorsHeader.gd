###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name VoiceOperatorsHeader extends MarginContainer

signal add_operator_pressed()
signal remove_operator_pressed()

@export_range(0, 4) var operator_count: int = 0:
	set = set_operator_count

@onready var _add_operator_button: Button = %AddOperatorButton
@onready var _remove_operator_button: Button = %RemOperatorButton
@onready var _operator_indicator: OperatorIndicator = %OperatorIndicator


func _ready() -> void:
	_update_indicator()

	_add_operator_button.pressed.connect(add_operator_pressed.emit)
	_remove_operator_button.pressed.connect(remove_operator_pressed.emit)


func set_operator_count(value: int) -> void:
	if operator_count == value:
		return

	operator_count = value
	_update_indicator()


func _update_indicator() -> void:
	if not is_node_ready():
		return

	_operator_indicator.operator_count = operator_count

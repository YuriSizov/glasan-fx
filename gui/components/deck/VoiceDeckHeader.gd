###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name VoiceDeckHeader extends MarginContainer

signal randomize_pressed()

@export var voice_name: String = "UNKNOWN":
	set = set_voice_name


@onready var _name_label: Label = %VoiceName
@onready var _randomize_button: GlowButton = %RandomizeButton


func _ready() -> void:
	_update_name_label()

	_randomize_button.pressed.connect(randomize_pressed.emit)


func set_voice_name(value: String) -> void:
	if voice_name == value:
		return

	voice_name = value
	_update_name_label()


func _update_name_label() -> void:
	if not is_node_ready():
		return

	_name_label.text = "%s VOICE" % [ voice_name ]

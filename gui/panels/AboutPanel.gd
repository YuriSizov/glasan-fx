###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name AboutPanel extends ContentPanel

@onready var _credits_block: RichTextLabel = %CreditsContent


func _ready() -> void:
	super()
	_credits_block.meta_clicked.connect(_handle_url_clicked)


func _handle_url_clicked(data: Variant) -> void:
	OS.shell_open(String(data))

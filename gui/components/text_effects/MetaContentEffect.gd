###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name MetaContentEffect extends RichTextEffect

var bbcode: String = "meta"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	char_fx.color = ThemeDB.get_project_theme().get_color("meta_color", "RichTextLabel")
	return true

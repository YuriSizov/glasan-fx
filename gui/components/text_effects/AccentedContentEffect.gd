###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name AccentedContentEffect extends RichTextEffect

var bbcode: String = "accent"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	char_fx.color = ThemeDB.get_project_theme().get_color("accent_color", "RichTextLabel")
	return true

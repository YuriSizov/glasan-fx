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

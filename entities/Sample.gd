###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name Sample extends RefCounted

var note: VoiceKnob = null
var length: VoiceKnob = null


func _init() -> void:
	note = VoiceKnob.new("NOTE", VoiceManager.MIN_NOTE_VALUE, VoiceManager.MAX_NOTE_VALUE)
	note.value = VoiceManager.DEFAULT_NOTE_VALUE

	length = VoiceKnob.new("LEN", VoiceManager.MIN_NOTE_LENGTH, VoiceManager.MAX_NOTE_LENGTH)
	length.value = VoiceManager.DEFAULT_NOTE_LENGTH

###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name Sample extends RefCounted

const MIN_NOTE_LENGTH := 1
const MAX_NOTE_LENGTH := 20
const DEFAULT_NOTE_LENGTH := 4

const MIN_NOTE_VALUE := 0
const MAX_NOTE_VALUE := 127
const DEFAULT_NOTE_VALUE := 42

var note: VoiceKnob = null
var length: VoiceKnob = null


func _init() -> void:
	note = VoiceKnob.new("NOTE", MIN_NOTE_VALUE, MAX_NOTE_VALUE)
	note.value = DEFAULT_NOTE_VALUE

	length = VoiceKnob.new("LEN", MIN_NOTE_LENGTH, MAX_NOTE_LENGTH)
	length.value = DEFAULT_NOTE_LENGTH

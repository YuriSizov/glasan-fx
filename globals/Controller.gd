###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

extends Node

var voice_manager: VoiceManager = null

# Global settings.
var buffer_size: int = 2048
var bpm: int = 120


func _init() -> void:
	voice_manager = VoiceManager.new(self)

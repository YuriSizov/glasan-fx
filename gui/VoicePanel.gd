###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name VoicePanel extends ContentPanel

const FALLBACK_DECK_SCENE := preload("res://gui/voices/FallbackVoiceDeck.tscn")
const DECK_SCENES: Array[PackedScene] = [
	preload("res://gui/voices/SiOPMVoiceDeck.tscn"),
	null,
	null,
	null,
	null,
	null,
]

var _current_deck: BaseVoiceDeck = null


func _ready() -> void:
	super()
	_edit_current_voice()

	if not Engine.is_editor_hint():
		Controller.voice_manager.voice_changed.connect(_edit_current_voice)


# Voice management.

func _edit_current_voice() -> void:
	if Engine.is_editor_hint():
		return

	if is_instance_valid(_current_deck):
		_content.remove_child(_current_deck)
		_current_deck.queue_free()
		_current_deck = null

	var voice := Controller.voice_manager.get_voice_params()
	var voice_type := voice.voice.get_chip_type()

	if voice_type >= 0 && voice_type < DECK_SCENES.size() && DECK_SCENES[voice_type]:
		_current_deck = DECK_SCENES[voice_type].instantiate()
	else:
		_current_deck = FALLBACK_DECK_SCENE.instantiate()

	_current_deck.voice = voice
	_content.add_child(_current_deck)

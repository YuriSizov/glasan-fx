###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name VoicePanel extends ContentPanel

const FALLBACK_DECK_SCENE := preload("res://gui/voices/FallbackVoiceDeck.tscn")
const EDITOR_DECK_SCENE := preload("res://gui/voices/EditorOnlyDeck.tscn")
const DECK_SCENES: Array[PackedScene] = [
	preload("res://gui/voices/SiOPMVoiceDeck.tscn"),
	preload("res://gui/voices/OPLVoiceDeck.tscn"),
	preload("res://gui/voices/OPMVoiceDeck.tscn"),
	preload("res://gui/voices/OPNVoiceDeck.tscn"),
	preload("res://gui/voices/OPXVoiceDeck.tscn"),
	preload("res://gui/voices/MA3VoiceDeck.tscn"),
]

var _current_deck: BaseVoiceDeck = null
var _initialized_decks: Dictionary = {}


func _ready() -> void:
	super()
	_setup_editor_only_deck()
	_edit_current_voice()

	if not Engine.is_editor_hint():
		Controller.voice_manager.voice_changed.connect(_edit_current_voice)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		for deck: BaseVoiceDeck in _initialized_decks.values():
			if is_instance_valid(deck) && not deck.is_inside_tree():
				deck.queue_free()


# Voice management.

func _edit_current_voice() -> void:
	if Engine.is_editor_hint():
		return

	if is_instance_valid(_current_deck):
		_content.remove_child(_current_deck)
		_current_deck = null

	var voice := Controller.voice_manager.get_voice_params()
	var voice_type := voice.voice.get_chip_type()

	if _initialized_decks.has(voice_type) && is_instance_valid(_initialized_decks[voice_type]):
		_current_deck = _initialized_decks[voice_type]
	else:
		if voice_type >= 0 && voice_type < DECK_SCENES.size() && DECK_SCENES[voice_type]:
			_current_deck = DECK_SCENES[voice_type].instantiate()
		else:
			_current_deck = FALLBACK_DECK_SCENE.instantiate()

		_initialized_decks[voice_type] = _current_deck

	_current_deck.voice = voice
	_content.add_child(_current_deck)


func _setup_editor_only_deck() -> void:
	if not Engine.is_editor_hint():
		return

	if is_instance_valid(_current_deck):
		_content.remove_child(_current_deck)
		_current_deck = null

	_current_deck = EDITOR_DECK_SCENE.instantiate()
	_content.add_child(_current_deck)

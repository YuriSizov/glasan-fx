###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name VoicePanel extends MarginContainer

const GENERIC_DECK_SCENE := preload("res://gui/voices/GenericVoiceDeck.tscn")

@onready var _deck_container: PanelContainer = %DeckContainer

@onready var _siopm_button: Button = %SiOPMButton
@onready var _opl_button: Button = %OPLButton
@onready var _opm_button: Button = %OPMButton
@onready var _opn_button: Button = %OPNButton
@onready var _opx_button: Button = %OPXButton
@onready var _ma3_button: Button = %MA3Button

var _current_deck: GenericVoiceDeck = null


func _ready() -> void:
	_siopm_button.pressed.connect(Controller.voice_manager.change_voice_type.bind(SiONDriver.CHIP_SIOPM))
	_opl_button.pressed.connect(Controller.voice_manager.change_voice_type.bind(SiONDriver.CHIP_OPL))
	_opm_button.pressed.connect(Controller.voice_manager.change_voice_type.bind(SiONDriver.CHIP_OPM))
	_opn_button.pressed.connect(Controller.voice_manager.change_voice_type.bind(SiONDriver.CHIP_OPN))
	_opx_button.pressed.connect(Controller.voice_manager.change_voice_type.bind(SiONDriver.CHIP_OPX))
	_ma3_button.pressed.connect(Controller.voice_manager.change_voice_type.bind(SiONDriver.CHIP_MA3))

	_edit_current_voice()
	Controller.voice_manager.voice_changed.connect(_edit_current_voice)


func _edit_current_voice() -> void:
	if is_instance_valid(_current_deck):
		_deck_container.remove_child(_current_deck)
		_current_deck.queue_free()
		_current_deck = null

	# TODO: Add custom decks for every voice type.

	_current_deck = GENERIC_DECK_SCENE.instantiate()
	_current_deck.voice = Controller.voice_manager.get_voice_params()
	_deck_container.add_child(_current_deck)

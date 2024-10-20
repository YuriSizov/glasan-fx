###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name VoiceTypesPanel extends ContentPanel

var voice_buttons := preload("res://gui/panels/voice_type_buttons.tres")

@onready var _siopm_button: Button = %SiOPMButton
@onready var _opl_button: Button = %OPLButton
@onready var _opm_button: Button = %OPMButton
@onready var _opn_button: Button = %OPNButton
@onready var _opx_button: Button = %OPXButton
@onready var _ma3_button: Button = %MA3Button


func _ready() -> void:
	super()

	if not Engine.is_editor_hint():
		_siopm_button.pressed.connect(Controller.voice_manager.change_voice_type.bind(SiONDriver.CHIP_SIOPM))
		_opl_button.pressed.connect(Controller.voice_manager.change_voice_type.bind(SiONDriver.CHIP_OPL))
		_opm_button.pressed.connect(Controller.voice_manager.change_voice_type.bind(SiONDriver.CHIP_OPM))
		_opn_button.pressed.connect(Controller.voice_manager.change_voice_type.bind(SiONDriver.CHIP_OPN))
		_opx_button.pressed.connect(Controller.voice_manager.change_voice_type.bind(SiONDriver.CHIP_OPX))
		_ma3_button.pressed.connect(Controller.voice_manager.change_voice_type.bind(SiONDriver.CHIP_MA3))

		Controller.voice_manager.voice_changed.connect(_handle_voice_changed)


func _handle_voice_changed() -> void:
	var voice := Controller.voice_manager.get_voice_params()
	var voice_type := voice.voice.get_chip_type()

	if voice_buttons.get_pressed_button().get_index() != voice_type:
		voice_buttons.get_buttons()[voice_type].button_pressed = true

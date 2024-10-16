###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name VoiceTypesPanel extends ContentPanel

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

class_name FlagSelector
extends Control

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var indicator_1p: TextureRect = %Indicator1P
@onready var indicator_2p: TextureRect = %Indicator2P

#当前场景控制方案变量
var control_scheme := Player.ControlScheme.P1
#记录是否选择此项
var is_selected := false

func _ready() -> void:
	#对比控制方案
	indicator_1p.visible = control_scheme == Player.ControlScheme.P1
	indicator_2p.visible = control_scheme == Player.ControlScheme.P2

func _process(_delta: float) -> void:
	#检查是否按下了SHOOT键
	if not is_selected and KeyUtils.is_action_just_pressed(control_scheme, KeyUtils.Action.SHOOT):
		#已选中后播放正确动画与音效
		is_selected = true
		animation_player.play("selected")
		SoundPlayer.play(SoundPlayer.Sound.UI_SELECT)
	elif is_selected and KeyUtils.is_action_just_pressed(control_scheme, KeyUtils.Action.PASS):
		is_selected = false
		animation_player.play("selecting")

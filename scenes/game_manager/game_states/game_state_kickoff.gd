class_name GameStateKikcoff
extends GameState

var valid_control_schemes := []

func _enter_tree() -> void:
	#创建一个得分方的国家数据变量
	var country_starting := state_data.country_scored_on
	if country_starting.is_empty():
		country_starting = manager.current_match.country_home
	#判断开球玩家是否为玩家1的国家
	if country_starting == manager.player_setup[0]:
		#如果是，将添加有效控制方案
		valid_control_schemes.append(Player.ControlScheme.P1)
			#判断开球玩家是否为玩家1的国家
	if country_starting == manager.player_setup[1]:
		#如果是，将添加有效控制方案
		valid_control_schemes.append(Player.ControlScheme.P2)
	#如果没有任何匹配,开球将由CPU执行
	if valid_control_schemes.size() == 0:
		valid_control_schemes.append(Player.ControlScheme.P1)

func _process(_delta: float) -> void:
	for control_scheme : Player.ControlScheme in valid_control_schemes:
		if KeyUtils.is_action_just_pressed(control_scheme, KeyUtils.Action.PASS):
			#发送开球信号
			GameEvents.Kickoff_started.emit()
			#按下按键播放音效
			SoundPlayer.play(SoundPlayer.Sound.WHISTLE)
			transition_state(GameManager.State.IN_PLAY)

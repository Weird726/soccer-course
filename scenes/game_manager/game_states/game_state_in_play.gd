class_name GameStateInPlay
extends GameState

func _enter_tree() -> void:
	#监听球队得分事件
	GameEvents.team_scored.connect(on_team_scored.bind())

func _process(delta: float) -> void:
	#处理时间实现倒计时功能
	manager.time_left -= delta
	if manager.is_time_up():
		#判断比分是否持平，持平进入加时赛
		if manager.is_game_tied():
			transition_state(GameManager.State.OVERTIME)
		else:
			transition_state(GameManager.State.GAMEOVER)

func on_team_scored(country_scored_on: String) -> void:
	transition_state(GameManager.State.SCORED, GameStateData.build().set_country_scored_on(country_scored_on))

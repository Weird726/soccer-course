class_name GameStateOvertime
extends GameState

func _enter_tree() -> void:
	#监听队伍得分事件
	GameEvents.team_scored.connect(on_team_scored.bind())

#创建回调函数
func on_team_scored(country_scored_on: String) -> void:
	#在结束游戏状态前也要增加游戏分数
	manager.increase_score(country_scored_on)
	#不仅过度游戏结束状态，还要确保记录新比分游戏变化
	transition_state(GameManager.State.GAMEOVER)
	

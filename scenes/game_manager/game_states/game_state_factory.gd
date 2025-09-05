class_name GameStateFactory

#在字典中存储状态列表
var states : Dictionary

#每个状态都会分配实际的类
func _init() -> void:
	states = {
		GameManager.State.GAMEOVER: GameStateGameOver,
		GameManager.State.IN_PLAY: GameStateInPlay,
		GameManager.State.OVERTIME: GameStateOvertime,
		GameManager.State.RESET: GameStateReset,
		GameManager.State.SCORED: GameStateScored,
	}

#按需获取新状态
func get_fresh_state(state: GameManager.State) -> GameState:
	#在此确认当前状态是可用的
	assert(states.has(state), "state does not exist")
	#负责返回该状态的新实例
	return states.get(state).new()
	

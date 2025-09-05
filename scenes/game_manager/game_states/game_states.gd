class_name GameState
extends Node

#使用一个信号来指示状态转换
signal state_transition_requested(new_state: GameManager.State, data: GameStateData)

var manager : GameManager = null
var state_data : GameStateData = null

func setup(context_manager: GameManager, context_data: GameStateData) -> void:
	#创建依赖项
	manager = context_manager
	state_data = context_data

#状态转换时要允许有默认值
func transition_state(new_state: GameManager.State, data: GameStateData = GameStateData.new()) -> void:
	state_transition_requested.emit(new_state, data)

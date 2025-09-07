class_name GameStateReset
extends GameState

func _enter_tree() -> void:
	#发出这个事件
	GameEvents.team_reset.emit()
	#监听新事件方式
	GameEvents.kickoff_ready.connect(on_kickoff_ready.bind())

#转换到准备状态
func on_kickoff_ready() -> void:
	transition_state(GameManager.State.KICKOFF, state_data)

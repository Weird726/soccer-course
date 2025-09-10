class_name GameStateGameOver
extends GameState

#打印当前状态
func _enter_tree() -> void:
	#从游戏管理器获胜国家中获取参数
	var country_winner := manager.get_winner_country()
	#发出游戏结束信号时传入该值
	GameEvents.game_over.emit(country_winner)

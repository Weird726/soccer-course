class_name WorldScreen
extends Screen

func _enter_tree() -> void:
	#调用游戏裁判重置
	GameManager.start_game()

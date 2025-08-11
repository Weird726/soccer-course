class_name BallStateFreeform
extends BallState

#检测玩家是否重叠的方法
func _enter_tree() -> void:
	#连接到这个信号,并绑定它
	player_detection_area.body_entered.connect(on_player_enter.bind())

#创建绑定的方法，接收一个玩家参数
func on_player_enter(body : Player) -> void:
	#从被携带状态转换属性
	ball.carrier = body
	#切换到被携带状态
	state_transition_requested.emit(Ball.State.CARRIED)

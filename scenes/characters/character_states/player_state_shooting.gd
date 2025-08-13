class_name PlayerStateShooting
extends PlayerState

#统一的节点节点进入树时的初始方法
func _enter_tree() -> void:
	#播放动画 “踢”
	animation_player.play("kick")

#监听回调
func on_animation_complete() -> void:
	#判断该角色是否是AI控制,或者是人类控制
	if player.control_scheme == Player.ControlScheme.CPU:
		#AI角色进入回复状态
		transition_state(Player.State.RECOVERING)
	else:
		#玩家角色直接进入移动状态
		transition_state(Player.State.MOVING)
	shoot_ball()

#射击方法创建
func shoot_ball() -> void:
	
	#开始召唤我们的球,传递状态数据
	ball.shoot(state_data.shot_direction * state_data.shot_power)
	

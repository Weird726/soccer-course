class_name PlayerStateReseting
extends PlayerState

var has_arrived := false

#监听全局信号
func _enter_tree() -> void:
		GameEvents.Kickoff_started.connect(on_kickoff_started.bind())

func _process(_delta: float) -> void:
	#判断是否到达
	if not has_arrived:
		var direction := player.position.direction_to(state_data.reset_position)
		#检查一下距离目的地还有多远
		if player.position.distance_squared_to(state_data.reset_position) < 2:
			has_arrived = true
			#要让玩家停止移动
			player.velocity = Vector2.ZERO
			#停止时让玩家面向目标球门
			player.face_towards_target_goal()
		else:
			#让它们全速移动
			player.velocity = direction * player.speed
		#两种情况下都调用移动动画播放方法
		player.set_movemont_animation()
		#同时设置确保朝向
		player.set_heading()

func is_ready_for_kickoff() -> bool:
	return has_arrived

#返回回调函数
func on_kickoff_started() ->void:
	#切换到移动状态
	transition_state(Player.State.MOVING)

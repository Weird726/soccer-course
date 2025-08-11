#这个节点将被添加为Player的子对象，玩家的每一帧都要经过它的处理
#它将通过引用所有Player移动逻辑
#此逻辑特定为移动状态生效
class_name PlayerStateMoving
extends PlayerState

func _process(_delta: float) -> void:
	#检测是我们控制玩家还是CPU控制玩家（AI处理）
	if player.control_scheme == Player.ControlScheme.CPU:
		pass #这里是AI处理逻辑预留
	else:
		#包含角色移动方向等的方法
		handle_human_movement()
	#创建一个set_movement_animation()方法来重构代码
	player.set_movemont_animation()
	#判断人物动画方向方法
	player.set_heading()

func handle_human_movement() -> void:
		#针对Player 1 的控制方向代码
	var direction := KeyUtils.get_input_vector(player.control_scheme)
	# 方向 * 速度 = 调整的速度 velocity 是以每秒像素为单位的
	player.velocity = direction * player.speed
	#判断玩家是否持球,且刚按下射门键
	if player.has_ball() and KeyUtils.is_action_just_pressed(player.control_scheme, KeyUtils.Action.SHOOT):
		#过渡到预设门状态
		state_transition_requested.emit(Player.State.PREPPING_SHOT)
		
	#判断玩家的速度是否与向量零不同，并且调用KeyUtils的is_action_just_pressed（）的方法，一个判断值判断是否过度到铲球状态
	#if player.velocity != Vector2.ZERO and KeyUtils.is_action_just_pressed(player.control_scheme, KeyUtils.Action.SHOOT):
	#	#发动信号并携带铲球的参数
	#	state_transition_requested.emit(Player.State.TACKLING)

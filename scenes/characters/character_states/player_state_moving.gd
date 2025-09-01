#这个节点将被添加为Player的子对象，玩家的每一帧都要经过它的处理
#它将通过引用所有Player移动逻辑
#此逻辑特定为移动状态生效
class_name PlayerStateMoving
extends PlayerState

func _process(_delta: float) -> void:
	#检测是我们控制玩家还是CPU控制玩家（AI处理）
	if player.control_scheme == Player.ControlScheme.CPU:
		#调用AI处理方法
		ai_behavior.process_ai()
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
	#判断如果玩家的速度不为0
	if player.velocity != Vector2.ZERO:
		#它们按下了一个方向,旋转视野锥体
		teammate_detection_area.rotation = player.velocity.angle()
		
	#判断玩家是否持球,且刚按下传球键
	if player.has_ball() :
		if KeyUtils.is_action_just_pressed(player.control_scheme, KeyUtils.Action.PASS):
			#过渡到预设门状态
			transition_state(Player.State.PASSING)
		#判断玩家是否持球,且刚按下射门键
		elif KeyUtils.is_action_just_pressed(player.control_scheme, KeyUtils.Action.SHOOT):
			#过渡到预设门状态
			transition_state(Player.State.PREPPING_SHOT)
	elif KeyUtils.is_action_just_pressed(player.control_scheme, KeyUtils.Action.SHOOT):
	#球体本身创造一个方法进行询问，你属于什么状态(判断是你是否是空中交互状态）
		if ball.can_air_interact():
		#判断玩家的速度是否为0
			if player.velocity == Vector2.ZERO:
				#判断我们如果面向目标
				if player.is_facing_target_goal():
					#我们就进入临空抽射状态
					transition_state(Player.State.VOLLEY_KICK)
				else:
					#进入倒挂射门状态
					transition_state(Player.State.BLCYCLE_KICK)
			else:
				#切换到头球状态
				transition_state(Player.State.HEADER)
	#判断玩家的速度是否与向量零不同，并且调用KeyUtils的is_action_just_pressed（）的方法，一个判断值判断是否过度到铲球状态
		elif player.velocity != Vector2.ZERO:
			#发动信号并携带铲球的参数
			state_transition_requested.emit(Player.State.TACKLING)

func can_carry_ball() -> bool:
	return player.role != Player.Role.GOALIE

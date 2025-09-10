class_name PlayerStatePreppingShot
extends PlayerState

#设置一个最大奖励变量，初始为1秒
const DURATION_MAX_BONUS := 1000.0
#初始化奖励最高变量
const EASE_REWARD_FACTOR := 2.0
#跟踪当前方向的变量
var shot_direction := Vector2.ZERO
#初始化记录的时间
var time_start_shot := Time.get_ticks_msec()

#首先播放动画
func _enter_tree() -> void:
	animation_player.play("prep_kick")
	#同时禁止玩家移动
	player.velocity = Vector2.ZERO
	#设置这个值（最好时机）
	time_start_shot = Time.get_ticks_msec()
	#初始化为玩家的方向
	shot_direction = player.heading

#处理过程
func _process(delta: float) -> void:
	#每一帧都会添加到这个方向向量中,此权重为时间量 * 输入向量
	shot_direction += KeyUtils.get_input_vector(player.control_scheme) * delta
	#判断动作是否被松开
	if KeyUtils.is_action_just_released(player.control_scheme, KeyUtils.Action.SHOOT):
		#计算在这些状态中等待乐多久
		#计算当前时间戳与开始时间戳之间的差值
		#这里的值只能在0 - 1 秒之间变化，并存储下来
		var duration_press := clampf(Time.get_ticks_msec() - time_start_shot, 0.0, DURATION_MAX_BONUS)
		#创建一个用于存储实际花费时间值的变量
		var ease_time := duration_press / DURATION_MAX_BONUS
		#此处使用了缓动函数计算
		var bonus := ease(ease_time, EASE_REWARD_FACTOR)
		#计算射程威力 玩家的按住时间 * (1 + 奖励)
		var shot_power := player.power * (1 + bonus)
		#将变量归一化处理
		shot_direction = shot_direction.normalized()
		#创建过渡对象，传递参数
		#var state_data := PlayerStateData.new()
		#state_data.shot_power = shot_power
		#state_data.shot_direction = shot_direction
		#使用构建来创建对象(构建器模式的伟大之处)一行完成一切
		var data = PlayerStateData.build().set_shot_power(shot_power).set_shot_direction(shot_direction)
		#预备射门状态发送状态信号，切换到射门状态(额外添加了射门力量和射门方向）
		transition_state(Player.State.SHOOTING, data)

func can_pass() -> bool:
	return true

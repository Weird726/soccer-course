class_name PlayerStateHeader
extends PlayerState

#球高度最小值
const BALL_HEIGHT_MIN := 10.0
#球高度最大值
const BALL_HEIGHT_MAX := 30.0
#创建一个常量，初始额外力量奖励
const BONUS_POWER := 1.3
#创建一个常量，初始或起始高度
const HEIGHT_START := 0.1
#创建一个常量，初始高度向量
const HEIGHT_VELOCITY := 1.5

#老规矩，进入状态先_enter_tree()
func _enter_tree() -> void:
	animation_player.play("header")
	#以下两个代码都是赋值初始数值
	player.height = HEIGHT_START
	player.height_velocity = HEIGHT_VELOCITY
	#使用球检测区域来查看是否发生了接触
	ball_detection_area.body_entered.connect(on_ball_entered.bind())	

#自动断开信号的方法
func on_ball_entered(contact_ball: Ball) -> void:
	#判断我们是否与球体建立连接
	if  contact_ball.can_air_connect(BALL_HEIGHT_MIN, BALL_HEIGHT_MAX):
		#播放音效
		SoundPlayer.play(SoundPlayer.Sound.POWERSHOT)
		#玩家的向量 * 归一化的值 * 额外奖励
		contact_ball.shoot(player.velocity.normalized() * player.power * BONUS_POWER)

#老规矩，结束状态使用的处理方法 (过程方法）
func _process(_delta: float) -> void:
	#判断玩家的高度是否为0
	if player.height == 0:
		#进入回复状态
		transition_state(Player.State.RECOVERING)

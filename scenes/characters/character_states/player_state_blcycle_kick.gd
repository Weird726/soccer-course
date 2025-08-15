class_name PlayerStateBicycleKick
extends PlayerState


#球的高度最小值
const BALL_HEIGHT_MIN := 5.0
#球的高度最大值
const BALL_HEIGHT_MAX := 25.0
#创建一个额外的奖励（常量）
const BONUS_POWER := 2.0

#老规矩，先播放动画
func _enter_tree() -> void:
	animation_player.play("bicycle_kick")
	#检测球是否已经接触
	ball_detection_area.body_entered.connect(on_ball_entered.bind())

#立即创建一个方法
func on_ball_entered(contact_ball: Ball) -> void:
	#判断球是否可以空中接触
	if contact_ball.can_air_connect(BALL_HEIGHT_MIN, BALL_HEIGHT_MAX):
		#选择目标位置
		var destination := target_goal.get_random_target_position()
		#创建一个方向向量,球从当前位置朝目的地移动的方向,(归一化的向量）
		var direction := ball.position.direction_to(destination)
		#用方向向量将球发射出去，然后与玩家的力量相乘
		contact_ball.shoot(direction * player.power * BONUS_POWER)

#重写onAnimationComplete
func on_animation_complete() -> void:
	#直接过渡到回复状态
	transition_state(Player.State.RECOVERING)

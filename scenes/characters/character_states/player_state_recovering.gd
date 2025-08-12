class_name PlayerStateRecovering
extends PlayerState

#常量回复时长
const DURATION_RECOVERY := 500
#记录时间,当前的时间
var time_start_recovery := Time.get_ticks_msec()

#当我们进入状态时
func _enter_tree() -> void:
	#设置时间
	time_start_recovery = Time.get_ticks_msec()
	#回复时玩家的速度为0
	player.velocity = Vector2.ZERO
	#结束继续滑动，播放正确的动画
	animation_player.play("recover")

#此方法确保我们在此状态下花费了足够的时间
func _process(_delta: float)-> void:
	#如果当前的时间戳 减去 开始回复的时间戳 大于 回复的持续时间
	if Time.get_ticks_msec() - time_start_recovery > DURATION_RECOVERY:
		#转换状态，进入移动状态
		transition_state(Player.State.MOVING)

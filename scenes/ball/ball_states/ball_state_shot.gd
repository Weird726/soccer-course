class_name BallStateShot
extends BallState

#设置一个持续时间的常量
const DURATION_SHOT := 1000
#创建一个射击高度常量
const SHOT_HEIGHT := 5
#精灵缩放常量设置
const SHOT_SPRITE_SCALE := 0.8

#重置记录的时间
var time_since_shot := Time.get_ticks_msec()

#老规矩，进状态先播放动画
func _enter_tree() -> void:
	#判断球是否朝右飞去
	if  ball.velocity.x >= 0:
		#继续播放滚动动画
		animation_player.play("roll")
		#强制动画帧向前推动一帧
		animation_player.advance(0)
	else:
		#否则就倒着滚(动画翻转）
		animation_player.play_backwards("roll")
		#强制动画帧向前推动一帧
		animation_player.advance(0)
	#Y轴缩放 = 射门精灵缩放比
	sprite.scale.y = SHOT_SPRITE_SCALE
	#赋值，使球的高度等于射门的高度
	ball.height = SHOT_HEIGHT
	#作为入口树的一部分并重置时间
	time_since_shot = Time.get_ticks_msec()
#处理方法
func _process(delta: float) -> void:
	#检查已经过去了多少时间,如果超过一秒
	if Time.get_ticks_msec() - time_since_shot > DURATION_SHOT:
		#将过度到自由形态
		state_transition_requested.emit(Ball.State.FREEFORM)
	else:
		#运动计算用调用move_and_collide方法来计算，并保持物理为关闭状态
		ball.move_and_collide(ball.velocity * delta)

#退出树该状态
func _exit_tree() -> void:
	sprite.scale.y = 1.0

#此逻辑将在"tackling"状态作为子节点添加到"Player”时执行
class_name PlayerStateTackling
#扩展玩家状态类以便访问所有类
extends PlayerState
#铲球回复前持续时间
const DURATION_PRIOR_RECOVERY := 200
#添加一个常量来记录摩擦力这个值
const GROUND_FRICTION := 250.0
#私有变量
var is_tackle_complete := false

#设置初始铲球时间为当前的时间，当前时间戳
var time_finish_tackle := Time.get_ticks_msec()
#当我们进入树中.开始过度到这个状态
func _enter_tree() -> void:
	animation_player.play("tackle")


#处理方法
func _process(delta: float) -> void:
	#首先判断是否已经完成铲球动作
	if not is_tackle_complete:
		#如果还没有速度将会逐渐调整直为0（使用godot提供的函数moveTowards来实现）
		player.velocity = player.velocity.move_toward(Vector2.ZERO, delta * GROUND_FRICTION)
		#检查是否已经到达Vector2
		if player.velocity == Vector2.ZERO:
			#如果到达了将此次铲球标记为完成
			is_tackle_complete = true
			#额外功能,记录时间
			time_finish_tackle = Time.get_ticks_msec()
			#检查是否在这个状态停留了足够的时间
		elif Time.get_ticks_msec() - time_finish_tackle > DURATION_PRIOR_RECOVERY:
			#如果是就会转换到玩家的移动状态
			state_transition_requested.emit(Players.State.RECOVERING)

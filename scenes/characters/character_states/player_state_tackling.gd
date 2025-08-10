#此逻辑将在"tackling"状态作为子节点添加到"Player”时执行
class_name PlayerStateTackling
#扩展玩家状态类以便访问所有类
extends PlayerState
#铲球的持续时间
const DURATION_TACKLE := 200
#设置初始铲球时间为当前的时间，当前时间戳
var time_start_tackle := Time.get_ticks_msec()
#当我们进入树中.开始过度到这个状态
func _enter_tree() -> void:
	animation_player.play("tackle")
	#额外功能
	time_start_tackle = Time.get_ticks_msec()

#处理方法
func _process(_delta: float) -> void:
	#检查是否在这个状态停留了足够的时间
	if Time.get_ticks_msec() - time_start_tackle > DURATION_TACKLE:
		#如果是就会转换到玩家的移动状态
		state_transition_requested.emit(Players.State.MOVING)

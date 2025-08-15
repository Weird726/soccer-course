class_name PlayerStateChestControl
extends PlayerState

#创建一个常量用于持续时间(半秒）
const DURATION_CONTROL := 500
#创建一个变量来记录时间：当前的时间戳
var time_since_control := Time.get_ticks_msec()

#老规矩先播放动画
func _enter_tree() -> void:
	animation_player.play("chest_control")
	#阻止玩家移动，修改玩家速度
	player.velocity = Vector2.ZERO
	#标记时间戳（非常重要这个行为，必须要标记那个时间戳）
	time_since_control = Time.get_ticks_msec()
#检查一下时间
func _process(delta: float) -> void:
	#判断我们是否在这个方法内部保持了一定的时间
	if Time.get_ticks_msec() - time_since_control > DURATION_CONTROL:
		#转换到移动状态
		transition_state(Player.State.MOVING)

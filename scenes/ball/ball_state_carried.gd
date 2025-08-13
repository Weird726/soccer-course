class_name BallStateCarried
extends BallState
#创建一个为频率的常量
const DRIBBLE_FREQUENCY := 10.0
#创建一个为强度的常量
const DRIBBLE_INTENSITY := 3.0
#创建一个常量
const OFFSET_FROM_PLAYER := Vector2(10, 4)

#创建时间类变量
var dribble_time := 0.0

#创建一个方法用来确认是否有一个携带者
func _enter_tree() -> void:
	#检查携带者是否为空
	assert(carrier != null)

#设置球的位置方法
func _process(delta: float) -> void:
	#新变量
	var vx := 0.0
	#加到时间上
	dribble_time += delta
	#判断角色的速度是否为0从而转换动画状态
	if carrier.velocity != Vector2.ZERO:
		#如果VX的x值不为0，就执行这个操作
		if carrier.velocity.x != 0:
			#余弦函数,用于模拟球在脚步运动的假动画
			vx = cos(dribble_time * DRIBBLE_FREQUENCY) * DRIBBLE_INTENSITY
		if carrier.heading.x >= 0:
			animation_player.play("roll")
			#强制以0秒的时间前进
			animation_player.advance(0)
		else:
			animation_player.play_backwards("roll")
			#强制以0秒的时间前进
			animation_player.advance(0)
	else:
		animation_player.play("idle")
		#处理重力的
		process_gravity(delta)
	#设置为携带者的位置,增加一个偏移量
	ball.position = carrier.position + Vector2(vx + carrier.heading.x * OFFSET_FROM_PLAYER.x, OFFSET_FROM_PLAYER.y)

class_name BallStateFreeform
extends BallState

const MAX_CAPTURE_HEIGHT := 25

#记录进入该状态的时间的变量
var time_since_freeform := Time.get_ticks_msec()

#检测玩家是否重叠的方法
func _enter_tree() -> void:
	#连接到这个信号,并绑定它
	player_detection_area.body_entered.connect(on_player_enter.bind())
	time_since_freeform = Time.get_ticks_msec()

#创建绑定的方法，接收一个玩家参数
func on_player_enter(body : Player) -> void:
#给球对球员接球时的高度设置上限
	if body.can_carry_ball() and ball.height < MAX_CAPTURE_HEIGHT:
		#从被携带状态转换属性
		ball.carrier = body
		body.control_ball()
		#切换到被携带状态
		transition_state(Ball.State.CARRIED)

#判断状态播放动画的方法
func _process(delta: float) -> void:
	#判断已经过去了多少的时间
	player_detection_area.monitoring = (Time.get_ticks_msec() - time_since_freeform > state_data.lock_duration)
	#动画状态反转函数
	set_ball_animation_from_velocity()
	#判断应用哪种摩擦力,此处是三元运算符
	var friction := ball.friction_air if ball.height > 0 else ball.friction_ground
	#球的速度以时间间隔逐渐减小到零
	ball.velocity = ball.velocity.move_toward(Vector2.ZERO, friction * delta)
	#处理重力并传入增量（因用一个弹跳因子）
	process_gravity(delta, ball.BOUNCINESS)
	#PhysicsBody2D提供的移动和碰撞方法，速度 * 每秒增量 = 像素每秒为单位的速度
	move_and_bounce(delta)

func can_air_interact() -> bool:
	return true

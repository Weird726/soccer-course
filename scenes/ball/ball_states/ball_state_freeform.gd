class_name BallStateFreeform
extends BallState

#常量，弹跳因子
const BOUNCINESS := 0.8
#常量，摩擦空气
const FRICTION_AIR := 35.0
#常量，摩擦地面
const FRICTION_GROUND := 250.0

#检测玩家是否重叠的方法
func _enter_tree() -> void:
	#连接到这个信号,并绑定它
	player_detection_area.body_entered.connect(on_player_enter.bind())

#创建绑定的方法，接收一个玩家参数
func on_player_enter(body : Player) -> void:
	#从被携带状态转换属性
	ball.carrier = body
	#切换到被携带状态
	state_transition_requested.emit(Ball.State.CARRIED)

#判断状态播放动画的方法
func _process(delta: float) -> void:
	#动画状态反转函数
	set_ball_animation_from_velocity()
	#判断应用哪种摩擦力,此处是三元运算符
	var friction := FRICTION_AIR if ball.height > 0 else FRICTION_GROUND
	#球的速度以时间间隔逐渐减小到零
	ball.velocity = ball.velocity.move_toward(Vector2.ZERO, friction * delta)
	#处理重力并传入增量（因用一个弹跳因子）
	process_gravity(delta, BOUNCINESS)
	#PhysicsBody2D提供的移动和碰撞方法，速度 * 每秒增量 = 像素每秒为单位的速度
	ball.move_and_collide((ball.velocity * delta))

#这样设置的好处是所有状态都能访问Ball
#并且所有状态的逻辑都能改变球的属性
class_name BallState
extends Node
#重力常数
const GRAVITY := 10.0

#设置一个信号来转换状态
signal state_transition_requested(new_state: BallState)

#设置一个动画对象引用
var animation_player : AnimationPlayer = null
#设置一个对Ball对象的引用
var ball : Ball = null
#类型为玩家的携带者参数
var carrier : Player = null
#创建一个变量,初始值为空
var player_detection_area : Area2D = null
#创建一个变量，球自身精灵贴图
var sprite : Sprite2D = null

#设置一个方法来设置这些状态,添加Area2d后所有的状态逻辑都能访问它
func setup(context_ball : Ball, context_player_detection_area : Area2D, context_carrier : Player, context_animation_player : AnimationPlayer, context_sprite : Sprite2D) -> void:
	#设置Ball对象
	ball = context_ball
	#设置赋值检测区域
	player_detection_area = context_player_detection_area
	#传递后赋值
	carrier = context_carrier
	#传递动画复制引用对象
	animation_player = context_animation_player
	#传递图片精灵引用对象
	sprite = context_sprite

func set_ball_animation_from_velocity() -> void:
		#判断球的速度是否为0
	if ball.velocity == Vector2.ZERO:
		#播放闲置动画
		animation_player.play("idle")
	#否则判断是否朝右移动
	elif ball.velocity.x > 0:
		animation_player.play("roll")
		#强制推进动画播放器，防止卡住
		animation_player.advance(0)
	else:
		#否则向后播放
		animation_player.play_backwards("roll")
		#强制推进动画播放器，防止卡住
		animation_player.advance(0)

#模拟重力过程的方法
func process_gravity(delta: float, bounciness: float = 0.0) -> void:
	#判断球是否在高空,或者球的高度大于0时，球就在向上运动
	if ball.height > 0 or ball.height_velocity > 0:
		#球的高度以及高度速度会受到速度的影响
		ball.height_velocity -= GRAVITY * delta
		#添加速度和高度速度
		ball.height += ball.height_velocity
		#判断球的高度防止穿过地面
		if ball.height < 0:
			#如果球在地面将暂时保持在地面上
			ball.height = 0
			#检查是否有弹跳因子,同时检查是否进入了地面
			if bounciness > 0 and ball.height_velocity < 0:
				#回复这个高度速度（从而实现弹跳效果
				ball.height_velocity = -ball.height_velocity * bounciness
				#球的速度 = 球的速度 * 弹跳因子(这种写法也是可行的）
				ball.velocity *= bounciness

#移动并弹跳方法
func move_and_bounce(delta: float) -> void:
	#调用这个碰撞方法
	var collision := ball.move_and_collide(ball.velocity * delta)
	#判断是否确实发生了碰撞
	if collision != null:
		#让球反弹,调整球的速度（这个bounce的用法需要指定法线)
		ball.velocity = ball.velocity.bounce(collision.get_normal()) * ball.BOUNCINESS
		#防止效果成为强力射出，所以切换为自由状态
		ball.switch_state(Ball.State.FREEFORM)

#创建这个空气交互方法
func can_air_interact() -> bool:
	return false

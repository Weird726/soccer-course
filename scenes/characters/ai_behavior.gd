class_name AIBehavior
extends Node

#限制调用的计时器常量
const DURATION_AI_TICK_FREQUENCY := 200

#定义一些变量来存储引用
var ball : Ball = null
var player : Player = null
#创建一个计时器变量并初始化为当前时间戳
var time_since_last_ai_tick := Time.get_ticks_msec()

#经典准备就绪方法
func _ready() -> void:
	#初始化这个时间，添加一个0-200随机数
	time_since_last_ai_tick = Time.get_ticks_msec() + randi_range(0, DURATION_AI_TICK_FREQUENCY)

#创建一个依赖方法setup
func setup(context_player : Player, context_ball : Ball) -> void:
	player = context_player
	ball = context_ball

#创建一个空方法用于AI处理，每次AI执行任务时都执行这个方法
func process_ai() -> void:
	#判断是否已经过去了足够的时间
	if Time.get_ticks_msec() - time_since_last_ai_tick > DURATION_AI_TICK_FREQUENCY:
		#重置计时器,防止不断调用
		time_since_last_ai_tick = Time.get_ticks_msec()
		#移动方法
		perform_ai_movement()
		#决策方法
		perform_ai_decisions()

func perform_ai_movement() -> void:
	#创建转向力向量，添加这个转向力
	var total_steering_force := Vector2.ZERO
	total_steering_force += get_onduty_steering_force()
	#限制转向向量的长度
	total_steering_force = total_steering_force.limit_length(1.0)
	#现在根据转向力来影响速度
	player.velocity = total_steering_force * player.speed

func perform_ai_decisions() -> void:
	pass

func get_onduty_steering_force() -> Vector2:
	#返回球员的权重 * 方向向量相乘
	return player.weight_on_duty_steering * player.position.direction_to(ball.position)

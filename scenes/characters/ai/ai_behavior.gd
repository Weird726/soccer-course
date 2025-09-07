class_name AIBehavior
extends Node

#限制调用的计时器常量
const DURATION_AI_TICK_FREQUENCY := 200


#定义一些变量来存储引用
var ball : Ball = null
#定义一个对手检测区域变量初始化为空（ai）
var opponent_detection_area : Area2D = null
var player : Player = null
#ai引用区域
var teammate_detection_area : Area2D = null
#创建一个计时器变量并初始化为当前时间戳
var time_since_last_ai_tick := Time.get_ticks_msec()

#经典准备就绪方法
func _ready() -> void:
	#初始化这个时间，添加一个0-200随机数
	time_since_last_ai_tick = Time.get_ticks_msec() + randi_range(0, DURATION_AI_TICK_FREQUENCY)

#创建一个依赖方法setup
func setup(context_player : Player, context_ball : Ball, context_opponent_detection_area: Area2D, context_teammate_detection_area: Area2D,) -> void:
	player = context_player
	ball = context_ball
	opponent_detection_area = context_opponent_detection_area
	teammate_detection_area = context_teammate_detection_area

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
	pass

func perform_ai_decisions() -> void:
	pass

#获取双圆权重的方法
func get_bicircular_weight(position: Vector2, center_target: Vector2, inner_circle_radius: float, inner_circle_weight: float, outer_circle_radius: float, outer_circle_weight: float) -> float:
	var distance_to_center := position.distance_to(center_target)
	#判断该距离是否大于外圈半径
	if distance_to_center > outer_circle_radius:
		#返回外圈权重
		return outer_circle_weight
	#判断是否在内圈内
	elif distance_to_center < inner_circle_radius:
		return inner_circle_weight
	else:
		#内圈距离 = 中心距离 - 内圈半径
		var distance_to_inner_radius := distance_to_center - inner_circle_radius
		#计算小圆与大圆之间的总距离
		var close_range_distance := outer_circle_radius - inner_circle_radius
		#创建插值（在内圈权重与外圈权重之间进行插值计算）
		return lerpf(inner_circle_weight, outer_circle_weight, distance_to_inner_radius / close_range_distance)

#用于判断对手控球状态的方法
func is_ball_possessed_by_opponent() -> bool:
	#返回值
	return ball.carrier != null and ball.carrier.country != player.country
#创建一个判断球队当前是否持球的函数
func is_ball_carried_by_teammate() -> bool:
	#判断当前要有持球者的同时保证持球者不是玩家自己
	return ball.carrier != null and ball.carrier != player and ball.carrier.country == player.country

#检测区域内部是否有敌对球队的玩家方法
func has_opponents_nearby() -> bool:
	var players := opponent_detection_area.get_overlapping_bodies()
	return players.find_custom(func(p: Player): return p.country != player.country) > -1

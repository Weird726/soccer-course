class_name AIBehavior
extends Node

#限制调用的计时器常量
const DURATION_AI_TICK_FREQUENCY := 200
#通过概率常量
const PASS_PROBABILTY := 0.05
#创建一个150的常量
const SHOT_DISTANCE := 150
#概率常量
const SHOT_PROBABILITY := 0.3
#创建一个球员速度常量
const SPREAD_ASSIST_FACTOR := 0.8
const TACKLE_DISTANCE := 15
const TACKLE_PROBABILITY := 0.3

#定义一些变量来存储引用
var ball : Ball = null
#定义一个对手检测区域变量初始化为空（ai）
var opponent_detection_area : Area2D = null
var player : Player = null
#创建一个计时器变量并初始化为当前时间戳
var time_since_last_ai_tick := Time.get_ticks_msec()

#经典准备就绪方法
func _ready() -> void:
	#初始化这个时间，添加一个0-200随机数
	time_since_last_ai_tick = Time.get_ticks_msec() + randi_range(0, DURATION_AI_TICK_FREQUENCY)

#创建一个依赖方法setup
func setup(context_player : Player, context_ball : Ball, context_opponent_detection_area: Area2D) -> void:
	player = context_player
	ball = context_ball
	opponent_detection_area = context_opponent_detection_area

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
	#判断玩家是否当前持球
	if player.has_ball():
		total_steering_force += get_carrier_steering_force()
	#只有当不是守门员的时候才能执行if 代码块
	elif player.role != Player.Role.GOALIE:
		total_steering_force += get_onduty_steering_force()
		#先判断是否有队友持球
		if is_ball_carried_by_teammate():
			total_steering_force += get_assist_formation_steering()
	#限制转向向量的长度
	total_steering_force = total_steering_force.limit_length(1.0)
	#现在根据转向力来影响速度
	player.velocity = total_steering_force * player.speed

#AI决策部分
func perform_ai_decisions() -> void:
	#判断球是否被对方球员持有
	if is_ball_possessed_by_opponent() and player.position.distance_to(ball.position) < TACKLE_DISTANCE and randf() < TACKLE_PROBABILITY:
		#进入拦截状态
		player.switch_state(Player.State.TACKLING)
	#首先判断球员是否持球
	if ball.carrier == player:
		#计算球员与球门之间的距离
		var target := player.target_goal.get_center_target_position()
		#判断检查目标的距离，判断0~1的随机值是否小于来实现概念
		if player.position.distance_to(target) < SHOT_DISTANCE and randf() < SHOT_PROBABILITY:
			#创建方法
			face_towards_target_goal()
			#射门方向变量
			var shot_direction := player.position.direction_to(player.target_goal.get_random_target_position())
			#设置射门方向，暂时当前射门朝向
			var data := PlayerStateData.build().set_shot_power(player.power).set_shot_direction(shot_direction)
			#在射门前确保目标面朝射门方向
			player.switch_state(Player.State.SHOOTING, data)
		#不需要射门情况下判断是否有对手
		elif has_opponents_nearby() and randf() < PASS_PROBABILTY:
			player.switch_state(Player.State.PASSING)

func get_onduty_steering_force() -> Vector2:
	#返回球员的权重 * 方向向量相乘
	return player.weight_on_duty_steering * player.position.direction_to(ball.position)

#载体转向力
func get_carrier_steering_force() -> Vector2:
	#确定位置
	var target := player.target_goal.get_center_target_position()
	#确定方向
	var direction := player.position.direction_to(target)
	#权重
	var weight := get_bicircular_weight(player.position, target, 100, 0, 150, 1)
	#返回权重 * 方向向量
	return weight * direction

#创建一个获取协助编队转向函数
func get_assist_formation_steering() -> Vector2:
	#出生点差异变量
	var spawn_difference := ball.carrier.spawn_position - player.spawn_position
	#获得协助位置变量
	var assist_destination := ball.carrier.position - spawn_difference * SPREAD_ASSIST_FACTOR
	#获得方向变量
	var direction := player.position.direction_to(assist_destination)
	#获得权重变量
	var weight := get_bicircular_weight(player.position, assist_destination, 30, 0.2, 60, 1)
	return weight * direction

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

#创建一个球员面向方法(没有返回值的方法）
func face_towards_target_goal() -> void:
	if not player.is_facing_target_goal():
		player.heading = player.heading * -1

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

class_name AIBehaviorField
extends AIBehavior

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

func perform_ai_movement() -> void:
	#创建转向力向量，添加这个转向力
	var total_steering_force := Vector2.ZERO
	#判断玩家是否当前持球
	if player.has_ball():
		total_steering_force += get_carrier_steering_force()
	#先判断是否有队友持球
	elif is_ball_carried_by_teammate():
		total_steering_force += get_assist_formation_steering_force()
	#只有当不是守门员的时候才能执行if 代码块
	else:
		total_steering_force += get_onduty_steering_force()
		#检查操控力的长度
		if total_steering_force.length_squared() < 1:
			#判断球是否在对方球队下
			if is_ball_possessed_by_opponent():
				total_steering_force += get_spawn_steering_force()
				#自由的向球移动
			elif ball.carrier == null:
				total_steering_force += get_ball_proximity_steering_force()

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
			player.face_towards_target_goal()
			#射门方向变量
			var shot_direction := player.position.direction_to(player.target_goal.get_random_target_position())
			#设置射门方向，暂时当前射门朝向
			var data := PlayerStateData.build().set_shot_power(player.power).set_shot_direction(shot_direction)
			#在射门前确保目标面朝射门方向
			player.switch_state(Player.State.SHOOTING, data)
		#不需要射门情况下判断是否有对手(轻量级判断放前面，重量级往后放）
		elif randf() < PASS_PROBABILTY and has_opponents_nearby() and has_teammate_in_view():
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
func get_assist_formation_steering_force() -> Vector2:
	#出生点差异变量
	var spawn_difference := ball.carrier.spawn_position - player.spawn_position
	#获得协助位置变量
	var assist_destination := ball.carrier.position - spawn_difference * SPREAD_ASSIST_FACTOR
	#获得方向变量
	var direction := player.position.direction_to(assist_destination)
	#获得权重变量
	var weight := get_bicircular_weight(player.position, assist_destination, 30, 0.2, 60, 1)
	return weight * direction

#创建一个获取球接近转向的力的方法
func get_ball_proximity_steering_force() -> Vector2:
	#在次使用双圆权重
	var weight := get_bicircular_weight(player.position, ball.position, 50, 1, 120, 0)
	#方向向量
	var direction := player.position.direction_to(ball.position)
	#返回它们
	return weight * direction

#获取返回转向力的方法
func get_spawn_steering_force() -> Vector2:
	var weight := get_bicircular_weight(player.position, player.spawn_position, 30, 0, 100, 1)
	var direction := player.position.direction_to(player.spawn_position)
	return weight * direction

#有队友在视图的情况下
func has_teammate_in_view() -> bool:
	var players_in_view := teammate_detection_area.get_overlapping_bodies()
	return players_in_view.find_custom(func(p: Player): return p != player and p.country == player.country) > -1

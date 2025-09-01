class_name AIBehaviorGoalie
extends AIBehavior

const PROXIMITY_CONCERN := 10.0

#AI自主决定方法
func perform_ai_movement() -> void:
	#创建转向力向量，添加这个转向力
	var total_steering_force := get_goalie_steering_force()
	#限制转向向量的长度
	total_steering_force = total_steering_force.limit_length(1.0)
	#现在根据转向力来影响速度
	player.velocity = total_steering_force * player.speed

#AI自主移动方法
func perform_ai_decisions() -> void:
	#判断球是否朝向得分区域
	if ball.is_headed_for_scoring_area(player.own_goal.get_scoring_area()):
		#切换到俯冲状态
		player.switch_state(Player.State.DIVING)


#获取守门员转向力的方法
func get_goalie_steering_force() -> Vector2:
	#上方位置
	var top := player.own_goal.get_top_target_position()
	#下方位置
	var bottom := player.own_goal.get_bottom_target_position()
	#中心点位置
	var center := player.spawn_position
	#球的垂直位置
	var target_y := clampf(ball.position.y, top.y, bottom.y)
	#目的地位置
	var destination := Vector2(center.x, target_y)
	#方向
	var direction := player.position.direction_to(destination)
	#计算到目的地的距离
	var distance_to_destination := player.position.distance_to(destination)
	#计算权重
	var weight := clampf(distance_to_destination / PROXIMITY_CONCERN, 0, 1)
	#返回权重*方向
	return weight * direction

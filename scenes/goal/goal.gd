class_name Goal
extends Node2D

@onready var back_net_area: Area2D = %BackNetArea
@onready var scoring_area: Area2D = %ScoringArea
@onready var targets: Node2D = %Targets

#监听球何时进入该区域
func _ready() -> void:
	#添加一个监听器并创建一个函数（函数名的描述最好是非常清晰）用于监听
	back_net_area.body_entered.connect(on_ball_enter_back_net.bind())

#球进入网里时的函数
func on_ball_enter_back_net(ball: Ball) -> void:
	#进入网格范围让球停止
	ball.stop()

#可调用的方法,随机目标位置
func get_random_target_position() -> Vector2:
	#返回一个随机点，在0和获取子元素的数量随机变化
	return targets.get_child(randi_range(0, targets.get_child_count() - 1)).global_position

#中心目标职位方法
func get_center_target_position() -> Vector2:
	return targets.get_child(int(targets.get_child_count() / 2.0)).global_position

#获取球门最上方目标点位置的方法
func get_top_target_position() -> Vector2:
	return targets.get_child(0).global_position

#获取球门最下方目标点位置的方法
func get_bottom_target_position() -> Vector2:
	return targets.get_child(targets.get_child_count() - 1).global_position

func get_scoring_area() -> Area2D:
	return scoring_area
